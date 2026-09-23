import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/primary_button.dart';
import 'verify_email_controller.dart';

class VerifyEmailPage extends GetView<VerifyEmailController> {
  const VerifyEmailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/bg.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => context.pop(),
                            icon: const Icon(
                              Icons.arrow_back_ios,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const Expanded(
                            child: Text(
                              'Verify Email',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 40),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                        ),
                        child: Center(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0,
                                  ),
                                  child: Text(
                                    'We sent a 6-digit OTP to ${controller.email}. Enter it below to verify your email.',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 32),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: List.generate(
                                    6,
                                    (index) => SizedBox(
                                      width: 45,
                                      height: 50,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: TextField(
                                          controller:
                                              controller.otpControllers[index],
                                          focusNode:
                                              controller.otpFocusNodes[index],
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [
                                            LengthLimitingTextInputFormatter(1),
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                          ],
                                          onChanged: (value) {
                                            controller.onOtpChanged(
                                              value,
                                              index,
                                            );
                                          },
                                          decoration: const InputDecoration(
                                            border: InputBorder.none,
                                            counterText: '',
                                            contentPadding: EdgeInsets.zero,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Obx(
                                  () => PrimaryButton(
                                    text: controller.isLoading.value
                                        ? 'Verifying...'
                                        : 'Verify',
                                    onPressed: controller.verifyEmail,
                                    isLoading: controller.isLoading.value,
                                    child: controller.isLoading.value
                                        ? const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              SizedBox(
                                                height: 18,
                                                width: 18,
                                                child:
                                                    CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2,
                                                    ),
                                              ),
                                              SizedBox(width: 12),
                                              Text(
                                                'Verifying...',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          )
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
