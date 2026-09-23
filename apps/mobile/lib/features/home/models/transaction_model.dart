class TransactionModel {
  final String title;
  final String subtitle;
  final String amount;
  final bool isIncome;
  final String trailingText;
  final String category;
  final DateTime? date;
  final String description;
  final String? fileUrl;

  const TransactionModel({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isIncome,
    required this.trailingText,
    this.category = '',
    this.date,
    this.description = '',
    this.fileUrl,
  });
}
