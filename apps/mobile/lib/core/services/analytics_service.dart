import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class AnalyticsService extends GetxService {
  static AnalyticsService get to => Get.find();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  FirebaseAnalytics get analytics => _analytics;
  FirebaseCrashlytics get crashlytics => _crashlytics;

  /// Log custom event
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    try {
      await _analytics.logEvent(name: name, parameters: parameters);
      debugPrint('📊 Analytics Event Logged: $name | $parameters');
    } catch (e) {
      debugPrint('❌ Analytics logEvent error: $e');
    }
  }

  /// Set user identifier for Crashlytics & Analytics
  Future<void> setUserIdentifier(String userId) async {
    try {
      await _analytics.setUserId(id: userId);
      await _crashlytics.setUserIdentifier(userId);
      debugPrint('👤 Analytics & Crashlytics User ID set: $userId');
    } catch (e) {
      debugPrint('❌ setUserIdentifier error: $e');
    }
  }

  /// Record non-fatal error to Crashlytics
  Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    dynamic reason,
    Iterable<Object> information = const [],
    bool fatal = false,
  }) async {
    try {
      await _crashlytics.recordError(
        exception,
        stack,
        reason: reason,
        information: information,
        fatal: fatal,
      );
    } catch (e) {
      debugPrint('❌ Crashlytics recordError failed: $e');
    }
  }

  /// Log custom log message to Crashlytics report
  void logCrashlytics(String message) {
    _crashlytics.log(message);
  }
}
