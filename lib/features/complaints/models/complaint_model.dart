class ComplaintModel {
  final String requestId;
  final String title;
  final String content;
  final String type;

  ComplaintModel({
    required this.requestId,
    required this.title,
    required this.content,
    this.type = 'request', // القيمة الافتراضية
  });

  Map<String, dynamic> toJson() {
    return {
      'request_id': requestId,
      'title': title,
      'content': content,
      'type': type,
    };
  }

  factory ComplaintModel.fromJson(Map<String, dynamic> json) {
    return ComplaintModel(
      requestId: json['request_id']?.toString() ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      type: json['type'] ?? 'request',
    );
  }
}
