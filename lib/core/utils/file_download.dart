/// تنزيل ملف نصي (CSV/JSON) من الداشبورد.
///
/// على الويب: تنزيل مباشر عبر المتصفح. على APK: يُرجع false
/// وتعرض الواجهة رسالة توجّه لاستخدام نسخة الويب.
export 'file_download_stub.dart' if (dart.library.js_interop) 'file_download_web.dart';
