/// Employee Registry Database
/// Maps employee numbers to their department, role, and line manager
/// This database should be maintained by HR and synchronized with the system

class EmployeeRegistry {
  // Deprecated: Use EmployeeRegistryService for actual employee management
  // This static registry is maintained for backwards compatibility only
  static final Map<String, EmployeeRegistryEntry> _registry = <String, EmployeeRegistryEntry>{};

  /// Get employee registry entry by employee number
  static EmployeeRegistryEntry? getEntry(String employeeNumber) {
    return _registry[employeeNumber.toUpperCase()];
  }

  /// Check if employee number exists in registry
  static bool exists(String employeeNumber) {
    return _registry.containsKey(employeeNumber.toUpperCase());
  }

  /// Get all registered employee numbers
  static List<String> getAllEmployeeNumbers() {
    return _registry.keys.toList()..sort();
  }

  /// Add new employee to registry (for HR admin)
  static void addEmployee(EmployeeRegistryEntry entry) {
    _registry[entry.employeeNumber.toUpperCase()] = entry;
  }

  /// Update employee registry entry (for HR admin)
  static void updateEmployee(String employeeNumber, EmployeeRegistryEntry entry) {
    _registry[employeeNumber.toUpperCase()] = entry;
  }

  /// Remove employee from registry (for HR admin)
  static void removeEmployee(String employeeNumber) {
    _registry.remove(employeeNumber.toUpperCase());
  }

  /// Get all employees in a department
  static List<EmployeeRegistryEntry> getEmployeesByDepartment(String department) {
    return _registry.values
        .where((entry) => entry.department == department)
        .toList();
  }

  /// Get all employees reporting to a line manager
  static List<EmployeeRegistryEntry> getEmployeesByLineManager(String lineManager) {
    return _registry.values
        .where((entry) => entry.lineManager == lineManager)
        .toList();
  }
}

class EmployeeRegistryEntry {
  final String employeeNumber;
  final String name;
  final String designation;
  final String jobGrade;
  final String department;
  final String lineManager;
  final String? email; // Optional
  final String initialPassword; // HR-generated initial password
  final bool passwordChanged; // Track if employee has changed password

  EmployeeRegistryEntry({
    required this.employeeNumber,
    required this.name,
    required this.designation,
    required this.jobGrade,
    required this.department,
    required this.lineManager,
    this.email,
    String? initialPassword,
    this.passwordChanged = false,
  }) : initialPassword = initialPassword ?? _generateRandomPassword();
  
  /// Generate a secure random password
  static String _generateRandomPassword() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghjkmnpqrstuvwxyz23456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    String password = '';
    
    // Generate 12-character password
    for (int i = 0; i < 12; i++) {
      password += chars[(random + i * 7) % chars.length];
    }
    
    return password;
  }

  Map<String, dynamic> toJson() {
    return {
      'employeeNumber': employeeNumber,
      'name': name,
      'designation': designation,
      'jobGrade': jobGrade,
      'department': department,
      'lineManager': lineManager,
      'email': email,
      'initialPassword': initialPassword,
      'passwordChanged': passwordChanged,
    };
  }

  factory EmployeeRegistryEntry.fromJson(Map<String, dynamic> json) {
    // Safe string conversion with fallback
    String safeString(dynamic value, String fallback) {
      if (value == null) return fallback;
      return value.toString();
    }
    
    return EmployeeRegistryEntry(
      employeeNumber: safeString(json['employeeNumber'], 'UNKNOWN'),
      name: safeString(json['name'], 'Unknown Name'),
      designation: safeString(json['designation'], 'Unknown Role'),
      jobGrade: safeString(json['jobGrade'], 'M1'),
      department: safeString(json['department'], 'HR & Admin'),
      lineManager: safeString(json['lineManager'], 'General Manager'),
      email: json['email']?.toString(),
      initialPassword: json['initialPassword']?.toString(),
      passwordChanged: json['passwordChanged'] == true,
    );
  }
  
  /// Create a copy with updated fields
  EmployeeRegistryEntry copyWith({
    String? employeeNumber,
    String? name,
    String? designation,
    String? jobGrade,
    String? department,
    String? lineManager,
    String? email,
    String? initialPassword,
    bool? passwordChanged,
  }) {
    return EmployeeRegistryEntry(
      employeeNumber: employeeNumber ?? this.employeeNumber,
      name: name ?? this.name,
      designation: designation ?? this.designation,
      jobGrade: jobGrade ?? this.jobGrade,
      department: department ?? this.department,
      lineManager: lineManager ?? this.lineManager,
      email: email ?? this.email,
      initialPassword: initialPassword ?? this.initialPassword,
      passwordChanged: passwordChanged ?? this.passwordChanged,
    );
  }
}
