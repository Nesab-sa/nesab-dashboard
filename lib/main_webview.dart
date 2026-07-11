// نقطة دخول مستقلة لتطبيق الداشبورد على الجوال (أندرويد/iOS).
//
// هذا الملف يشغّل غلاف WebView فقط ولا يستورد أيّ كود من الداشبورد الأصلي،
// لذلك يُبنى الـAPK بمعزل تام عن مكتبات/شاشات الداشبورد، ويبقى بناء الويب
// (عبر lib/main.dart) سليماً دون أي تأثير.
//
// أمر البناء:
//   flutter build apk --release -t lib/main_webview.dart
import 'package:flutter/material.dart';

import 'package:nesab_dashboard/app/mobile_webview/dashboard_webview_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DashboardWebViewApp());
}
