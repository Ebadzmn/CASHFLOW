import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/glass_text_field.dart';
import '../../../routes/app_routes.dart';
import 'login_controller.dart';

class LoginPage extends GetView<LoginController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:
          false, // Prevents background from resizing when keyboard opens
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
                            'Login to your Account',
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

                              const SizedBox(height: 20),

                              // Password Field
                              const Text(
                                'Password',
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

                              // Remember Me & Forgot Password
                              Row(
                                children: [
                                  Obx(
                                    () => SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: Checkbox(
                                        value: controller.rememberMe.value,
                                        onChanged: (value) =>
                                            controller.toggleRememberMe(),
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
                                  const Text(
                                    'Remember Me',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const Spacer(),
                                  TextButton(
                                    onPressed: () =>
                                        context.push(Routes.FORGOT_PASSWORD),
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: const Text(
                                      'Forget Password?',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        decoration: TextDecoration.underline,
                                        decorationColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 32),

                              // Login Button
                              Obx(
                                () => PrimaryButton(
                                  text: 'Log in',
                                  onPressed: controller.login,
                                  isLoading: controller.isLoading.value,
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Sign Up Link
                              Center(
                                child: RichText(
                                  text: TextSpan(
                                    text: "Don't have an account? ",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'Sign Up',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () =>
                                              context.push(Routes.SIGNUP),
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
