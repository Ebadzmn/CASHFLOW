import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/network/network_exception.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../routes/app_router.dart';
import '../../../routes/app_routes.dart';

class VerifyEmailController extends GetxController {
  VerifyEmailController({required this.email});

  final String email;
  final AuthRepository _authRepository = AuthRepository();

  final List<TextEditingController> otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> otpFocusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );

  final RxBool isLoading = false.obs;



  String get otp => otpControllers.map((controller) => controller.text).join();

  void clearOtp() {
    for (final controller in otpControllers) {
      controller.clear();
    }
    FocusScope.of(Get.context!).requestFocus(otpFocusNodes.first);
  }

  Future<void> verifyEmail() async {
    final code = otp.trim();

    if (email.trim().isEmpty) {
      _showError('Email is required. Please sign up again.');
      AppRouter.router.go(Routes.SIGNUP);
      return;
    }

    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      _showError('Please enter a valid 6-digit OTP');
      return;
    }

    final oneTimeCode = int.parse(code);

    isLoading.value = true;

    try {
      final response = await _authRepository.verifyEmail(
        email: email.trim(),
        oneTimeCode: oneTimeCode,
      );

      if (response.success) {
        Get.snackbar(
          'Success',
          response.message.isNotEmpty
              ? response.message
              : 'Email verified successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        AppRouter.router.go(Routes.LOGIN);
        return;
      }

      _showError(
        response.message.isNotEmpty
            ? response.message
            : 'Verification failed, try again',
      );
    } on NetworkException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Verification failed, try again');
    } finally {
      isLoading.value = false;
    }
  }

  void onOtpChanged(String value, int index) {
    if (value.isNotEmpty && index < otpFocusNodes.length - 1) {
      FocusScope.of(Get.context!).requestFocus(otpFocusNodes[index + 1]);
    } else if (value.isEmpty && index > 0) {
      FocusScope.of(Get.context!).requestFocus(otpFocusNodes[index - 1]);
    } else if (index == otpFocusNodes.length - 1) {
      FocusScope.of(Get.context!).unfocus();
    }
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
