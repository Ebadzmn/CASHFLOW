import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/secure_storage_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/chat_socket_service.dart';
import '../profile/profile_controller.dart';
import '../../routes/app_routes.dart';
import '../../routes/app_router.dart';
import '../../core/network/api_client.dart';

class AuthController extends GetxController {
  final SecureStorageService _storageService = SecureStorageService();
  final StorageService _localStorageService = Get.find<StorageService>();
  final ProfileController _profileController = Get.find<ProfileController>();

  @override
  void onInit() {
    super.onInit();
    // Do NOT call checkAuthStatus here to avoid redundant or conflicting navigations
  }

  Future<void> checkAuthStatus() async {
    // Artificial delay for splash screen feel
    await Future.delayed(const Duration(seconds: 2));

    final hasSeenOnboarding = _localStorageService.hasSeenOnboarding();
    if (!hasSeenOnboarding) {
      AppRouter.router.go(Routes.ONBOARDING);
      return;
    }

    final hasToken = await _storageService.hasTokens();

    if (hasToken) {
      try {
        await _profileController.fetchProfile(showLoading: false);
        await _profileController.checkSubscriptionStatus();
        if (Get.isRegistered<ChatSocketService>()) {
          await Get.find<ChatSocketService>().connect();
        }
      } catch (_) {}
      AppRouter.router.go(Routes.HOME);
    } else {
      AppRouter.router.go(Routes.LOGIN);
    }
  }

  /// Shows a confirmation dialog before logging out
  void confirmLogout() {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1A2A3D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Logout',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white38),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              logout();
            },
            child: const Text(
              'Logout',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> logout() async {
    try {
      // 1. Clear singleton memory (removes header from current Dio instance)
      ApiClient.instance.clearToken();

      // 2. Clear secure storage
      await _storageService.clearTokens();

      // 3. Clear profile cache
      await _profileController.clearProfile();

      if (Get.isRegistered<ChatSocketService>()) {
        Get.find<ChatSocketService>().disconnect();
      }

      // 4. Navigate to Login
      AppRouter.router.go(Routes.LOGIN);

      Get.snackbar(
        'Success',
        'Logged out successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to logout',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
