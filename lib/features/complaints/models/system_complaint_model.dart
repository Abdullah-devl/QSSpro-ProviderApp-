class SystemComplaintModel {
  final int? id;
  final String title;
  final String type;
  final String content;
  final String appSource;
  final String status;
  final DateTime? createdAt;

  SystemComplaintModel({
    this.id,
    required this.title,
    required this.type,
    required this.content,
    this.appSource = "provider",
    this.status = "pending",
    this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'type': type,
      'content': content,
      'app_source': appSource,
    };
  }

  factory SystemComplaintModel.fromJson(Map<String, dynamic> json) {
    return SystemComplaintModel(
      id: json['id'],
      title: json['title'] ?? '',
      type: json['type'] ?? '',
      content: json['content'] ?? '',
      appSource: json['app_source'] ?? 'provider',
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at']) 
          : null,
    );
  }
}
