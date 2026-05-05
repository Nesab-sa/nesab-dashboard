import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FCMService {
  static final FCMService _instance = FCMService._internal();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  FCMService._internal();

  factory FCMService() {
    return _instance;
  }

  /// Initialize Firebase Cloud Messaging and save token to Firestore
  Future<void> initialize() async {
    try {
      // Request notification permissions for iOS
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        // Get initial FCM token and save to Firestore
        final token = await _firebaseMessaging.getToken();
        if (token != null) {
          await _saveTokenToFirestore(token);
        }

        // Listen for token refresh and update in Firestore
        _firebaseMessaging.onTokenRefresh.listen((newToken) {
          _saveTokenToFirestore(newToken);
        });
      }
    } catch (e) {
      print('Error initializing FCM: $e');
    }
  }

  /// Save FCM token to Firestore under users/{uid}/fcmToken
  Future<void> _saveTokenToFirestore(String token) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .set(
              {'fcmToken': token},
              SetOptions(merge: true),
            );
      }
    } catch (e) {
      print('Error saving FCM token to Firestore: $e');
    }
  }
}
