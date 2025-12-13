

class Goal {
  String id;
  String employeeId;
  int year;
  String goalNumber; // GOAL 1, GOAL 2, GOAL 3
  String title;
  List<Deliverable> deliverables;
  DateTime createdDate;
  GoalStatus status;
  bool isSubmittedToManager; // Track if submitted for manager review

  Goal({
    required this.id,
    required this.employeeId,
    required this.year,
    required this.goalNumber,
    required this.title,
    required this.deliverables,
    required this.createdDate,
    this.status = GoalStatus.draft,
    this.isSubmittedToManager = false,
  });

  // Calculate weights based on priorities
  void recalculateWeights() {
    if (deliverables.isEmpty) return;
    
    final totalPriority = deliverables.fold<int>(0, (sum, d) => sum + d.priority);
    if (totalPriority == 0) return;
    
    // Weight for each row = 70% × (Its Priority ÷ Sum of all Priorities)
    for (var deliverable in deliverables) {
      deliverable.weight = (70.0 * deliverable.priority) / totalPriority;
    }
  }

  double get totalWeight {
    return deliverables.fold(0.0, (sum, d) => sum + d.weight);
  }

  double get selfScore {
    if (deliverables.isEmpty) return 0.0;
    return deliverables.fold(0.0, (sum, d) => sum + d.selfContribution);
  }

  double get managerScore {
    if (deliverables.isEmpty) return 0.0;
    return deliverables.fold(0.0, (sum, d) => sum + d.managerContribution);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'year': year,
      'goalNumber': goalNumber,
      'title': title,
      'deliverables': deliverables.map((d) => d.toJson()).toList(),
      'createdDate': createdDate.toIso8601String(),
      'status': status.toString(),
      'isSubmittedToManager': isSubmittedToManager,
    };
  }

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      year: json['year'] as int,
      goalNumber: json['goalNumber'] as String,
      title: json['title'] as String,
      deliverables: (json['deliverables'] as List)
          .map((d) => Deliverable.fromJson(d as Map<String, dynamic>))
          .toList(),
      createdDate: DateTime.parse(json['createdDate'] as String),
      status: GoalStatus.values.firstWhere(
        (s) => s.toString() == json['status'],
        orElse: () => GoalStatus.draft,
      ),
      isSubmittedToManager: json['isSubmittedToManager'] as bool? ?? false,
    );
  }
}

class Deliverable {
  int number;
  String description;
  double weight; // Calculated automatically based on priority
  int priority; // 1-3 (default 1)
  String thresholdPerformance;
  String keyResults;
  int selfScore; // 1-5
  int managerScore; // 1-5

  Deliverable({
    required this.number,
    required this.description,
    this.weight = 0.0,
    this.priority = 1,
    this.thresholdPerformance = '',
    this.keyResults = '',
    this.selfScore = 0,
    this.managerScore = 0,
  });

  double get selfContribution {
    return (selfScore * weight) / 100;
  }

  double get managerContribution {
    return (managerScore * weight) / 100;
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'description': description,
      'weight': weight,
      'priority': priority,
      'thresholdPerformance': thresholdPerformance,
      'keyResults': keyResults,
      'selfScore': selfScore,
      'managerScore': managerScore,
    };
  }

  factory Deliverable.fromJson(Map<String, dynamic> json) {
    return Deliverable(
      number: json['number'] as int,
      description: json['description'] as String,
      weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
      priority: json['priority'] as int? ?? 1,
      thresholdPerformance: json['thresholdPerformance'] as String? ?? '',
      keyResults: json['keyResults'] as String? ?? '',
      selfScore: json['selfScore'] as int? ?? 0,
      managerScore: json['managerScore'] as int? ?? 0,
    );
  }
}

enum GoalStatus {
  draft,

  submitted,

  approved,

  inProgress,

  completed,
}
