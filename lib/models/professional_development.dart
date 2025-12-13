

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
}
