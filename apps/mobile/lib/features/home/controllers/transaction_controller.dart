import 'dart:async';

import 'package:intl/intl.dart';
import 'package:get/get.dart';

import '../../../data/repositories/income_repository.dart';
import '../models/transaction_model.dart';

class TransactionController extends GetxController {
  final IncomeRepository _incomeRepository = IncomeRepository();

  final RxInt selectedIndex = 0.obs;
  final RxBool isLoading = false.obs;

  final RxList<TransactionModel> allTransactions = <TransactionModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    unawaited(fetchTransactions());
  }

  Future<void> fetchTransactions() async {
    isLoading.value = true;

    try {
      final results = await Future.wait([
        _incomeRepository.fetchIncomeHistory(),
        _incomeRepository.fetchExpenseHistory(),
      ]);

      final incomeTransactions = _buildTransactions(results[0], isIncome: true);
      final expenseTransactions = _buildTransactions(
        results[1],
        isIncome: false,
      );

      final combined = [...incomeTransactions, ...expenseTransactions];
      combined.sort((left, right) {
        final leftDate = left.date ?? DateTime.fromMillisecondsSinceEpoch(0);
        final rightDate = right.date ?? DateTime.fromMillisecondsSinceEpoch(0);
        return rightDate.compareTo(leftDate);
      });

      allTransactions.assignAll(combined);
    } catch (_) {
      allTransactions.clear();
    } finally {
      isLoading.value = false;
    }
  }

  List<TransactionModel> _buildTransactions(
    List<Map<String, dynamic>> source, {
    required bool isIncome,
  }) {
    return source
        .map((entry) => _mapHistoryEntry(entry, isIncome: isIncome))
        .whereType<TransactionModel>()
        .toList();
  }

  TransactionModel? _mapHistoryEntry(
    Map<String, dynamic> entry, {
    required bool isIncome,
  }) {
    final amount = _toDouble(entry['amount']);
    final category = _readText(entry['category']);
    final description = _readText(entry['description']);
    final fileUrl = _readText(entry['fileUrl']);
    final transactionDate =
        _parseDate(entry['date']) ?? _parseDate(entry['createdAt']);

    if (amount == null) {
      return null;
    }

    final title = category.isNotEmpty
        ? category
        : (isIncome ? 'Income' : 'Expense');
    final dateLabel = transactionDate == null
        ? 'Date unavailable'
        : DateFormat('MMM d, yyyy').format(transactionDate);
    final subtitle = description.isEmpty
        ? dateLabel
        : '$dateLabel • $description';
    final formattedAmount = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: amount % 1 == 0 ? 0 : 2,
    ).format(amount.abs());

    return TransactionModel(
      title: title,
      subtitle: subtitle,
      amount: '${isIncome ? '+' : '-'}$formattedAmount',
      isIncome: isIncome,
      trailingText: fileUrl.isNotEmpty ? 'Receipt Attached' : category,
      category: category,
      date: transactionDate,
      description: description,
      fileUrl: fileUrl.isEmpty ? null : fileUrl,
    );
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

  DateTime? _parseDate(dynamic value) {
    final raw = value?.toString();
    if (raw == null || raw.isEmpty) {
      return null;
    }

    return DateTime.tryParse(raw);
  }

  String _readText(dynamic value) {
    final text = value?.toString().trim() ?? '';
    return text;
  }

  List<TransactionModel> get filteredTransactions {
    if (selectedIndex.value == 0) return allTransactions;
    if (selectedIndex.value == 1) {
      return allTransactions.where((t) => t.isIncome).toList();
    }
    return allTransactions.where((t) => !t.isIncome).toList();
  }

  void changeFilter(int index) {
    selectedIndex.value = index;
  }
}
