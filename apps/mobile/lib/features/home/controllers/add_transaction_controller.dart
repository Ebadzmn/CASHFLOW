import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../core/network/network_exception.dart';
import '../../../data/repositories/income_repository.dart';
import '../home_controller.dart';
import 'stats_controller.dart';
import 'transaction_controller.dart';

class IncomeSubmitResult {
  final bool success;
  final String message;

  const IncomeSubmitResult({required this.success, required this.message});
}

class AddTransactionController extends GetxController {
  final IncomeRepository _incomeRepository = IncomeRepository();
  final ImagePicker _imagePicker = ImagePicker();

  final selectedType = 0.obs;
  final selectedCategory = RxnString();
  final selectedDate = Rxn<DateTime>();
  final selectedImage = Rxn<XFile>();
  final isSubmitting = false.obs;

  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController bankNameController = TextEditingController();
  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController refIdController = TextEditingController();
  final List<String> categories = const [
    'Salary',
    'Freelance',
    'Business',
    'Investment',
    'Gift',
    'Refund',
    'Other',
  ];

  void setType(int type) {
    selectedType.value = type;
  }

  String get titleLabel {
    if (selectedType.value == 0) {
      return 'Add Income';
    }
    if (selectedType.value == 1) {
      return 'Add Expense';
    }
    return 'Add Bank Transaction';
  }

  String get submitButtonLabel {
    if (selectedType.value == 0) {
      return 'Submit Income';
    }
    if (selectedType.value == 1) {
      return 'Submit Expense';
    }
    return 'Submit Bank Transaction';
  }

  void setCategory(String? category) {
    selectedCategory.value = category;
  }

  Future<void> pickDate(BuildContext context) async {
    final initialDate = selectedDate.value ?? DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null) {
      return;
    }

    selectedDate.value = pickedDate;
    dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
  }

  Future<void> pickImage() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        selectedImage.value = image;
      }
    } on MissingPluginException catch (_) {
      Get.snackbar(
        'Image Picker Unavailable',
        'Please fully stop and rerun the app after installing the image picker plugin.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } on PlatformException catch (error) {
      Get.snackbar(
        'Failed to pick image',
        error.message ?? 'Unable to access the image picker on this device.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      Get.snackbar(
        'Failed to pick image',
        'Unable to access the image picker.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void removeImage() {
    selectedImage.value = null;
  }

  Future<IncomeSubmitResult> submitTransaction() async {
    final amount = amountController.text.trim();
    final date = selectedDate.value;
    final description = descriptionController.text.trim();

    if (selectedType.value == 2) {
      final bankName = bankNameController.text.trim();
      final accountNumber = accountNumberController.text.trim();
      final refId = refIdController.text.trim();
      final amountValue = num.tryParse(amount);

      if (amount.isEmpty) {
        return const IncomeSubmitResult(
          success: false,
          message: 'Amount is required',
        );
      }

      if (amountValue == null) {
        return const IncomeSubmitResult(
          success: false,
          message: 'Amount must be a number',
        );
      }

      if (bankName.isEmpty) {
        return const IncomeSubmitResult(
          success: false,
          message: 'Bank name is required',
        );
      }

      if (accountNumber.isEmpty) {
        return const IncomeSubmitResult(
          success: false,
          message: 'Account number is required',
        );
      }

      if (!RegExp(r'^\d{4}$').hasMatch(accountNumber)) {
        return const IncomeSubmitResult(
          success: false,
          message: 'Last 4 digits must be exactly 4 numbers',
        );
      }

      if (refId.isEmpty) {
        return const IncomeSubmitResult(
          success: false,
          message: 'Reference ID is required',
        );
      }

      if (date == null) {
        return const IncomeSubmitResult(
          success: false,
          message: 'Date is required',
        );
      }

      isSubmitting.value = true;

      try {
        final response = await _incomeRepository.createBankTransaction(
          body: {
            'amount': amountValue,
            'bankName': bankName,
            'accountNumberLast4Digits': accountNumber,
            'refId': refId,
            'date': DateTime.utc(
              date.year,
              date.month,
              date.day,
            ).toIso8601String(),
          },
        );

        final message = (response['message'] as String?)?.trim();
        clearForm();

        _refreshRelatedData();

        return IncomeSubmitResult(
          success: true,
          message: message?.isNotEmpty == true
              ? message!
              : 'Transaction added successfully',
        );
      } on NetworkException catch (error) {
        return IncomeSubmitResult(success: false, message: error.message);
      } catch (_) {
        return const IncomeSubmitResult(
          success: false,
          message: 'Failed to add transaction',
        );
      } finally {
        isSubmitting.value = false;
      }
    }

    final category = selectedCategory.value?.trim() ?? '';

    if (amount.isEmpty) {
      return const IncomeSubmitResult(
        success: false,
        message: 'Amount is required',
      );
    }

    if (category.isEmpty) {
      return const IncomeSubmitResult(
        success: false,
        message: 'Category is required',
      );
    }

    if (date == null) {
      return const IncomeSubmitResult(
        success: false,
        message: 'Date is required',
      );
    }

    isSubmitting.value = true;

    try {
      final payload = <String, String>{
        'amount': amount,
        'category': category,
        'date': DateFormat('yyyy-MM-dd').format(date),
        'description': description,
      };

      final imageFile = selectedImage.value == null
          ? null
          : File(selectedImage.value!.path);

      final response = selectedType.value == 0
          ? await _incomeRepository.createIncome(
              fields: payload,
              image: imageFile,
            )
          : await _incomeRepository.createExpense(
              fields: payload,
              image: imageFile,
            );

      final message = (response['message'] as String?)?.trim();
      clearForm();

      _refreshRelatedData();

      return IncomeSubmitResult(
        success: true,
        message: message?.isNotEmpty == true
            ? message!
            : (selectedType.value == 0
                  ? 'Income added successfully'
                  : 'Expense added successfully'),
      );
    } on NetworkException catch (error) {
      return IncomeSubmitResult(success: false, message: error.message);
    } catch (_) {
      return const IncomeSubmitResult(
        success: false,
        message: 'Failed to submit transaction',
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  void clearForm() {
    amountController.clear();
    descriptionController.clear();
    dateController.clear();
    bankNameController.clear();
    accountNumberController.clear();
    refIdController.clear();
    selectedCategory.value = null;
    selectedDate.value = null;
    selectedImage.value = null;
    selectedType.value = 0;
  }

  void _refreshRelatedData() {
    if (Get.isRegistered<HomeController>()) {
      unawaited(Get.find<HomeController>().refreshDashboard());
    }

    if (Get.isRegistered<TransactionController>()) {
      unawaited(Get.find<TransactionController>().fetchTransactions());
    }

    if (Get.isRegistered<StatsController>()) {
      unawaited(Get.find<StatsController>().fetchExpenseReport());
    }
  }


}
