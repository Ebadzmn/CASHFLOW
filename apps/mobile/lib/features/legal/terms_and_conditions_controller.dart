import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/terms_conditions_response.dart';
import '../../data/repositories/legal_repository.dart';

class TermsAndConditionsController extends GetxController {
  final LegalRepository _legalRepository = LegalRepository();

  final termsList = <TermsConditionItem>[].obs;
  final selectedTerm = Rxn<TermsConditionDetails>();
  final isLoading = false.obs;
  final detailsLoading = false.obs;
  final errorMessage = ''.obs;

  Future<void> loadTerms() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final items = await _legalRepository.getTermsList();
      termsList.assignAll(items);
    } catch (error) {
      errorMessage.value = 'Failed to load terms';
      Get.snackbar(
        'Error',
        'Failed to load terms',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadTermDetails(String id) async {
    if (id.isEmpty) {
      errorMessage.value = 'Failed to load details';
      return;
    }

    detailsLoading.value = true;
    errorMessage.value = '';

    try {
      final details = await _legalRepository.getTermDetails(id);
      selectedTerm.value = details;
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

  void clearSelectedTerm() {
    selectedTerm.value = null;
    detailsLoading.value = false;
  }
}