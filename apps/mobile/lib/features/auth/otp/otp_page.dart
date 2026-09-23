import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/primary_button.dart';
import 'otp_controller.dart';

class OtpPage extends GetView<OtpController> {
  const OtpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            // Background Image
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

            // Content
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  
                  // Header
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
                            'OTP Verification',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 40), // Balance the back button
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
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Description Text
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16.0),
                                child: Text(
                                  'Your OTP has been sent to your registered email address. Enter it below to continue.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    height: 1.5,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 32),

                              // OTP Input Fields
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: List.generate(
                                  6,
                                  (index) => SizedBox(
                                    width: 45,
                                    height: 50,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: TextField(
                                        controller: controller.otpControllers[index],
                                        focusNode: controller.otpFocusNodes[index],
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          LengthLimitingTextInputFormatter(1),
                                          FilteringTextInputFormatter.digitsOnly,
                                        ],
                                        onChanged: (value) {
                                          if (value.isNotEmpty) {
                                            if (index < 5) {
                                              FocusScope.of(context).requestFocus(controller.otpFocusNodes[index + 1]);
                                            } else {
                                              FocusScope.of(context).unfocus();
                                            }
                                          } else if (value.isEmpty && index > 0) {
                                            FocusScope.of(context).requestFocus(controller.otpFocusNodes[index - 1]);
                                          }
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

                              // Timer Text
                              Obx(() => Text(
                                'Code expires in: ${controller.timerText.value}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              )),

                              const SizedBox(height: 32),

                              // Verify Button
                              Obx(
                                () => PrimaryButton(
                                  text: controller.isLoading.value
                                      ? 'Verifying...'
                                      : 'Verify',
                                  onPressed: controller.isLoading.value
                                      ? () {}
                                      : () => controller.verifyOtp(context),
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Resend Code
                              Center(
                                child: RichText(
                                  text: TextSpan(
                                    text: "Don't receive any code? ",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'Resend',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = controller.resendOtp,
                                      ),
                                    ],
                                  ),
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
    );
  }
}
