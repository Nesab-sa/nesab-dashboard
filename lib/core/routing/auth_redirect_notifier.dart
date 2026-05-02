import 'package:flutter/foundation.dart';

/// Notifier for GoRouter to refresh redirect when auth state changes.
class AuthRedirectNotifier extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  void setAuthenticated(bool value) {
    if (_isAuthenticated != value) {
      _isAuthenticated = value;
      notifyListeners();
    }
  }
}
