

class ProfessionalDevelopment {
  String id;

  String employeeId;

  int year;

  String selfDevelopment;

  int selfScore; // 1-5

  String teamDevelopment;

  int teamScore; // 1-5

  double selfWeight; // Default 0.35%

  double teamWeight; // Default 0.35%

  DateTime lastUpdated;

  ProfessionalDevelopment({
    required this.id,
    required this.employeeId,
    required this.year,
    this.selfDevelopment = '',
    this.selfScore = 0,
    this.teamDevelopment = '',
    this.teamScore = 0,
    this.selfWeight = 0.35,
    this.teamWeight = 0.35,
    required this.lastUpdated,
  });

  double get selfContribution {
    return (selfScore * selfWeight);
  }

  double get teamContribution {
    return (teamScore * teamWeight);
  }

  double get totalContribution {
    return selfContribution + teamContribution;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'year': year,
      'selfDevelopment': selfDevelopment,
      'selfScore': selfScore,
      'teamDevelopment': teamDevelopment,
      'teamScore': teamScore,
      'selfWeight': selfWeight,
      'teamWeight': teamWeight,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory ProfessionalDevelopment.fromJson(Map<String, dynamic> json) {
    return ProfessionalDevelopment(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      year: json['year'] as int,
      selfDevelopment: json['selfDevelopment'] as String? ?? '',
      selfScore: json['selfScore'] as int? ?? 0,
      teamDevelopment: json['teamDevelopment'] as String? ?? '',
      teamScore: json['teamScore'] as int? ?? 0,
      selfWeight: (json['selfWeight'] as num?)?.toDouble() ?? 0.35,
      teamWeight: (json['teamWeight'] as num?)?.toDouble() ?? 0.35,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }
}
