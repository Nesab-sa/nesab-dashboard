import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// تنزيل ملف نصي في المتصفح عبر Blob + رابط مؤقت.
bool downloadTextFile(String filename, String content, {String mime = 'text/plain'}) {
  final blob = web.Blob(
    [content.toJS].toJS,
    web.BlobPropertyBag(type: mime),
  );
  final url = web.URL.createObjectURL(blob);
  final anchor = web.HTMLAnchorElement()
    ..href = url
    ..download = filename;
  web.document.body?.appendChild(anchor);
  anchor.click();
  anchor.remove();
  web.URL.revokeObjectURL(url);
  return true;
}
