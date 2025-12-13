

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
}

enum FeedbackType {
  managerToEmployee,

  peerToPeer,

  selfReflection,

  oneOnOne,
}
