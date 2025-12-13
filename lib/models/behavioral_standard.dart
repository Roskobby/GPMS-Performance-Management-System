

class BehavioralStandard {
  String id;

  String employeeId;

  int year;

  Map<String, BehavioralItem> items;

  DateTime lastUpdated;

  BehavioralStandard({
    required this.id,
    required this.employeeId,
    required this.year,
    required this.items,
    required this.lastUpdated,
  });

  double get selfTotalScore {
    return items.values.fold(0.0, (sum, item) => sum + item.selfScore);
  }

  double get managerTotalScore {
    return items.values.fold(0.0, (sum, item) => sum + item.managerScore);
  }

  double get selfPercentage {
    int maxScore = items.length * 5;
    return (selfTotalScore / maxScore) * 30; // 30% weight
  }

  double get managerPercentage {
    int maxScore = items.length * 5;
    return (managerTotalScore / maxScore) * 30; // 30% weight
  }

  static Map<String, BehavioralItem> getDefaultItems() {
    return {
      // PART I: HSSE
      'hsse_1': BehavioralItem(
        category: 'HSSE',
        statement: 'Exhibit positive behaviors that comply with HSSE requirements',
        selfScore: 0,
        managerScore: 0,
      ),
      'hsse_2': BehavioralItem(
        category: 'HSSE',
        statement: 'Proactively promote safety at the workplace',
        selfScore: 0,
        managerScore: 0,
      ),

      // PART II: CUSTOMERS / EMPLOYEES
      'customer_1': BehavioralItem(
        category: 'Customer Focus/Teamwork',
        statement: 'Develop good relations with external customers (If applicable)',
        selfScore: 0,
        managerScore: 0,
      ),
      'customer_2': BehavioralItem(
        category: 'Customer Focus/Teamwork',
        statement: 'Develop and ensure good working relations with other departments',
        selfScore: 0,
        managerScore: 0,
      ),
      'customer_3': BehavioralItem(
        category: 'Customer Focus/Teamwork',
        statement: 'Ensure teamwork & co-operation within department',
        selfScore: 0,
        managerScore: 0,
      ),
      'soft_skills': BehavioralItem(
        category: 'Soft Skills',
        statement: 'Communicate effectively to share information &/or skills with colleagues',
        selfScore: 0,
        managerScore: 0,
      ),

      // PART III: COMPETENCIES
      'job_knowledge_1': BehavioralItem(
        category: 'Job Knowledge',
        statement: 'Possess knowledge of work procedures & requirements of job',
        selfScore: 0,
        managerScore: 0,
      ),
      'job_knowledge_2': BehavioralItem(
        category: 'Job Knowledge',
        statement: 'Show technical competence/skill in area of specialization',
        selfScore: 0,
        managerScore: 0,
      ),
      'job_knowledge_3': BehavioralItem(
        category: 'Job Knowledge',
        statement: 'Is able to work independently',
        selfScore: 0,
        managerScore: 0,
      ),
      'work_attitude_1': BehavioralItem(
        category: 'Work Attitude',
        statement: 'Display a willingness to learn (on the job & any other training opportunity)',
        selfScore: 0,
        managerScore: 0,
      ),
      'work_attitude_2': BehavioralItem(
        category: 'Work Attitude',
        statement: 'Is proactive & display positive attitude',
        selfScore: 0,
        managerScore: 0,
      ),
      'work_attitude_3': BehavioralItem(
        category: 'Work Attitude',
        statement: "Follow instructions to the supervisor's / line manager's satisfaction",
        selfScore: 0,
        managerScore: 0,
      ),
      'work_attitude_4': BehavioralItem(
        category: 'Work Attitude',
        statement: 'Is responsible & reliable',
        selfScore: 0,
        managerScore: 0,
      ),
      'work_attitude_5': BehavioralItem(
        category: 'Work Attitude',
        statement: 'Is adaptable & willing to accept new responsibilities',
        selfScore: 0,
        managerScore: 0,
      ),
      'quality_1': BehavioralItem(
        category: 'Quality & Quantity of Work',
        statement: 'Is accurate, thorough & careful with work performed',
        selfScore: 0,
        managerScore: 0,
      ),
      'quality_2': BehavioralItem(
        category: 'Quality & Quantity of Work',
        statement: 'Is able to handle a reasonable volume of work',
        selfScore: 0,
        managerScore: 0,
      ),
      'quality_3': BehavioralItem(
        category: 'Quality & Quantity of Work',
        statement: 'Plan and organize work effectively (able to meet deadlines)',
        selfScore: 0,
        managerScore: 0,
      ),
      'process_improvement': BehavioralItem(
        category: 'Process Improvement',
        statement: 'Seek to continually improve processes & work methods generally (going the extra mile)',
        selfScore: 0,
        managerScore: 0,
      ),
      'problem_solving_1': BehavioralItem(
        category: 'Problem Solving',
        statement: 'Is able to handle conflicts / problems at work',
        selfScore: 0,
        managerScore: 0,
      ),
      'problem_solving_2': BehavioralItem(
        category: 'Problem Solving',
        statement: 'Help resolve team problems on work-related matters',
        selfScore: 0,
        managerScore: 0,
      ),
      'supervision_1': BehavioralItem(
        category: 'Supervision/Motivation of Staff',
        statement: 'Is a positive role model for other staff',
        selfScore: 0,
        managerScore: 0,
      ),
      'supervision_2': BehavioralItem(
        category: 'Supervision/Motivation of Staff',
        statement: 'Proactively supervise work of subordinates / contractors (if applicable)',
        selfScore: 0,
        managerScore: 0,
      ),

      // PART IV: PERFORMANCE
      'attendance': BehavioralItem(
        category: 'Attendance/Punctuality',
        statement: 'Has good attendance\n5) 0 day of MC\n4) 1 to 2 days of MC\n3) 3 to 4 days of MC\n2) 5 days of MC\n1) > 6 days of MC',
        selfScore: 0,
        managerScore: 0,
      ),
      'punctuality': BehavioralItem(
        category: 'Attendance/Punctuality',
        statement: 'Is punctual\n5) No Lateness\n4) Late for 1 to 2 times\n3) Late for 3 to 4 times\n2) Late for 5 to 6 times\n1) Late for > 7 times',
        selfScore: 0,
        managerScore: 0,
      ),

      // PART V: OTHER CONTRIBUTIONS
      'other_1': BehavioralItem(
        category: 'Other Contributions',
        statement: 'Use practices that save company resources and minimize wastage',
        selfScore: 0,
        managerScore: 0,
      ),
      'other_2': BehavioralItem(
        category: 'Other Contributions',
        statement: 'Participate or Contribute to additional or adhoc projects / committees / non-job-related tasks',
        selfScore: 0,
        managerScore: 0,
      ),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'year': year,
      'items': items.map((key, value) => MapEntry(key, value.toJson())),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory BehavioralStandard.fromJson(Map<String, dynamic> json) {
    final itemsData = json['items'] as Map<String, dynamic>?;
    final itemsMap = itemsData?.map(
      (key, value) => MapEntry(key, BehavioralItem.fromJson(value as Map<String, dynamic>)),
    ) ?? <String, BehavioralItem>{};
    
    return BehavioralStandard(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      year: json['year'] as int,
      items: itemsMap,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }
}

class BehavioralItem {
  String category;

  String statement;

  int selfScore; // 0-5 (0 = Not Rated, 1-5 = Rating)

  int managerScore; // 0-5

  BehavioralItem({
    required this.category,
    required this.statement,
    this.selfScore = 0,
    this.managerScore = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'statement': statement,
      'selfScore': selfScore,
      'managerScore': managerScore,
    };
  }

  factory BehavioralItem.fromJson(Map<String, dynamic> json) {
    return BehavioralItem(
      category: json['category'] as String,
      statement: json['statement'] as String,
      selfScore: json['selfScore'] as int? ?? 0,
      managerScore: json['managerScore'] as int? ?? 0,
    );
  }
}
