import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../../routes/app_routes.dart';
import '../home_controller.dart';
import '../../auth/auth_controller.dart';
import '../../profile/profile_controller.dart';

class SettingsContent extends GetView<HomeController> {
  const SettingsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Header
            Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () => controller.changeTabIndex(0),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Settings',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 48), // To balance the back button
              ],
            ),
            const SizedBox(height: 16),
            // Glassmorphic Card
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        // Profile Section
                        GetX<ProfileController>(
                          builder: (profileController) {
                            final profile = profileController.userProfile.value;
                            final imageUrl = profileController.profileImageUrl;

                            return Row(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: imageUrl != null
                                        ? DecorationImage(
                                            image: NetworkImage(imageUrl),
                                            fit: BoxFit.cover,
                                          )
                                        : const DecorationImage(
                                            image: AssetImage(
                                              'assets/images/profile_placeholder.png',
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                    border: Border.all(
                                      color: Colors.white24,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      profileController.isLoading.value
                                          ? 'Fetching profile...'
                                          : (profile?.name.isNotEmpty == true
                                                ? profile!.name
                                                : 'User'),
                                      style: GoogleFonts.outfit(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      profile?.email.isNotEmpty == true
                                          ? profile!.email
                                          : 'No email available',
                                      style: GoogleFonts.outfit(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 50),
                        // Settings Items
                        _buildSettingsItem(
                          icon: Icons.workspace_premium_outlined,
                          title: 'Premium Plans',
                          subtitle: 'Purchase your new plan',
                          onTap: () => context.push(Routes.PREMIUM_PLANS),
                        ),
                        _buildSettingsItem(
                          icon: Icons.person_outline,
                          title: 'My profile',
                          subtitle: 'Manage your profile and account details.',
                          onTap: () => context.push(Routes.MY_PROFILE),
                        ),
                        _buildSettingsItem(
                          icon: Icons.lock_outline,
                          title: 'Change Password',
                          subtitle: 'Update your account security.',
                          onTap: () => context.push(Routes.CHANGE_PASSWORD),
                        ),
                        _buildSettingsItem(
                          icon: Icons.description_outlined,
                          title: 'Terms & Conditions',
                          subtitle: 'Read our terms and conditions carefully.',
                          onTap: () => context.push(Routes.TERMS),
                        ),
                        _buildSettingsItem(
                          icon: Icons.shield_outlined,
                          title: 'Privacy Policy',
                          subtitle:
                              'Learn how your information is collected and used.',
                          onTap: () => context.push(Routes.PRIVACY),
                        ),
                        const SizedBox(height: 20),
                        // Logout
                        _buildLogoutItem(context),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 80), // Space for bottom nav
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(
                      color: Colors.white60,
                      fontSize: 13,
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

  Widget _buildLogoutItem(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.find<AuthController>().confirmLogout(),
      child: Row(
        children: [
          const Icon(Icons.logout, color: Colors.redAccent, size: 28),
          const SizedBox(width: 20),
          Text(
            'Logout',
            style: GoogleFonts.outfit(
              color: Colors.redAccent,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
