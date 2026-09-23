import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../home_controller.dart';

class BalanceChartCard extends StatelessWidget {
  const BalanceChartCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Obx(() {
      final chartData = controller.chartData;
      final totalBalance = chartData.fold<double>(
        0,
        (sum, entry) =>
            sum + (entry['income'] as double) - (entry['expense'] as double),
      );

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Balance',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatCurrency(totalBalance),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    _buildLegendItem(const Color(0xFFEB5757), 'Expenses'),
                    const SizedBox(width: 12),
                    _buildLegendItem(const Color(0xFF56CCF2), 'Income'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: _buildChartBody(controller),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildChartBody(HomeController controller) {
    if (controller.isLoading.value) {
      return const Center(
        child: SizedBox(
          height: 28,
          width: 28,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Color(0xFF56CCF2),
          ),
        ),
      );
    }

    if (controller.chartData.isEmpty) {
      return const Center(
        child: Text(
          'No data available',
          style: TextStyle(
            color: Colors.white54,
            fontSize: 14,
          ),
        ),
      );
    }

    final chartData = controller.chartData;
    final incomeSpots = <FlSpot>[];
    final expenseSpots = <FlSpot>[];
    double maxValue = 0;

    for (final entry in chartData) {
      final monthIndex = (entry['month'] as int) - 1;
      final income = entry['income'] as double;
      final expense = entry['expense'] as double;

      incomeSpots.add(FlSpot(monthIndex.toDouble(), income));
      expenseSpots.add(FlSpot(monthIndex.toDouble(), expense));
      maxValue = math.max(maxValue, math.max(income, expense));
    }

    final maxY = math.max(1000.0, (maxValue * 1.2).ceilToDouble());
    final yInterval = maxY / 4;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.white.withOpacity(0.1),
              strokeWidth: 1,
              dashArray: [5, 5],
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                const style = TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                );

                final monthIndex = value.toInt();
                if (monthIndex < 0 || monthIndex > 11) {
                  return Container();
                }

                return SideTitleWidget(
                  meta: meta,
                  child: Text(_monthLabel(monthIndex + 1), style: style),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: yInterval,
              reservedSize: 50,
              getTitlesWidget: (value, meta) {
                if (value < 0 || value > maxY) {
                  return Container();
                }

                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    _formatAxisAmount(value),
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: 11,
        minY: 0,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: incomeSpots,
            isCurved: true,
            color: const Color(0xFF56CCF2),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(show: false),
          ),
          LineChartBarData(
            spots: expenseSpots,
            isCurved: true,
            color: const Color(0xFFEB5757),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  String _formatCurrency(double value) {
    return NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(value);
  }

  String _formatAxisAmount(double value) {
    if (value >= 1000) {
      final compactValue = value / 1000;
      final formatted = compactValue == compactValue.roundToDouble()
          ? compactValue.toStringAsFixed(0)
          : compactValue.toStringAsFixed(1);
      return '\$${formatted}k';
    }

    return '\$${value.toStringAsFixed(0)}';
  }

  String _monthLabel(int month) {
    switch (month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
      default:
        return '';
    }
  }
}