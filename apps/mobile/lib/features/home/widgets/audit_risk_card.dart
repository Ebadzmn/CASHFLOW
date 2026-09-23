import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/audit_risk_controller.dart';

class AuditRiskCard extends StatelessWidget {
  const AuditRiskCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuditRiskController>();

    return Obx(() {
      final level = controller.riskLevel.value;
      final count = controller.riskCount.value;
      final statusColor = controller.riskColor;

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: const Color(0xFF16253A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: controller.isLoading.value
            ? _buildLoadingState()
            : controller.errorMessage.value.isNotEmpty
            ? _buildErrorState(controller)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Audit Risk',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Issues Found: $count',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: statusColor),
                        ),
                        child: Text(
                          level.toUpperCase(),
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Audit Risk: $level',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 40,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        const thumbSize = 24.0;
                        final trackWidth = constraints.maxWidth - thumbSize;
                        final thumbLeft = (trackWidth * controller.riskProgress)
                            .clamp(0.0, trackWidth);

                        return Stack(
                          children: [
                            Center(
                              child: Container(
                                height: 12,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFEB5757),
                                      Color(0xFFF2994A),
                                      Color(0xFF27AE60),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: thumbLeft,
                              top: 0,
                              bottom: 0,
                              child: Container(
                                width: thumbSize,
                                height: thumbSize,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'HIGH',
                        style: TextStyle(
                          color: Color(0xFFEB5757),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'MODERATE',
                        style: TextStyle(
                          color: Color(0xFFF2994A),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'LOW',
                        style: TextStyle(
                          color: Color(0xFF27AE60),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      );
    });
  }

  Widget _buildLoadingState() {
    return const SizedBox(
      height: 120,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                color: Color(0xFF56CCF2),
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Checking audit risk...',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(AuditRiskController controller) {
    return SizedBox(
      height: 120,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Failed to load audit risk',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: controller.fetchAuditRisk,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
