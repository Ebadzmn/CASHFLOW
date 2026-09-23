import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../auth/auth_controller.dart';
import 'splash_controller.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final SplashController controller = Get.find<SplashController>();

  @override
  void initState() {
    super.initState();
    // Use the AuthController to check where to go on app start.
    // This centrally manages the splash screen delay and logic.
    Get.find<AuthController>().checkAuthStatus();
  }

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
          
          // Center Content
          Center(
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                // color: const Color(0xFF1A2138), // Dark blue card color
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Center(
                child: Image.asset(
                  'assets/images/cashflow.png',
                  width: 150,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
