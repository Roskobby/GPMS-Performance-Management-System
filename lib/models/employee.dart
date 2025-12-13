class Employee {
  String id;
  String employeeNumber; // Primary identifier
  String name;
  String department;
  String jobGrade;
  String designation;
  String lineManager;
  String? email; // Optional
  String? photoUrl;
  String? password; // For authentication
  bool isFirstLogin; // Track if password needs to be changed
  DateTime? lastPasswordChange;

  Employee({
    required this.id,
    required this.employeeNumber,
    required this.name,
    required this.department,
    required this.jobGrade,
    required this.designation,
    required this.lineManager,
    this.email,
    this.photoUrl,
    this.password,
    this.isFirstLogin = true,
    this.lastPasswordChange,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeNumber': employeeNumber,
      'name': name,
      'department': department,
      'jobGrade': jobGrade,
      'designation': designation,
      'lineManager': lineManager,
      'email': email,
      'photoUrl': photoUrl,
      'password': password,
      'isFirstLogin': isFirstLogin,
      'lastPasswordChange': lastPasswordChange?.toIso8601String(),
    };
  }

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] as String,
      employeeNumber: json['employeeNumber'] as String,
      name: json['name'] as String,
      department: json['department'] as String,
      jobGrade: json['jobGrade'] as String,
      designation: json['designation'] as String,
      lineManager: json['lineManager'] as String,
      email: json['email'] as String?,
      photoUrl: json['photoUrl'] as String?,
      password: json['password'] as String?,
      isFirstLogin: json['isFirstLogin'] as bool? ?? true,
      lastPasswordChange: json['lastPasswordChange'] != null
          ? DateTime.parse(json['lastPasswordChange'] as String)
          : null,
    );
  }
}
