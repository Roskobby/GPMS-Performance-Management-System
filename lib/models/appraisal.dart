

class Appraisal {
  String id;

  String employeeId;

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

  DateTime? submittedDate;

  DateTime? approvedDate;

  String? disciplinaryNotes;

  Appraisal({
    required this.id,
    required this.employeeId,
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
    this.submittedDate,
    this.approvedDate,
    this.disciplinaryNotes,
  });

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
      'year': year,
      'reviewPeriodStart': reviewPeriodStart.toIso8601String(),
      'reviewPeriodEnd': reviewPeriodEnd.toIso8601String(),
      'status': status.toString(),
      'behavioralStandardId': behavioralStandardId,
      'goalIds': goalIds,
      'professionalDevelopmentId': professionalDevelopmentId,
      'behavioralScore': behavioralScore,
      'kpiScore': kpiScore,
      'overallScore': overallScore,
      'employeeComments': employeeComments,
      'managerComments': managerComments,
      'submittedDate': submittedDate?.toIso8601String(),
      'approvedDate': approvedDate?.toIso8601String(),
      'disciplinaryNotes': disciplinaryNotes,
    };
  }

  factory Appraisal.fromJson(Map<String, dynamic> json) {
    return Appraisal(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      year: json['year'] as int,
      reviewPeriodStart: DateTime.parse(json['reviewPeriodStart'] as String),
      reviewPeriodEnd: DateTime.parse(json['reviewPeriodEnd'] as String),
      status: AppraisalStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => AppraisalStatus.draft,
      ),
      behavioralStandardId: json['behavioralStandardId'] as String,
      goalIds: (json['goalIds'] as List).cast<String>(),
      professionalDevelopmentId: json['professionalDevelopmentId'] as String,
      behavioralScore: (json['behavioralScore'] as num?)?.toDouble() ?? 0.0,
      kpiScore: (json['kpiScore'] as num?)?.toDouble() ?? 0.0,
      overallScore: (json['overallScore'] as num?)?.toDouble() ?? 0.0,
      employeeComments: json['employeeComments'] as String? ?? '',
      managerComments: json['managerComments'] as String? ?? '',
      submittedDate: json['submittedDate'] != null
          ? DateTime.parse(json['submittedDate'] as String)
          : null,
      approvedDate: json['approvedDate'] != null
          ? DateTime.parse(json['approvedDate'] as String)
          : null,
      disciplinaryNotes: json['disciplinaryNotes'] as String?,
    );
  }
}

enum AppraisalStatus {
  draft,

  selfAssessmentComplete,

  submitted,

  managerReview,

  completed,

  archived,
}
