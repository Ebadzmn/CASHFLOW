import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/primary_button.dart';
import 'scan_receipt_controller.dart';

class ScanReceiptPage extends GetView<ScanReceiptController> {
  const ScanReceiptPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
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
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
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
                      const Expanded(
                        child: Text(
                          'Scan Receipt',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(
                          () => GestureDetector(
                            onTap: () =>
                                controller.showImageSourceOptions(context),
                            child: Container(
                              width: double.infinity,
                              height: 400,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  if (controller.selectedImage.value == null)
                                    Padding(
                                      padding: const EdgeInsets.all(24.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            'assets/images/cashflow.png',
                                            height: 170,
                                            fit: BoxFit.contain,
                                            color: Colors.white.withValues(
                                              alpha: 0.8,
                                            ),
                                            colorBlendMode: BlendMode.modulate,
                                          ),
                                          const SizedBox(height: 18),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 18,
                                              vertical: 14,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withValues(
                                                alpha: 0.10,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              border: Border.all(
                                                color: Colors.white.withValues(
                                                  alpha: 0.12,
                                                ),
                                              ),
                                            ),
                                            child: Column(
                                              children: [
                                                const Text(
                                                  'Choose image',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  'Tap here to take a photo or pick from gallery',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Colors.white
                                                        .withValues(
                                                          alpha: 0.78,
                                                        ),
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  else
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Image.file(
                                        File(
                                          controller.selectedImage.value!.path,
                                        ),
                                        width: double.infinity,
                                        height: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  Positioned(
                                    top: 0,
                                    left: 0,
                                    child: _buildCorner(
                                      isTop: true,
                                      isLeft: true,
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: _buildCorner(
                                      isTop: true,
                                      isLeft: false,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    child: _buildCorner(
                                      isTop: false,
                                      isLeft: true,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: _buildCorner(
                                      isTop: false,
                                      isLeft: false,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Obx(
                          () => AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: controller.ocrResult.isEmpty
                                ? Container(
                                    key: const ValueKey('empty-result'),
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(18),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.08,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.10,
                                        ),
                                      ),
                                    ),
                                    child: const Text(
                                      'Scan an image to get amount and category.',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                  )
                                : Container(
                                    key: const ValueKey('result-panel'),
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(18),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.08,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.10,
                                        ),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Extracted result',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 14),
                                        _buildResultRow(
                                          label: 'Amount',
                                          value: controller.ocrResult['amount']
                                              ?.toString(),
                                        ),
                                        const SizedBox(height: 10),
                                        _buildResultRow(
                                          label: 'Category',
                                          value: controller
                                              .ocrResult['category']
                                              ?.toString(),
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Row(
                          children: [
                            Expanded(
                              child: PrimaryButton(
                                text: 'Retake',
                                onPressed: () =>
                                    controller.showImageSourceOptions(context),
                                gradientColors: [
                                  Colors.white.withValues(alpha: 0.2),
                                  Colors.white.withValues(alpha: 0.1),
                                ],
                                isGlass: true,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Obx(
                                () => PrimaryButton(
                                  text: controller.ocrResult.isEmpty
                                      ? 'Scan'
                                      : 'Save Expense',
                                  isLoading:
                                      controller.isLoading.value ||
                                      controller.isSaving.value,
                                  onPressed:
                                      controller.isLoading.value ||
                                          controller.isSaving.value
                                      ? null
                                      : () async {
                                          if (controller.ocrResult.isNotEmpty) {
                                            final result = await controller
                                                .saveReceiptAsExpense();
                                            if (!context.mounted) {
                                              return;
                                            }

                                            Get.snackbar(
                                              result.success
                                                  ? 'Success'
                                                  : 'Error',
                                              result.message,
                                              backgroundColor: result.success
                                                  ? Colors.green
                                                  : Colors.redAccent,
                                              colorText: Colors.white,
                                              snackPosition:
                                                  SnackPosition.BOTTOM,
                                            );

                                            if (result.success) {
                                              await Future.delayed(
                                                const Duration(
                                                  milliseconds: 700,
                                                ),
                                              );
                                              Get.back();
                                            }
                                            return;
                                          }

                                          await controller.analyzeReceipt();
                                        },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorner({required bool isTop, required bool isLeft}) {
    const double size = 24;
    const double thickness = 3;
    const Color color = Colors.white;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        border: Border(
          top: isTop
              ? const BorderSide(color: color, width: thickness)
              : BorderSide.none,
          bottom: !isTop
              ? const BorderSide(color: color, width: thickness)
              : BorderSide.none,
          left: isLeft
              ? const BorderSide(color: color, width: thickness)
              : BorderSide.none,
          right: !isLeft
              ? const BorderSide(color: color, width: thickness)
              : BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildResultRow({required String label, required String? value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        Flexible(
          child: Text(
            value?.isNotEmpty == true ? value! : '-',
            textAlign: TextAlign.end,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
