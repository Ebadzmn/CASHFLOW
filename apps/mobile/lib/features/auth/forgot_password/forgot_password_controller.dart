import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../../core/network/network_exception.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../routes/app_routes.dart';

class ForgotPasswordController extends GetxController {
  final emailController = TextEditingController();
  final AuthRepository _authRepository = AuthRepository();
  final RxBool isLoading = false.obs;



  Future<void> submitEmail(BuildContext context) async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your email address',
        colorText: Colors.white,
        backgroundColor: Colors.red.withOpacity(0.8),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    isLoading.value = true;
    try {
      final response = await _authRepository.forgotPassword(email);
      if (response.success) {
        Get.snackbar(
          'Success',
          response.message.isNotEmpty
              ? response.message
              : 'Verification code sent to your email',
          colorText: Colors.white,
          backgroundColor: Colors.green,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
        if (context.mounted) {
          context.push(Routes.OTP, extra: email);
        }
      } else {
        Get.snackbar(
          'Error',
          response.message.isNotEmpty
              ? response.message
              : 'Failed to send verification code',
          colorText: Colors.white,
          backgroundColor: Colors.red.withOpacity(0.8),
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
      }
    } on NetworkException catch (e) {
      Get.snackbar(
        'Error',
        e.message,
        colorText: Colors.white,
        backgroundColor: Colors.red.withOpacity(0.8),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } catch (_) {
      Get.snackbar(
        'Error',
        'Failed to send reset email. Please try again.',
        colorText: Colors.white,
        backgroundColor: Colors.red.withOpacity(0.8),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isLoading.value = false;
    }
  }
}

