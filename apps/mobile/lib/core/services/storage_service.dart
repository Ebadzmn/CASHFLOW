import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService extends GetxService {
  late SharedPreferences _prefs;

  static const String keyUserId = 'user_id';
  static const String keyName = 'name';
  static const String keyEmail = 'email';
  static const String keyRole = 'role';
  static const String keyImage = 'image';
  static const String keyPlan = 'plan';
  static const String keyIsSubscribed = 'is_subscribed';
  static const String keySubscribedProductId = 'subscribed_product_id';
  static const String keyVerified = 'verified';
  static const String keyHasSeenOnboarding = 'has_seen_onboarding';

  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  // Save User Data
  Future<void> saveUserData({
    required String userId,
    required String name,
    required String email,
    required String role,
    required String image,
    required String plan,
    required bool verified,
  }) async {
    await _prefs.setString(keyUserId, userId);
    await _prefs.setString(keyName, name);
    await _prefs.setString(keyEmail, email);
    await _prefs.setString(keyRole, role);
    await _prefs.setString(keyImage, image);
    await _prefs.setString(keyPlan, plan);
    await _prefs.setBool(keyVerified, verified);
  }

  Future<void> saveSubscriptionState({
    required bool isSubscribed,
    String? productId,
    String? plan,
  }) async {
    await _prefs.setBool(keyIsSubscribed, isSubscribed);
    if (productId == null || productId.isEmpty) {
      await _prefs.remove(keySubscribedProductId);
    } else {
      await _prefs.setString(keySubscribedProductId, productId);
    }

    if (plan != null && plan.isNotEmpty) {
      await _prefs.setString(keyPlan, plan);
    }
  }

  // Clear All Data
  Future<void> clearAll() async {
    await _prefs.clear();
  }

  // Getters
  String? getUserId() => _prefs.getString(keyUserId);
  String? getName() => _prefs.getString(keyName);
  String? getEmail() => _prefs.getString(keyEmail);
  String? getRole() => _prefs.getString(keyRole);
  String? getImage() => _prefs.getString(keyImage);
  String? getPlan() => _prefs.getString(keyPlan);
  bool isSubscribed() => _prefs.getBool(keyIsSubscribed) ?? false;
  String? getSubscribedProductId() => _prefs.getString(keySubscribedProductId);
  String? getActiveProductId() => _prefs.getString(keySubscribedProductId);
  bool? getVerified() => _prefs.getBool(keyVerified);

  bool hasSeenOnboarding() => _prefs.getBool(keyHasSeenOnboarding) ?? false;

  Future<void> setHasSeenOnboarding(bool value) async {
    await _prefs.setBool(keyHasSeenOnboarding, value);
  }
}
