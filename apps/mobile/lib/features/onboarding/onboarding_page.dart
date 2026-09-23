import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import '../../core/widgets/primary_button.dart';
import 'onboarding_controller.dart';

class OnboardingPage extends GetView<OnboardingController> {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg.png',
              fit: BoxFit.cover,
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),
                
                // Welcome Text
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    'Welcome to CashFlowIQ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Subtitle Text
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Text(
                    'Know where your money is going Know what\'s coming next Never walk into an audit alone again.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),

                const Spacer(flex: 3),

                // Illustration
                Expanded(
                  flex: 6,
                  child: Image.asset(
                    'assets/images/onboard.png',
                    fit: BoxFit.contain,
                  ),
                ),

                const Spacer(flex: 2),

                // Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      // Get Started Button
                      PrimaryButton(
                        text: 'Get Started',
                        onPressed: () {
                          controller.markOnboardingSeen();
                          context.go(Routes.SIGNUP);
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Login Button
                      PrimaryButton(
                        text: 'Login',
                        onPressed: () {
                          controller.markOnboardingSeen();
                          context.go(Routes.LOGIN);
                        },
                        isGlass: true,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 48),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
