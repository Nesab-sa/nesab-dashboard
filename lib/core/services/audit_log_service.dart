import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// سجل العمليات (Audit Log) — من/متى/ماذا غيّر.
///
/// يكتب في مجموعة `audit_log` (القواعد: إنشاء فقط — لا تعديل ولا حذف)،
/// ولا يُفشل العملية الأساسية أبداً إذا تعذرت الكتابة.
///
/// الأفعال المعتمدة (action): siteContent.save, header.save, maintenance.save,
/// seo.save, seo.clear, notification.send, notification.schedule,
/// notification.cancelSchedule, notification.cancelActive, notification.delete,
/// user.ban, user.unban, user.delete, users.export, tool.save, tool.delete.
class AuditLogService {
  AuditLogService._();

  static Future<void> log(
    String action, {
    String target = '',
    Map<String, dynamic>? details,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance.collection('audit_log').add({
        'action': action,
        'target': target,
        'details': details ?? const <String, dynamic>{},
        'admin': user?.email ?? 'unknown',
        'adminUid': user?.uid ?? '',
        'at': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // فشل تسجيل الأثر لا يجب أن يكسر العملية نفسها
    }
  }
}
