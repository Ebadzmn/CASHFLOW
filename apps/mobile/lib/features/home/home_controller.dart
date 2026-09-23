import 'dart:async';
import 'dart:math' as math;

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../data/repositories/income_repository.dart';
import 'controllers/audit_risk_controller.dart';
import 'widgets/add_transaction_modal.dart';

class HomeController extends GetxController {
  final IncomeRepository _incomeRepository = IncomeRepository();

  final selectedIndex = 0.obs;
  // Initialize to true to maintain backward compatibility if no argument is passed (e.g. from hot reload)
  final isPro = true.obs;
  final incomeList = <Map<String, dynamic>>[].obs;
  final expenseList = <Map<String, dynamic>>[].obs;
  final chartData = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    unawaited(fetchBalanceChartData());
  }

  void changeTabIndex(int index) {
    if (index == 4) {
      Get.dialog(
        const AddTransactionModal(),
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(
          0.3,
        ), // Light overlay, blur is inside the widget
      );
    } else {
      selectedIndex.value = index;
    }
  }

  Future<void> fetchBalanceChartData() async {
    isLoading.value = true;

    try {
      final results = await Future.wait([
        _incomeRepository.fetchIncomeList(),
        _incomeRepository.fetchExpenseList(),
      ]);

      final incomeMonths = _buildLatestYearMonthlyTotals(results[0]);
      final expenseMonths = _buildLatestYearMonthlyTotals(results[1]);

      incomeList.assignAll(incomeMonths);
      expenseList.assignAll(expenseMonths);
      chartData.assignAll(_mergeMonthlyTotals(incomeMonths, expenseMonths));
    } catch (_) {
      incomeList.clear();
      expenseList.clear();
      chartData.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshDashboard() async {
    await Future.wait([
      fetchBalanceChartData(),
      if (Get.isRegistered<AuditRiskController>())
        Get.find<AuditRiskController>().fetchAuditRisk(),
    ]);
  }

  List<Map<String, dynamic>> _buildLatestYearMonthlyTotals(
    List<Map<String, dynamic>> source,
  ) {
    if (source.isEmpty) {
      return <Map<String, dynamic>>[];
    }

    final normalized = source
        .map(_normalizeMonthlyEntry)
        .whereType<Map<String, dynamic>>()
        .toList();

    if (normalized.isEmpty) {
      return <Map<String, dynamic>>[];
    }

    final latestYear = normalized
        .map((entry) => entry['year'] as int)
        .reduce(math.max);

    final totalsByMonth = <int, double>{
      for (var month = 1; month <= 12; month++) month: 0.0,
    };

    for (final entry in normalized) {
      if (entry['year'] != latestYear) {
        continue;
      }

      final month = entry['month'] as int;
      totalsByMonth[month] =
          (totalsByMonth[month] ?? 0) + (entry['total'] as double);
    }

    return List.generate(12, (index) {
      final month = index + 1;
      return <String, dynamic>{
        'year': latestYear,
        'month': month,
        'monthLabel': _monthLabel(month),
        'total': totalsByMonth[month] ?? 0,
      };
    });
  }

  List<Map<String, dynamic>> _mergeMonthlyTotals(
    List<Map<String, dynamic>> incomeMonths,
    List<Map<String, dynamic>> expenseMonths,
  ) {
    final incomeByMonth = <int, double>{
      for (final entry in incomeMonths)
        entry['month'] as int: entry['total'] as double,
    };
    final expenseByMonth = <int, double>{
      for (final entry in expenseMonths)
        entry['month'] as int: entry['total'] as double,
    };

    final latestYear =
        <int>[
          ...incomeMonths.map((entry) => entry['year'] as int),
          ...expenseMonths.map((entry) => entry['year'] as int),
        ].fold<int?>(null, (previous, current) {
          if (previous == null) {
            return current;
          }
          return math.max(previous, current);
        });

    return List.generate(12, (index) {
      final month = index + 1;
      return <String, dynamic>{
        'year': latestYear,
        'month': month,
        'monthLabel': _monthLabel(month),
        'income': incomeByMonth[month] ?? 0,
        'expense': expenseByMonth[month] ?? 0,
      };
    });
  }

  Map<String, dynamic>? _normalizeMonthlyEntry(Map<String, dynamic> entry) {
    final year = _toInt(entry['year']);
    final month = _toInt(entry['month']);
    final total = _toDouble(entry['total']);

    if (year == null || month == null || total == null) {
      return null;
    }

    return <String, dynamic>{'year': year, 'month': month, 'total': total};
  }

  int? _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '');
  }

  double? _toDouble(dynamic value) {
    if (value is double) {
      return value;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '');
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
