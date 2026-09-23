import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/primary_button.dart';
import '../home_controller.dart';
import '../controllers/stats_controller.dart';
import '../widgets/blurred_card_overlay.dart';
import '../../profile/profile_controller.dart';

class StatsContent extends StatelessWidget {
  const StatsContent({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<StatsController>()
        ? Get.find<StatsController>()
        : Get.put(StatsController());
    final profileController = Get.find<ProfileController>();

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    if (Get.isRegistered<HomeController>()) {
                      Get.find<HomeController>().changeTabIndex(0);
                      return;
                    }

                    if (Get.key.currentState?.canPop() ?? false) {
                      Get.back();
                    }
                  },
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const Expanded(
                  child: Text(
                    'Reports',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              final isPremium = profileController.isPremiumUser;

              return RefreshIndicator(
                onRefresh: controller.fetchExpenseReport,
                color: const Color(0xFF56CCF2),
                backgroundColor: const Color(0xFF10253F),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (controller.isLoading.value)
                        const Padding(
                          padding: EdgeInsets.only(top: 24),
                          child: Center(
                            child: Text(
                              'Loading report...',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        )
                      else if (controller.chartData.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 24),
                          child: Center(
                            child: Text(
                              'No expense data found',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        )
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Expense report by category',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Container(
                              height: 320,
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                20,
                                16,
                                18,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF4F6A8F,
                                ).withValues(alpha: 0.90),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.10),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.22),
                                    blurRadius: 18,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: _ExpenseBarChart(
                                chartData: controller.chartData,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Lock Choose File format section for free users
                            BlurredCardOverlay(
                              isPro: isPremium,
                              title: 'Export Financial Reports',
                              subtitle: 'Choose file format & download PDF, Excel, or CSV reports',
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Choose file format',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF16253A).withValues(alpha: 0.85),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.12),
                                        width: 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.25),
                                          blurRadius: 20,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        _FormatOption(
                                          title: 'PDF Document',
                                          subtitle: 'Standard document format for printing & sharing',
                                          badgeText: 'Recommended',
                                          icon: Icons.picture_as_pdf_rounded,
                                          iconColor: const Color(0xFFEB5757),
                                          selected:
                                              controller.selectedFormat.value ==
                                              'PDF',
                                          onTap: () =>
                                              controller.setSelectedFormat('PDF'),
                                        ),
                                        const _FormatDivider(),
                                        _FormatOption(
                                          title: 'Excel Spreadsheet (.xlsx)',
                                          subtitle: 'Structured data for financial accounting',
                                          icon: Icons.table_chart_rounded,
                                          iconColor: const Color(0xFF27AE60),
                                          selected:
                                              controller.selectedFormat.value ==
                                              'Excel',
                                          onTap: () =>
                                              controller.setSelectedFormat('Excel'),
                                        ),
                                        const _FormatDivider(),
                                        _FormatOption(
                                          title: 'CSV File (.csv)',
                                          subtitle: 'Raw comma-separated data for export',
                                          icon: Icons.insert_drive_file_rounded,
                                          iconColor: const Color(0xFFF2994A),
                                          selected:
                                              controller.selectedFormat.value ==
                                              'CSV',
                                          onTap: () =>
                                              controller.setSelectedFormat('CSV'),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  PrimaryButton(
                                    text: 'Download Report',
                                    height: 56,
                                    borderRadius: 14,
                                    onPressed: controller.isDownloading.value
                                        ? null
                                        : () {
                                            final format =
                                                controller.selectedFormat.value;
                                            if (format == 'Excel') {
                                              controller.downloadExcelReport();
                                              return;
                                            }
                                            if (format == 'CSV') {
                                              controller.downloadCsvReport();
                                              return;
                                            }
                                            controller.downloadPdfReport();
                                          },
                                    isLoading: controller.isDownloading.value,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 28),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _FormatDivider extends StatelessWidget {
  const _FormatDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: Colors.white.withValues(alpha: 0.10),
      height: 1,
      thickness: 1,
    );
  }
}

class _FormatOption extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? badgeText;
  final IconData icon;
  final Color iconColor;
  final bool selected;
  final VoidCallback onTap;

  const _FormatOption({
    required this.title,
    this.subtitle,
    this.badgeText,
    required this.icon,
    required this.iconColor,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFF2F80ED).withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              // Icon Badge
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: iconColor.withValues(alpha: selected ? 0.6 : 0.25),
                    width: 1,
                  ),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),

              // Title and Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                        if (badgeText != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2F80ED).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(0xFF56CCF2).withValues(alpha: 0.4),
                              ),
                            ),
                            child: Text(
                              badgeText!,
                              style: const TextStyle(
                                color: Color(0xFF56CCF2),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // Custom Radio Checkbox
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? const Color(0xFF2F80ED) : Colors.transparent,
                  border: Border.all(
                    color: selected
                        ? const Color(0xFF56CCF2)
                        : Colors.white.withValues(alpha: 0.35),
                    width: 2,
                  ),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF2F80ED).withValues(alpha: 0.4),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                child: selected
                    ? const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 16,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExpenseBarChart extends StatelessWidget {
  final List<Map<String, dynamic>> chartData;

  const _ExpenseBarChart({required this.chartData});

  @override
  Widget build(BuildContext context) {
    if (chartData.isEmpty) {
      return const Center(
        child: Text(
          'No expense data found',
          style: TextStyle(color: Colors.white54, fontSize: 14),
        ),
      );
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceEvenly,
        maxY: 100,
        minY: 0,
        barTouchData: BarTouchData(enabled: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 10,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.white.withValues(alpha: 0.14),
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          show: true,
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= chartData.length) {
                  return const SizedBox.shrink();
                }

                final label = chartData[index]['category'] as String;
                return SideTitleWidget(
                  meta: meta,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      label,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 42,
              interval: 10,
              getTitlesWidget: (value, meta) {
                if (value < 0 || value > 100) {
                  return const SizedBox.shrink();
                }

                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    '${value.toInt()}%',
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: List.generate(chartData.length, (index) {
          final entry = chartData[index];
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: (entry['percentage'] as double).clamp(0, 100),
                color: entry['color'] as Color,
                width: 28,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(2),
                  topRight: Radius.circular(2),
                ),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: 100,
                  color: Colors.white.withValues(alpha: 0.04),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
