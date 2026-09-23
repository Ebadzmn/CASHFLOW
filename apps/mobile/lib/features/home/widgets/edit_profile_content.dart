import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/widgets/glass_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../profile/profile_controller.dart';

class EditProfileContent extends GetView<ProfileController> {
  const EditProfileContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
                      'Edit profile',
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
            const SizedBox(height: 30),
            Expanded(
              child: Obx(
                () => ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Stack(
                              children: [
                                _buildProfileImage(context),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () => controller
                                        .showImageSourceOptions(context),
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
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Center(
                            child: TextButton.icon(
                              onPressed: () =>
                                  controller.showImageSourceOptions(context),
                              icon: const Icon(
                                Icons.photo_library_outlined,
                                color: Colors.white,
                              ),
                              label: Text(
                                'Change image',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                          Text(
                            'Name',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          GlassTextField(
                            controller: controller.nameController,
                            hintText: 'Enter your name',
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Note',
                            style: GoogleFonts.outfit(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Name and image are sent as multipart form-data. You can update either one.',
                            style: GoogleFonts.outfit(
                              color: Colors.white60,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                          const Spacer(),
                          PrimaryButton(
                            text: 'Save',
                            isLoading: controller.isLoading.value,
                            onPressed: controller.isLoading.value
                                ? null
                                : () async {
                                    final success =
                                        await controller.updateProfile();
                                    if (success && context.mounted) {
                                      context.pop();
                                    }
                                  },
                            borderRadius: 12,
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage(BuildContext context) {
    final selectedImagePath = controller.selectedImagePath;
    final profileImageUrl = controller.profileImageUrl;

    final ImageProvider<Object> imageProvider = selectedImagePath != null
      ? FileImage(File(selectedImagePath))
      : profileImageUrl != null
        ? NetworkImage(profileImageUrl)
        : const AssetImage('assets/images/profile_placeholder.png');

    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
        border: Border.all(color: Colors.white24, width: 4),
      ),
      child: selectedImagePath == null && profileImageUrl == null
          ? const Icon(
              Icons.person,
              color: Colors.white,
              size: 56,
            )
          : null,
    );
  }
}
