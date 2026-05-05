import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nesab/app/dependency_injection.dart';
import 'package:nesab/core/services/local_signature_service.dart';
import 'package:nesab/shared/widgets/app_back_button.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// A full-screen page that loads [url] in an in-app WebView
/// with a back button overlaid at the top.
/// Supports saving PDFs and images generated client-side (e.g. html2pdf.js).
class CalculatorWebViewPage extends StatefulWidget {
  const CalculatorWebViewPage({required this.url, this.title, super.key});

  final String url;
  final String? title;

  @override
  State<CalculatorWebViewPage> createState() => _CalculatorWebViewPageState();
}

class _CalculatorWebViewPageState extends State<CalculatorWebViewPage> {
  double _progress = 0;
  bool _isLoading = true;
  InAppWebViewController? _webViewController;
  String? _signatureBase64;
  String _signatureName = '';
  String _signatureNumber = '';

  @override
  void initState() {
    super.initState();
    _loadSignature();
  }

  Future<void> _loadSignature() async {
    final service = getIt<LocalSignatureService>();
    final base64 = await service.getSignatureBase64();
    final name = await service.getName() ?? '';
    final number = await service.getNumber() ?? '';
    if (mounted) {
      setState(() {
        _signatureBase64 = base64;
        _signatureName = name;
        _signatureNumber = number;
      });
      _injectSignature();
    }
  }

  Future<void> _injectSignature() async {
    final controller = _webViewController;
    final sig = _signatureBase64;
    final name = _signatureName.replaceAll("'", "\\'");
    final number = _signatureNumber.replaceAll("'", "\\'");
    if (controller == null) return;
    // At least one of signature, name, or number must be present
    if (sig == null && name.isEmpty && number.isEmpty) return;

    final sigDataUri = sig != null ? 'data:image/png;base64,$sig' : '';

    await controller.evaluateJavascript(source: '''
(function() {
  window.__nesabSignatureName = '$name';
  window.__nesabSignatureNumber = '$number';

  if ('$sigDataUri') {
    window.__nesabSignatureBase64 = '$sigDataUri';
    window.__nesabSigImg = new Image();
    window.__nesabSigImg.src = window.__nesabSignatureBase64;
  }

  // Wrap _drawResultCanvas to append signature info at bottom-left
  if (typeof window._drawResultCanvas === 'function' && !window.__sigPatched) {
    window.__sigPatched = true;
    var origDraw = window._drawResultCanvas;
    window._drawResultCanvas = function(data, title) {
      var c = origDraw(data, title);
      var ctx = c.getContext('2d');
      var S = 2;
      var W = c.width / S;
      var totalH = c.height / S;

      var sigImg = window.__nesabSigImg;
      var sigName = window.__nesabSignatureName || '';
      var sigNumber = window.__nesabSignatureNumber || '';
      var hasSigImg = sigImg && sigImg.complete && sigImg.naturalWidth > 0;
      var hasInfo = sigName || sigNumber || hasSigImg;

      if (hasInfo) {
        var pad = 30;
        var sigW = 120, sigH = 60;
        var textLineH = 16;
        var textLines = 0;
        if (sigName) textLines++;
        if (sigNumber) textLines++;
        var textBlockH = textLines * textLineH;
        var blockH = Math.max(hasSigImg ? sigH : 0, textBlockH) + 20;

        // Expand canvas to fit signature block
        var newH = totalH + blockH + 20;
        var tempData = ctx.getImageData(0, 0, c.width, c.height);
        c.height = newH * S;
        ctx.scale(S, S);
        ctx.putImageData(tempData, 0, 0);

        // Draw background fill for new area
        ctx.fillStyle = '#0d2040';
        ctx.fillRect(0, totalH - 20, W, blockH + 40);

        // Re-draw watermark
        ctx.fillStyle = '#4a6a9a';
        ctx.font = '10px Cairo,sans-serif';
        ctx.textAlign = 'center';
        ctx.fillText('NESAB — www.Nesab.sa — By Abdullah Almalki', W / 2, newH - 12);

        // Draw at bottom-left
        var x = pad;
        var y = totalH - 5;

        // Draw signature image
        if (hasSigImg) {
          ctx.drawImage(sigImg, x, y, sigW, sigH);
        }

        // Draw name and number below or beside the signature
        ctx.fillStyle = '#ffffff';
        ctx.font = '12px Cairo,sans-serif';
        ctx.textAlign = 'left';
        var textX = hasSigImg ? x + sigW + 12 : x;
        var textY = y + 20;
        if (sigName) {
          ctx.fillText(sigName, textX, textY);
          textY += textLineH;
        }
        if (sigNumber) {
          ctx.fillText(sigNumber, textX, textY);
        }
      }
      return c;
    };
  }
})();
''');
  }

  /// JavaScript that intercepts blob downloads triggered by html2pdf.js
  /// and similar libraries. It overrides the <a> click-to-download pattern
  /// and sends the blob data back to Flutter as base64.
  static const String _blobInterceptJs = '''
(function() {
  if (window.__flutterBlobInterceptInstalled) return;
  window.__flutterBlobInterceptInstalled = true;

  // Store blobs by their object URL so we can retrieve them
  // even after html2pdf.js calls revokeObjectURL.
  window.__flutterBlobStore = {};

  // Override createObjectURL to store blob references.
  var origCreateObjectURL = URL.createObjectURL.bind(URL);
  URL.createObjectURL = function(blob) {
    var url = origCreateObjectURL(blob);
    if (blob instanceof Blob) {
      window.__flutterBlobStore[url] = blob;
    }
    return url;
  };

  // Override revokeObjectURL to delay revocation so fetch can still work.
  var origRevokeObjectURL = URL.revokeObjectURL.bind(URL);
  URL.revokeObjectURL = function(url) {
    // Delay revocation by 5 seconds to give Flutter time to fetch.
    setTimeout(function() {
      delete window.__flutterBlobStore[url];
      origRevokeObjectURL(url);
    }, 5000);
  };

  // Override <a> element creation to intercept click-to-download.
  var origCreateElement = document.createElement.bind(document);
  document.createElement = function(tag) {
    var el = origCreateElement(tag);
    if (tag.toLowerCase() === 'a') {
      var origClick = el.click.bind(el);
      el.click = function() {
        if (el.href && el.href.startsWith('data:')) {
          var fileName = el.download || 'download';
          var parts = el.href.split(',');
          var meta = parts[0];
          var base64 = parts.slice(1).join(',');
          var mimeType = meta.split(':')[1].split(';')[0];
          window.flutter_inappwebview.callHandler(
            'onBlobDownload', base64, fileName, mimeType
          );
          return;
        }
        if (el.href && el.href.startsWith('blob:')) {
          var fileName = el.download || 'download';
          var storedBlob = window.__flutterBlobStore[el.href];
          if (storedBlob) {
            var reader = new FileReader();
            reader.onloadend = function() {
              var base64 = reader.result.split(',')[1];
              var mimeType = storedBlob.type || 'application/octet-stream';
              window.flutter_inappwebview.callHandler(
                'onBlobDownload', base64, fileName, mimeType
              );
            };
            reader.readAsDataURL(storedBlob);
          } else {
            fetch(el.href)
              .then(function(r) { return r.blob(); })
              .then(function(blob) {
                var reader = new FileReader();
                reader.onloadend = function() {
                  var base64 = reader.result.split(',')[1];
                  var mimeType = blob.type || 'application/octet-stream';
                  window.flutter_inappwebview.callHandler(
                    'onBlobDownload', base64, fileName, mimeType
                  );
                };
                reader.readAsDataURL(blob);
              });
          }
          return;
        }
        origClick();
      };
    }
    return el;
  };

  // Intercept FileSaver.js saveAs if used.
  if (typeof window.saveAs === 'function') {
    window.saveAs = function(blob, fileName) {
      var reader = new FileReader();
      reader.onloadend = function() {
        var base64 = reader.result.split(',')[1];
        var mimeType = blob.type || 'application/octet-stream';
        window.flutter_inappwebview.callHandler(
          'onBlobDownload', base64, fileName || 'download', mimeType
        );
      };
      reader.readAsDataURL(blob);
    };
  }
})();
''';

  bool _isSharing = false;

  Future<void> _saveFile(
    String base64Data,
    String fileName,
    String mimeType,
  ) async {
    // Prevent overlapping share sheets (webview may fire multiple downloads)
    if (_isSharing) return;
    _isSharing = true;

    try {
      final Uint8List bytes = base64Decode(base64Data);

      // Ensure proper file extension.
      if (!fileName.contains('.')) {
        if (mimeType.contains('pdf')) {
          fileName = '$fileName.pdf';
        } else if (mimeType.contains('png')) {
          fileName = '$fileName.png';
        } else if (mimeType.contains('jpeg') || mimeType.contains('jpg')) {
          fileName = '$fileName.jpg';
        }
      }

      // Write to temp directory (no permissions needed), then share
      final tempDir = await getTemporaryDirectory();
      final tempPath = '${tempDir.path}/$fileName';
      await File(tempPath).writeAsBytes(bytes);

      // sharePositionOrigin is required for iPad share sheet
      final box = context.findRenderObject() as RenderBox?;
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(tempPath, mimeType: mimeType)],
          sharePositionOrigin: box != null
              ? box.localToGlobal(Offset.zero) & box.size
              : null,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل الحفظ: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      _isSharing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(widget.url)),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              useOnDownloadStart: true,
              allowFileAccessFromFileURLs: true,
              allowUniversalAccessFromFileURLs: true,
            ),
            onWebViewCreated: (controller) {
              _webViewController = controller;
              controller.addJavaScriptHandler(
                handlerName: 'onBlobDownload',
                callback: (args) {
                  if (args.length >= 3) {
                    _saveFile(
                      args[0] as String,
                      args[1] as String,
                      args[2] as String,
                    );
                  }
                },
              );
            },
            onLoadStart: (controller, url) {
              if (mounted) {
                setState(() => _isLoading = true);
              }
            },
            onLoadStop: (controller, url) async {
              await controller.evaluateJavascript(source: _blobInterceptJs);
              _injectSignature();
              if (mounted) {
                setState(() => _isLoading = false);
              }
            },
            onProgressChanged: (_, progress) {
              setState(() => _progress = progress / 100);
            },
            onDownloadStartRequest: (controller, request) async {
              final url = request.url.toString();

              // Handle blob: URLs (e.g. PDF from html2pdf.js).
              // Blob URLs can't be fetched from Dart — inject JS to read
              // the blob, convert to base64, and send back via handler.
              if (url.startsWith('blob:')) {
                final fileName =
                    request.suggestedFilename ?? 'download.pdf';
                final escapedUrl = url.replaceAll("'", "\\'");
                final escapedName = fileName.replaceAll("'", "\\'");
                await _webViewController?.evaluateJavascript(source: '''
(function() {
  var storedBlob = window.__flutterBlobStore && window.__flutterBlobStore['$escapedUrl'];
  function sendBlob(blob) {
    var reader = new FileReader();
    reader.onloadend = function() {
      var base64 = reader.result.split(',')[1];
      var mimeType = blob.type || 'application/octet-stream';
      window.flutter_inappwebview.callHandler(
        'onBlobDownload', base64, '$escapedName', mimeType
      );
    };
    reader.readAsDataURL(blob);
  }
  if (storedBlob) {
    sendBlob(storedBlob);
  } else {
    fetch('$escapedUrl')
      .then(function(r) { return r.blob(); })
      .then(sendBlob)
      .catch(function(err) {
        console.error('Flutter blob download error: ' + err);
      });
  }
})();
''');
                return;
              }

              // Handle data: URLs (e.g. from html2canvas).
              if (url.startsWith('data:')) {
                final commaIndex = url.indexOf(',');
                if (commaIndex == -1) return;
                final meta = url.substring(0, commaIndex);
                final base64Data = url.substring(commaIndex + 1);
                // Extract mime type: "data:image/png;base64" -> "image/png"
                final mimeType =
                    meta.replaceFirst('data:', '').split(';').first;
                final fileName =
                    request.suggestedFilename ?? 'download';
                _saveFile(base64Data, fileName, mimeType);
                return;
              }

              final fileName = request.suggestedFilename ?? url.split('/').last;
              try {
                final httpClient = HttpClient();
                final req = await httpClient.getUrl(Uri.parse(url));
                final resp = await req.close();
                final bytes = await resp.fold<List<int>>(
                  <int>[],
                  (list, chunk) => list..addAll(chunk),
                );

                final tempDir = await getTemporaryDirectory();
                final tempPath = '${tempDir.path}/$fileName';
                await File(tempPath).writeAsBytes(bytes);

                await SharePlus.instance.share(
                  ShareParams(
                    files: [XFile(tempPath)],
                  ),
                );
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('فشل الحفظ: $e'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
Positioned(bottom: 16, right: 16, child: AppBackButton()),
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.3),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(
                          'جاري التحميل...',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: 200,
                          child: LinearProgressIndicator(
                            value: _progress > 0 ? _progress : null,
                            backgroundColor: Colors.grey[300],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}
}
