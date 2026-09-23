import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../core/services/secure_storage_service.dart';
import '../../../core/services/chat_socket_service.dart';
import '../../profile/profile_controller.dart';
import '../../../routes/app_routes.dart';
import '../../../routes/app_router.dart';

class LoginController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();
  final SecureStorageService _storageService = SecureStorageService();
  final ProfileController _profileController = Get.find<ProfileController>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool rememberMe = false.obs;
  final RxBool isPasswordVisible = false.obs;



  void toggleRememberMe() {
    rememberMe.value = !rememberMe.value;
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter both email and password',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    try {
      final response = await _authRepository.login(email, password);

      if (response.success && response.data != null) {
        await _storageService.saveTokens(
          accessToken: response.data!.accessToken,
          refreshToken: response.data!.refreshToken,
        );

        try {
          await _profileController.fetchProfile(showLoading: false);
          await _profileController.checkSubscriptionStatus();
        } catch (_) {}

        if (Get.isRegistered<ChatSocketService>()) {
          await Get.find<ChatSocketService>().connect();
        }

        Get.snackbar(
          'Success',
          response.message,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );

        // Navigate to Home
        AppRouter.router.go(Routes.HOME);
      } else {
        Get.snackbar(
          'Error',
          response.message,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
