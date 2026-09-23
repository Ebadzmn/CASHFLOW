class NoticeItem {
  final String id;
  final String type;
  final DateTime? createdAt;
  final String documentUrl;

  NoticeItem({
    required this.id,
    required this.type,
    required this.createdAt,
    required this.documentUrl,
  });

  factory NoticeItem.fromJson(Map<String, dynamic> json) {
    return NoticeItem(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      type: json['type']?.toString().trim() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      documentUrl:
          json['document']?.toString().trim() ??
          json['documentUrl']?.toString().trim() ??
          json['file']?.toString().trim() ??
          '',
    );
  }
}
