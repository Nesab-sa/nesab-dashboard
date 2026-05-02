/// Centralized form validation rules for the Nesab app.
///
/// All validators return `null` when the input is valid, or an error key
/// that the caller can map to a localized message.
abstract class AppValidators {
  const AppValidators._();

  static const int passwordMinLength = 6;
  static const int nameMinLength = 2;

  /// Validates an email address.
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'emailRequired';
    final trimmed = value.trim();
    // Simple but effective email regex
    final regex = RegExp(r'^[\w\.\-\+]+@[\w\-]+\.[\w\-\.]+$');
    if (!regex.hasMatch(trimmed)) return 'emailInvalid';
    return null;
  }

  /// Validates a password.
  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'passwordRequired';
    if (value.length < passwordMinLength) return 'passwordTooShort';
    return null;
  }

  /// Validates a display name.
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) return 'nameRequired';
    if (value.trim().length < nameMinLength) return 'nameTooShort';
    return null;
  }

  /// Validates a required field (generic).
  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) return 'fieldRequired';
    return null;
  }
}
