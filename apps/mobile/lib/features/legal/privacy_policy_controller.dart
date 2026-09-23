import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/privacy_policy_response.dart';
import '../../data/repositories/legal_repository.dart';

class PrivacyPolicyController extends GetxController {
  final LegalRepository _legalRepository = LegalRepository();

  final privacyList = <PrivacyPolicyItem>[].obs;
  final selectedPrivacy = Rxn<PrivacyPolicyDetails>();
  final isLoading = false.obs;
  final detailsLoading = false.obs;
  final errorMessage = ''.obs;

  Future<void> loadPrivacyPolicies() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final items = await _legalRepository.getPrivacyPolicyList();
      privacyList.assignAll(items);
    } catch (error) {
      errorMessage.value = 'Failed to load privacy policy';
      Get.snackbar(
        'Error',
        'Failed to load privacy policy',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadPrivacyDetails(String id) async {
    if (id.isEmpty) {
      errorMessage.value = 'Failed to load details';
      return;
    }

    detailsLoading.value = true;
    errorMessage.value = '';

    try {
      final details = await _legalRepository.getPrivacyPolicyDetails(id);
      selectedPrivacy.value = details;
    } catch (error) {
      errorMessage.value = 'Failed to load details';
      Get.snackbar(
        'Error',
        'Failed to load details',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      detailsLoading.value = false;
    }
  }

  void clearSelectedPrivacy() {
    selectedPrivacy.value = null;
    detailsLoading.value = false;
  }
}