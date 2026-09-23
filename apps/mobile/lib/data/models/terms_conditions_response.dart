class TermsConditionItem {
  final String id;
  final String title;

  TermsConditionItem({required this.id, required this.title});

  factory TermsConditionItem.fromJson(Map<String, dynamic> json) {
    return TermsConditionItem(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
    );
  }
}

class TermsConditionDetails {
  final String id;
  final String title;
  final String description;

  TermsConditionDetails({
    required this.id,
    required this.title,
    required this.description,
  });

  factory TermsConditionDetails.fromJson(Map<String, dynamic> json) {
    return TermsConditionDetails(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
    );
  }
}