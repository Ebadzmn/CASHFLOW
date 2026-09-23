import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/glass_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../controllers/add_transaction_controller.dart';

class AddTransactionModal extends StatelessWidget {
  const AddTransactionModal({super.key});

  AddTransactionController get _controller =>
      Get.isRegistered<AddTransactionController>()
      ? Get.find<AddTransactionController>()
      : Get.put(AddTransactionController());

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Dialog(
        backgroundColor: const Color(0xFF1F2937),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(
                () => Text(
                  controller.titleLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _buildSegmentButton('Income', 0),
                  const SizedBox(width: 12),
                  _buildSegmentButton('Expense', 1),
                  const SizedBox(width: 12),
                  _buildSegmentButton('Bank Transaction', 2),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Amount',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 4),
              GlassTextField(
                controller: controller.amountController,
                hintText: '\$ 0.00',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              Obx(() {
                if (controller.selectedType.value == 2) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bank Name',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      GlassTextField(
                        controller: controller.bankNameController,
                        hintText: 'e.g. Chase, Wells Fargo',
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Account Number (Last 4)',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      GlassTextField(
                        controller: controller.accountNumberController,
                        hintText: '1234',
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Reference ID',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      GlassTextField(
                        controller: controller.refIdController,
                        hintText: 'Transaction reference ID',
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Date',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      GlassTextField(
                        controller: controller.dateController,
                        hintText: 'YYYY-MM-DD',
                        readOnly: true,
                        onTap: () => controller.pickDate(context),
                      ),
                      const SizedBox(height: 12),
                    ],
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Category',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.5),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withOpacity(0.15),
                            Colors.white.withOpacity(0.05),
                          ],
                        ),
                      ),
                      child: Obx(
                        () => DropdownButtonFormField<String>(
                          value: controller.selectedCategory.value,
                          dropdownColor: const Color(0xFF1F2937),
                          iconEnabledColor: Colors.white70,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 18,
                            ),
                          ),
                          hint: Text(
                            'Select category',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 14,
                            ),
                          ),
                          items: controller.categories
                              .map(
                                (category) => DropdownMenuItem<String>(
                                  value: category,
                                  child: Text(
                                    category,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: controller.setCategory,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Description',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    GlassTextField(
                      controller: controller.descriptionController,
                      hintText: 'Optional note or description',
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Date',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    GlassTextField(
                      controller: controller.dateController,
                      hintText: 'YYYY-MM-DD',
                      readOnly: true,
                      onTap: () => controller.pickDate(context),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Image',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Obx(
                      () => GestureDetector(
                        onTap: controller.pickImage,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.image_outlined,
                                  color: Colors.black,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  controller.selectedImage.value?.name ??
                                      'Pick an image (optional)',
                                  style: TextStyle(
                                    color:
                                        controller.selectedImage.value == null
                                        ? Colors.white54
                                        : Colors.white,
                                    fontSize: 13,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (controller.selectedImage.value != null)
                                TextButton(
                                  onPressed: controller.removeImage,
                                  child: const Text('Remove'),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
              const SizedBox(height: 20),
              Obx(
                () => PrimaryButton(
                  text: controller.submitButtonLabel,
                  isLoading: controller.isSubmitting.value,
                  onPressed: controller.isSubmitting.value
                      ? null
                      : () async {
                          final result = await controller.submitTransaction();
                          if (!context.mounted) {
                            return;
                          }

                          if (result.success) {
                            final messenger = ScaffoldMessenger.maybeOf(
                              context,
                            );
                            Get.back();

                            if (messenger != null) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text(result.message),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              });
                            } else {
                              Get.snackbar(
                                'Success',
                                result.message,
                                backgroundColor: Colors.green,
                                colorText: Colors.white,
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            }
                          } else {
                            Get.snackbar(
                              'Error',
                              result.message,
                              backgroundColor: Colors.redAccent,
                              colorText: Colors.white,
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          }
                        },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentButton(String text, int index) {
    final controller = _controller;

    return Expanded(
      child: Obx(() {
        final isSelected = controller.selectedType.value == index;
        return GestureDetector(
          onTap: () => controller.setType(index),
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.black
                  : Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.50)
                    : Colors.white.withValues(alpha: 0.30),
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        );
      }),
    );
  }
}
