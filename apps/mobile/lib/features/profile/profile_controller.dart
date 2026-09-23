import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'dart:io';

import '../../core/network/api_endpoints.dart';
import '../../core/network/network_exception.dart';
import '../../core/services/storage_service.dart';
import '../../data/models/profile_response.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/subscription_repository.dart';

class ProfileController extends GetxService {
  final AuthRepository _authRepository = AuthRepository();
  final ImagePicker _imagePicker = ImagePicker();

  final Rxn<ProfileData> userProfile = Rxn<ProfileData>();
  final RxBool isLoading = false.obs;
  final TextEditingController nameController = TextEditingController();
  final Rxn<XFile> selectedImage = Rxn<XFile>();

  bool get isPremiumUser {
    final fromBackend = userProfile.value?.isPremiumUser ?? false;
    if (fromBackend) return true;
    if (Get.isRegistered<StorageService>()) {
      return Get.find<StorageService>().isSubscribed();
    }
    return false;
  }

  /// Calls backend `/subscription/status` to verify current subscription state
  /// and updates local storage accordingly.
  Future<void> checkSubscriptionStatus() async {
    try {
      final subRepo = SubscriptionRepository();
      final status = await subRepo.getSubscriptionStatus();
      final isSubbed = status.data?.premium ?? false;

      if (Get.isRegistered<StorageService>()) {
        await Get.find<StorageService>().saveSubscriptionState(
          isSubscribed: isSubbed,
        );
      }
    } catch (e) {
      Get.log('Failed to check subscription status: $e');
    }
  }

  Future<void> prepareEditProfile() async {
    if (userProfile.value == null) {
      try {
        await fetchProfile(showLoading: false);
      } catch (_) {
        // Keep the editor usable even if the refresh fails.
      }
    }

    nameController.text = userProfile.value?.name ?? '';
    selectedImage.value = null;
  }

  Future<void> showImageSourceOptions(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1F2937),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera, color: Colors.white),
                title: const Text(
                  'Take Photo',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  unawaited(_pickImage(ImageSource.camera));
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.white),
                title: const Text(
                  'Choose from Gallery',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  unawaited(_pickImage(ImageSource.gallery));
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (image != null) {
        selectedImage.value = image;
      }
    } catch (error) {
      Get.snackbar(
        'Failed to pick image',
        'Unable to access the image picker.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.log('Profile image pick failed: $error');
    }
  }

  Future<void> fetchProfile({bool showLoading = true}) async {
    if (showLoading) {
      isLoading.value = true;
    }

    try {
      final response = await _authRepository.getProfile();
      if (response.success && response.data != null) {
        userProfile.value = response.data;
        if (nameController.text.isEmpty) {
          nameController.text = response.data!.name;
        }
        return;
      }

      throw NetworkException(
        message: response.message.isNotEmpty
            ? response.message
            : 'Failed to load profile',
      );
    } on NetworkException catch (e) {
      if (showLoading) {
        Get.snackbar(
          'Error',
          e.message,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      rethrow;
    } finally {
      if (showLoading) {
        isLoading.value = false;
      }
    }
  }

  String? get profileImageUrl {
    final image = userProfile.value?.image.trim();
    if (image == null || image.isEmpty) {
      return null;
    }

    if (image.startsWith('http://') || image.startsWith('https://')) {
      return image;
    }

    return '${ApiEndpoints.baseUrl}$image';
  }

  String? get selectedImagePath => selectedImage.value?.path;

  Future<bool> updateProfile() async {
    final trimmedName = nameController.text.trim();
    final image = selectedImage.value;

    if (trimmedName.isEmpty && image == null) {
      Get.snackbar(
        'Validation error',
        'Please enter a name or choose a new image.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    isLoading.value = true;

    try {
      final response = await _authRepository.updateProfile(
        name: trimmedName,
        image: image == null ? null : File(image.path),
      );

      if (!response.success) {
        throw NetworkException(
          message: response.message.isNotEmpty
              ? response.message
              : 'Failed to update profile',
        );
      }

      await fetchProfile(showLoading: false);
      nameController.text = userProfile.value?.name ?? trimmedName;
      selectedImage.value = null;

      Get.snackbar(
        'Success',
        response.message.isNotEmpty
            ? response.message
            : 'Profile updated successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } on NetworkException catch (e) {
      Get.snackbar(
        'Error',
        e.message,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } catch (error) {
      Get.log('Profile update failed: $error');
      Get.snackbar(
        'Error',
        'Failed to update profile',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> clearProfile() async {
    userProfile.value = null;
    isLoading.value = false;
    nameController.clear();
    selectedImage.value = null;
    if (Get.isRegistered<StorageService>()) {
      await Get.find<StorageService>().saveSubscriptionState(
        isSubscribed: false,
      );
    }
  }

}
