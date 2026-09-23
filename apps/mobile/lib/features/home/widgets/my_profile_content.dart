import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../../routes/app_routes.dart';
import '../../auth/auth_controller.dart';
import '../../../core/widgets/primary_button.dart';
import '../../profile/profile_controller.dart';

class MyProfileContent extends GetView<ProfileController> {
  const MyProfileContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () => controller.fetchProfile(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () => context.pop(),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'My profile',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 30),
                ClipRRect(
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
                      child: Obx(() {
                        final profile = controller.userProfile.value;
                        final imageUrl = controller.profileImageUrl;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Stack(
                                children: [
                                  Container(
                                    width: 120,
                                    height: 120,
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
                                        width: 4,
                                      ),
                                    ),
                                    child: imageUrl == null
                                        ? const Icon(
                                            Icons.person,
                                            color: Colors.white,
                                            size: 48,
                                          )
                                        : null,
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0D1A2A),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white24,
                                          width: 2,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt_outlined,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 30),
                            _buildProfileField(
                              'Full Name',
                              profile?.name.isNotEmpty == true
                                  ? profile!.name
                                  : 'Not available',
                            ),
                            const SizedBox(height: 16),
                            _buildProfileField(
                              'Email',
                              profile?.email.isNotEmpty == true
                                  ? profile!.email
                                  : 'Not available',
                            ),
                            const SizedBox(height: 16),
                            _buildProfileField(
                              'Phone Number',
                              profile?.contact?.isNotEmpty == true
                                  ? profile!.contact!
                                  : 'Not available',
                            ),
                            const SizedBox(height: 16),
                            _buildProfileField(
                              'Plan',
                              profile?.plan.isNotEmpty == true
                                  ? profile!.plan
                                  : 'Not available',
                            ),
                            const SizedBox(height: 16),
                            _buildProfileField(
                              'Plan Expire Date',
                              profile?.expireDate?.isNotEmpty == true
                                  ? profile!.expireDate!
                                  : 'Not available',
                            ),
                            const SizedBox(height: 24),
                            if (controller.isLoading.value)
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.only(bottom: 16.0),
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            PrimaryButton(
                              text: 'Edit',
                              onPressed: () =>
                                  context.push(Routes.EDIT_PROFILE),
                              borderRadius: 12,
                            ),
                            const SizedBox(height: 12),
                            PrimaryButton(
                              text: 'Logout',
                              onPressed: () =>
                                  Get.find<AuthController>().confirmLogout(),
                              borderRadius: 12,
                              gradientColors: [
                                const Color(0xFFFF5252).withOpacity(0.3),
                                const Color(0xFFFF5252).withOpacity(0.1),
                              ],
                              isGlass: true,
                            ),
                            const SizedBox(height: 20),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(color: Colors.white60, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
