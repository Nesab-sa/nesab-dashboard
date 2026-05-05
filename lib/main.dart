import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nesab/app/app.dart';
import 'package:nesab/app/app_bloc_observer.dart';
import 'package:nesab/app/dependency_injection.dart';
import 'package:nesab/firebase_options.dart';
import 'package:nesab/core/services/fcm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Bloc.observer = AppBlocObserver();
  await configureDependencies();

  // Initialize Firebase Cloud Messaging for push notifications
  await FCMService().initialize();

  runApp(const App());
}
