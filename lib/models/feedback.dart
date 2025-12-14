

class Feedback {
  String id;

  String employeeId;

  String fromUserId;

  String fromUserName;

  FeedbackType type;

  String title;

  String content;

  DateTime date;

  List<String> tags; // e.g., ["Communication", "Teamwork", "Leadership"]

  int rating; // 1-5

  String? employeeResponse;

  DateTime? responseDate;

  Feedback({
    required this.id,
    required this.employeeId,
    required this.fromUserId,
    required this.fromUserName,
    required this.type,
    required this.title,
    required this.content,
    required this.date,
    this.tags = const [],
    this.rating = 3,
    this.employeeResponse,
    this.responseDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'fromUserId': fromUserId,
      'fromUserName': fromUserName,
      'type': type.toString(),
      'title': title,
      'content': content,
      'date': date.toIso8601String(),
      'tags': tags,
      'rating': rating,
      'employeeResponse': employeeResponse,
      'responseDate': responseDate?.toIso8601String(),
    };
  }

  factory Feedback.fromJson(Map<String, dynamic> json) {
    return Feedback(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      fromUserId: json['fromUserId'] as String,
      fromUserName: json['fromUserName'] as String,
      type: FeedbackType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => FeedbackType.selfReflection,
      ),
      title: json['title'] as String,
      content: json['content'] as String,
      date: DateTime.parse(json['date'] as String),
      tags: (json['tags'] as List?)?.cast<String>() ?? [],
      rating: json['rating'] as int? ?? 3,
      employeeResponse: json['employeeResponse'] as String?,
      responseDate: json['responseDate'] != null
          ? DateTime.parse(json['responseDate'] as String)
          : null,
    );
  }
}

enum FeedbackType {
  managerToEmployee,

  peerToPeer,

  selfReflection,

  oneOnOne,
}
