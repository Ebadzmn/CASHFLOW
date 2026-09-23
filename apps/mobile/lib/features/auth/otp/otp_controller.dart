import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../../core/network/network_exception.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../routes/app_routes.dart';

class OtpController extends GetxController {
  OtpController({this.email = ''});

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

  final timerText = '02:59'.obs;
  final RxBool isLoading = false.obs;
  Timer? _timer;
  int _start = 179; // 2 minutes 59 seconds

  @override
  void onInit() {
    super.onInit();
    startTimer();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          timer.cancel();
        } else {
          _start--;
          int minutes = _start ~/ 60;
          int seconds = _start % 60;
          timerText.value = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
        }
      },
    );
  }

  String get otpCode => otpControllers.map((e) => e.text).join();

  Future<void> verifyOtp(BuildContext context) async {
    String otp = otpCode.trim();
    if (!RegExp(r'^\d{6}$').hasMatch(otp)) {
      Get.snackbar(
        'Error',
        'Please enter a complete 6-digit OTP',
        colorText: Colors.white,
        backgroundColor: Colors.red.withOpacity(0.8),
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (email.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Email address not found. Please try again.',
        colorText: Colors.white,
        backgroundColor: Colors.red.withOpacity(0.8),
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final oneTimeCode = int.tryParse(otp) ?? 0;
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
          colorText: Colors.white,
          backgroundColor: Colors.green,
          snackPosition: SnackPosition.BOTTOM,
        );

        final resetToken = response.token ?? '';

        if (context.mounted) {
          context.push(
            Routes.CHANGE_PASSWORD,
            extra: {
              'email': email.trim(),
              'resetToken': resetToken,
              'oneTimeCode': oneTimeCode,
              'isResetFlow': true,
            },
          );
        }
      } else {
        Get.snackbar(
          'Error',
          response.message.isNotEmpty
              ? response.message
              : 'Verification failed. Please try again.',
          colorText: Colors.white,
          backgroundColor: Colors.red.withOpacity(0.8),
          snackPosition: SnackPosition.BOTTOM,
        );
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
        'Verification failed. Please try again.',
        colorText: Colors.white,
        backgroundColor: Colors.red.withOpacity(0.8),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendOtp() async {
    if (email.isEmpty) {
      Get.snackbar(
        'Error',
        'Email address not found',
        colorText: Colors.white,
        backgroundColor: Colors.red.withOpacity(0.8),
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      final response = await _authRepository.forgotPassword(email);
      if (response.success) {
        _start = 179;
        timerText.value = '02:59';
        _timer?.cancel();
        startTimer();
        Get.snackbar(
          'Success',
          response.message.isNotEmpty
              ? response.message
              : 'OTP resent successfully',
          colorText: Colors.white,
          backgroundColor: Colors.green,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Error',
          response.message.isNotEmpty ? response.message : 'Failed to resend OTP',
          colorText: Colors.white,
          backgroundColor: Colors.red.withOpacity(0.8),
          snackPosition: SnackPosition.BOTTOM,
        );
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
        'Failed to resend OTP. Please try again.',
        colorText: Colors.white,
        backgroundColor: Colors.red.withOpacity(0.8),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}

