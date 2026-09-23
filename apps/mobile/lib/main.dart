import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'app.dart';
import 'core/services/analytics_service.dart';
import 'core/services/chat_socket_service.dart';
import 'core/services/storage_service.dart';
import 'features/auth/auth_controller.dart';
import 'features/profile/profile_controller.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    final app = await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('🔥 Firebase Connected Successfully! Project ID: ${app.options.projectId}');

    // Pass all uncaught errors from the Flutter framework to Crashlytics
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };

    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  } catch (e, stackTrace) {
    debugPrint('❌ Firebase Initialization Failed: $e');
    debugPrint('Stack: $stackTrace');
  }

  // Initialize Persistent Services
  await Get.putAsync(() => StorageService().init());
  Get.put(AnalyticsService(), permanent: true);
  Get.put(ProfileController(), permanent: true);
  Get.put(ChatSocketService(), permanent: true);
  Get.put(AuthController());
  runApp(const App());
}


