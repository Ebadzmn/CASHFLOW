import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/glass_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../routes/app_routes.dart';
import 'signup_controller.dart';

class SignupPage extends GetView<SignupController> {
  const SignupPage({super.key});

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
                            'Create Your Account',
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
                              // Full Name
                              const Text(
                                'Full Name',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              GlassTextField(
                                controller: controller.nameController,
                                hintText: 'Enter your full name',
                              ),

                              const SizedBox(height: 16),

                              // Contact Number
                              const Text(
                                'Contact Number',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              GlassTextField(
                                controller: controller.contactController,
                                hintText: 'Enter your contact number',
                                keyboardType: TextInputType.phone,
                              ),

                              const SizedBox(height: 16),

                              // Email
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
                                keyboardType: TextInputType.emailAddress,
                              ),

                              const SizedBox(height: 16),

                              // Create Password
                              const Text(
                                'Create Password',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Obx(
                                () => GlassTextField(
                                  controller: controller.passwordController,
                                  hintText: 'Enter your password',
                                  isPassword: true,
                                  isPasswordVisible:
                                      controller.isPasswordVisible.value,
                                  onTogglePassword:
                                      controller.togglePasswordVisibility,
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Confirm Password
                              const Text(
                                'Confirm Password',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Obx(
                                () => GlassTextField(
                                  controller:
                                      controller.confirmPasswordController,
                                  hintText: 'Re-enter your password',
                                  isPassword: true,
                                  isPasswordVisible:
                                      controller.isConfirmPasswordVisible.value,
                                  onTogglePassword: controller
                                      .toggleConfirmPasswordVisibility,
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Terms and Conditions Checkbox
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Obx(
                                    () => SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: Checkbox(
                                        value: controller.termsAccepted.value,
                                        onChanged: (value) =>
                                            controller.toggleTerms(),
                                        fillColor:
                                            MaterialStateProperty.resolveWith(
                                              (states) =>
                                                  states.contains(
                                                    MaterialState.selected,
                                                  )
                                                  ? Colors.white
                                                  : Colors.white,
                                            ),
                                        checkColor: const Color(0xFF007ACC),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        side: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: RichText(
                                      text: TextSpan(
                                        text:
                                            'By creating an account or signing you agree to our ',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          height: 1.5,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: 'Terms and Conditions',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () {
                                                context.push(Routes.TERMS);
                                              },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 32),

                              // Sign Up Button
                              Obx(
                                () => PrimaryButton(
                                  text: 'Sign Up',
                                  isLoading: controller.isLoading.value,
                                  onPressed: controller.signUp,
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Already have an account? Login
                              Center(
                                child: RichText(
                                  text: TextSpan(
                                    text: "Already have an account? ",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'Login',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () =>
                                              context.push(Routes.LOGIN),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
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
