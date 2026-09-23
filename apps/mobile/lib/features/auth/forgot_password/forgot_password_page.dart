import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/glass_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import 'forgot_password_controller.dart';

class ForgotPasswordPage extends GetView<ForgotPasswordController> {
  const ForgotPasswordPage({super.key});

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
                            'Forgot Password',
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Description Text
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16.0),
                                child: Text(
                                  'Don\'t worry. Enter your email and we\'ll send you a verification code to reset your password.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    height: 1.5,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 48),

                              // Email Field
                              const Text(
                                'Email',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              GlassTextField(
                                controller: controller.emailController,
                                hintText: 'Enter your email',
                              ),

                              const SizedBox(height: 32),

                              // Continue Button
                              Obx(
                                () => PrimaryButton(
                                  text: controller.isLoading.value
                                      ? 'Sending...'
                                      : 'Continue',
                                  onPressed: controller.isLoading.value
                                      ? () {}
                                      : () => controller.submitEmail(context),
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
