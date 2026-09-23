class PrivacyPolicyItem {
  final String id;
  final String title;

  PrivacyPolicyItem({required this.id, required this.title});

  factory PrivacyPolicyItem.fromJson(Map<String, dynamic> json) {
    return PrivacyPolicyItem(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
    );
  }
}

class PrivacyPolicyDetails {
  final String id;
  final String title;
  final String description;

  PrivacyPolicyDetails({
    required this.id,
    required this.title,
    required this.description,
  });

  factory PrivacyPolicyDetails.fromJson(Map<String, dynamic> json) {
    return PrivacyPolicyDetails(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
    );
  }
}