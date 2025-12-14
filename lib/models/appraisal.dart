import 'appraisal_status.dart';

class Appraisal {
  String id;
  String employeeId;
  String employeeNumber;
  String employeeName;
  int year;
  DateTime reviewPeriodStart;
  DateTime reviewPeriodEnd;
  AppraisalStatus status;
  
  String behavioralStandardId;
  List<String> goalIds;
  String professionalDevelopmentId;
  
  double behavioralScore; // 30% weight
  double kpiScore; // 70% weight
  double overallScore;
  
  String employeeComments;
  String managerComments;
  
  // Workflow timestamps
  DateTime createdAt;
  DateTime? submittedToManagerAt;
  DateTime? managerStartedReviewAt;
  DateTime? submittedToHRAt;
  
  // Manager information
  String? reviewedByManagerId;
  String? reviewedByManagerName;
  String? reviewedByManagerNumber;
  
  String? disciplinaryNotes;

  Appraisal({
    required this.id,
    required this.employeeId,
    required this.employeeNumber,
    required this.employeeName,
    required this.year,
    required this.reviewPeriodStart,
    required this.reviewPeriodEnd,
    this.status = AppraisalStatus.draft,
    required this.behavioralStandardId,
    required this.goalIds,
    required this.professionalDevelopmentId,
    this.behavioralScore = 0.0,
    this.kpiScore = 0.0,
    this.overallScore = 0.0,
    this.employeeComments = '',
    this.managerComments = '',
    DateTime? createdAt,
    this.submittedToManagerAt,
    this.managerStartedReviewAt,
    this.submittedToHRAt,
    this.reviewedByManagerId,
    this.reviewedByManagerName,
    this.reviewedByManagerNumber,
    this.disciplinaryNotes,
  }) : createdAt = createdAt ?? DateTime.now();

  void calculateOverallScore() {
    overallScore = behavioralScore + kpiScore;
  }

  String get performanceRating {
    if (overallScore >= 4.5) return 'Excellent';
    if (overallScore >= 4.0) return 'Above Average';
    if (overallScore >= 3.0) return 'Average/Good';
    if (overallScore >= 2.0) return 'Below Average';
    return 'Need Improvement';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'employeeNumber': employeeNumber,
      'employeeName': employeeName,
      'year': year,
      'reviewPeriodStart': reviewPeriodStart.toIso8601String(),
      'reviewPeriodEnd': reviewPeriodEnd.toIso8601String(),
      'status': status.toStorageString(),
      'behavioralStandardId': behavioralStandardId,
      'goalIds': goalIds,
      'professionalDevelopmentId': professionalDevelopmentId,
      'behavioralScore': behavioralScore,
      'kpiScore': kpiScore,
      'overallScore': overallScore,
      'employeeComments': employeeComments,
      'managerComments': managerComments,
      'createdAt': createdAt.toIso8601String(),
      'submittedToManagerAt': submittedToManagerAt?.toIso8601String(),
      'managerStartedReviewAt': managerStartedReviewAt?.toIso8601String(),
      'submittedToHRAt': submittedToHRAt?.toIso8601String(),
      'reviewedByManagerId': reviewedByManagerId,
      'reviewedByManagerName': reviewedByManagerName,
      'reviewedByManagerNumber': reviewedByManagerNumber,
      'disciplinaryNotes': disciplinaryNotes,
    };
  }

  factory Appraisal.fromJson(Map<String, dynamic> json) {
    return Appraisal(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      employeeNumber: json['employeeNumber'] as String? ?? '',
      employeeName: json['employeeName'] as String? ?? '',
      year: json['year'] as int,
      reviewPeriodStart: DateTime.parse(json['reviewPeriodStart'] as String),
      reviewPeriodEnd: DateTime.parse(json['reviewPeriodEnd'] as String),
      status: AppraisalStatusExtension.fromString(
        json['status'] as String? ?? 'draft',
      ),
      behavioralStandardId: json['behavioralStandardId'] as String,
      goalIds: (json['goalIds'] as List?)?.cast<String>() ?? [],
      professionalDevelopmentId: json['professionalDevelopmentId'] as String,
      behavioralScore: (json['behavioralScore'] as num?)?.toDouble() ?? 0.0,
      kpiScore: (json['kpiScore'] as num?)?.toDouble() ?? 0.0,
      overallScore: (json['overallScore'] as num?)?.toDouble() ?? 0.0,
      employeeComments: json['employeeComments'] as String? ?? '',
      managerComments: json['managerComments'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      submittedToManagerAt: json['submittedToManagerAt'] != null
          ? DateTime.parse(json['submittedToManagerAt'] as String)
          : null,
      managerStartedReviewAt: json['managerStartedReviewAt'] != null
          ? DateTime.parse(json['managerStartedReviewAt'] as String)
          : null,
      submittedToHRAt: json['submittedToHRAt'] != null
          ? DateTime.parse(json['submittedToHRAt'] as String)
          : null,
      reviewedByManagerId: json['reviewedByManagerId'] as String?,
      reviewedByManagerName: json['reviewedByManagerName'] as String?,
      reviewedByManagerNumber: json['reviewedByManagerNumber'] as String?,
      disciplinaryNotes: json['disciplinaryNotes'] as String?,
    );
  }
}
