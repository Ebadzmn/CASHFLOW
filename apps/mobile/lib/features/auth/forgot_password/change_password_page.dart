import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/widgets/glass_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import 'change_password_controller.dart';

class ChangePasswordPage extends GetView<ChangePasswordController> {
  const ChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
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
                      Expanded(
                        child: Text(
                          'Set New Password',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
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
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 40),
                          Text(
                            'Choose a New Password',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Enter and confirm your new password to regain access',
                            style: GoogleFonts.outfit(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Old Password (only when changing password from inside profile, not during reset)
                          if (!controller.isResetFlow) ...[
                            _buildLabel('Old Password'),
                            const SizedBox(height: 8),
                            Obx(
                              () => GlassTextField(
                                controller: controller.oldPasswordController,
                                hintText: 'Enter your old password',
                                isPassword: true,
                                isPasswordVisible:
                                    controller.isOldPasswordVisible.value,
                                onTogglePassword:
                                    controller.toggleOldPasswordVisibility,
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],

                          // New Password
                          _buildLabel('New Password'),
                          const SizedBox(height: 8),
                          Obx(
                            () => GlassTextField(
                              controller: controller.newPasswordController,
                              hintText: 'Enter your new password',
                              isPassword: true,
                              isPasswordVisible:
                                  controller.isNewPasswordVisible.value,
                              onTogglePassword:
                                  controller.toggleNewPasswordVisibility,
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Confirm Password
                          _buildLabel('Confirm Password'),
                          const SizedBox(height: 8),
                          Obx(
                            () => GlassTextField(
                              controller: controller.confirmPasswordController,
                              hintText: 'Re-enter your new password',
                              isPassword: true,
                              isPasswordVisible:
                                  controller.isConfirmPasswordVisible.value,
                              onTogglePassword:
                                  controller.toggleConfirmPasswordVisibility,
                            ),
                          ),

                          const SizedBox(height: 80), // Space for button
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Button
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: Obx(
              () => PrimaryButton(
                text: controller.isLoading.value ? 'Saving...' : 'Save',
                onPressed: controller.isLoading.value
                    ? () {}
                    : () => controller.savePassword(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.outfit(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
