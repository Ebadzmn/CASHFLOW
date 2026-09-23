import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/network_exception.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../routes/app_router.dart';
import '../../../routes/app_routes.dart';

class ChangePasswordController extends GetxController {
  ChangePasswordController({
    this.email = '',
    this.resetToken = '',
    this.oneTimeCode = 0,
    this.isResetFlow = false,
  });

  final String email;
  final String resetToken;
  final int oneTimeCode;
  final bool isResetFlow;

  final AuthRepository _authRepository = AuthRepository();

  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isOldPasswordVisible = false.obs;
  final isNewPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;
  final isLoading = false.obs;

  void toggleOldPasswordVisibility() => isOldPasswordVisible.toggle();
  void toggleNewPasswordVisibility() => isNewPasswordVisible.toggle();
  void toggleConfirmPasswordVisibility() => isConfirmPasswordVisible.toggle();



  Future<void> savePassword() async {
    final oldPassword = oldPasswordController.text.trim();
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (!isResetFlow && oldPassword.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your old password',
        colorText: Colors.white,
        backgroundColor: Colors.red.withOpacity(0.8),
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (newPassword.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a new password',
        colorText: Colors.white,
        backgroundColor: Colors.red.withOpacity(0.8),
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (newPassword.length < 6) {
      Get.snackbar(
        'Error',
        'Password must be at least 6 characters long',
        colorText: Colors.white,
        backgroundColor: Colors.red.withOpacity(0.8),
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (newPassword != confirmPassword) {
      Get.snackbar(
        'Error',
        'New password and confirm password do not match',
        colorText: Colors.white,
        backgroundColor: Colors.red.withOpacity(0.8),
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    try {
      if (isResetFlow) {
        // Reset password flow from Forgot Password
        final response = await _authRepository.resetPassword(
          resetToken: resetToken,
          newPassword: newPassword,
          confirmPassword: confirmPassword,
        );

        if (response.success) {
          Get.snackbar(
            'Success',
            response.message.isNotEmpty
                ? response.message
                : 'Your password has been successfully reset.',
            colorText: Colors.white,
            backgroundColor: Colors.green,
            snackPosition: SnackPosition.BOTTOM,
          );
          AppRouter.router.go(Routes.LOGIN);
        } else {
          Get.snackbar(
            'Error',
            response.message.isNotEmpty
                ? response.message
                : 'Failed to reset password',
            colorText: Colors.white,
            backgroundColor: Colors.red.withOpacity(0.8),
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else {
        // Change password from Settings/Profile
        final response = await _authRepository.changePassword(
          currentPassword: oldPassword,
          newPassword: newPassword,
        );

        if (response.success) {
          Get.snackbar(
            'Success',
            response.message.isNotEmpty
                ? response.message
                : 'Password changed successfully',
            colorText: Colors.white,
            backgroundColor: Colors.green,
            snackPosition: SnackPosition.BOTTOM,
          );
          Get.back();
        } else {
          Get.snackbar(
            'Error',
            response.message.isNotEmpty
                ? response.message
                : 'Failed to change password',
            colorText: Colors.white,
            backgroundColor: Colors.red.withOpacity(0.8),
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }
    } on NetworkException catch (e) {
      Get.snackbar(
        'Error',
        e.message,
        colorText: Colors.white,
        backgroundColor: Colors.red.withOpacity(0.8),
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      Get.snackbar(
        'Error',
        'An error occurred. Please try again.',
        colorText: Colors.white,
        backgroundColor: Colors.red.withOpacity(0.8),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}

