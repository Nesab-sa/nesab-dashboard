import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// الرابط الرسمي للداشبورد — لا يُغيَّر.
/// تطبيق الجوال غلاف WebView يفتح هذا الرابط الحيّ، فتظهر أي تحديثات تُنشر
/// على الويب فوراً داخل التطبيق بمجرد إعادة فتحه، دون إعادة بناء.
const String kDashboardUrl = 'https://nesab-26771.web.app/';

class DashboardWebViewApp extends StatelessWidget {
  const DashboardWebViewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Nesab Dashboard',
      debugShowCheckedModeBanner: false,
      home: DashboardWebViewPage(),
    );
  }
}

class DashboardWebViewPage extends StatefulWidget {
  const DashboardWebViewPage({super.key});

  @override
  State<DashboardWebViewPage> createState() => _DashboardWebViewPageState();
}

class _DashboardWebViewPageState extends State<DashboardWebViewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (!mounted) return;
            setState(() {
              _isLoading = true;
              _hasError = false;
            });
          },
          onPageFinished: (_) {
            if (!mounted) return;
            setState(() => _isLoading = false);
          },
          onWebResourceError: (error) {
            // أظهر شاشة إعادة المحاولة فقط عند فشل تحميل الصفحة الرئيسية.
            if (!mounted || !(error.isForMainFrame ?? true)) return;
            setState(() {
              _isLoading = false;
              _hasError = true;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(kDashboardUrl));
  }

  void _reload() {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    _controller.loadRequest(Uri.parse(kDashboardUrl));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (await _controller.canGoBack()) {
          await _controller.goBack();
        } else {
          await SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Stack(
            children: [
              if (!_hasError) WebViewWidget(controller: _controller),
              if (_isLoading && !_hasError)
                const Center(child: CircularProgressIndicator()),
              if (_hasError) _ErrorView(onRetry: _reload),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 56, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'تعذّر الاتصال بالداشبورد.\n'
              'تأكد من اتصالك بالإنترنت ثم أعد المحاولة.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}
