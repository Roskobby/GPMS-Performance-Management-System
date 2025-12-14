import 'package:hive/hive.dart';
import '../models/employee.dart';
import '../services/employee_registry_service.dart';

class AuthService {
  static const String _authBoxName = 'auth_box';
  static const String _currentUserKey = 'current_user';
  
  // Get employees box
  Box? get _employeesBox => Hive.isBoxOpen('employees') ? Hive.box('employees') : null;

  // Login with employee number and password
  Future<Employee?> login(String employeeNumber, String password) async {
    // Ensure employees box is open
    if (_employeesBox == null) {
      await Hive.openBox('employees');
    }
    
    final employeesBox = Hive.box('employees');
    
    // First, check if employee account already exists
    final employees = employeesBox.values.cast<Map<dynamic, dynamic>>();
    
    for (var employeeData in employees) {
      final employee = Employee.fromJson(Map<String, dynamic>.from(employeeData));
      
      if (employee.employeeNumber == employeeNumber) {
        // TODO: SECURITY - Implement password hashing for production
        // Currently using plain text comparison for development
        // Recommended: Use bcrypt, argon2, or PBKDF2 for password hashing
        if (employee.password == password) {
          // Save current user
          await _saveCurrentUser(employee);
          return employee;
        } else {
          return null; // Wrong password
        }
      }
    }
    
    // Employee account doesn't exist - check Employee Registry
    final registryEntry = EmployeeRegistryService.getEntry(employeeNumber);
    
    if (registryEntry != null) {
      // Verify password matches initial password from registry
      if (registryEntry.initialPassword == password) {
        // Create new Employee account from registry data
        final newEmployee = Employee(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          employeeNumber: registryEntry.employeeNumber,
          name: registryEntry.name,
          department: registryEntry.department,
          designation: registryEntry.designation,
          jobGrade: registryEntry.jobGrade,
          lineManager: registryEntry.lineManager,
          email: registryEntry.email,
          password: registryEntry.initialPassword,
          isFirstLogin: !registryEntry.passwordChanged, // If password not changed in registry, force change
        );
        
        // Save to employees box
        await employeesBox.put(newEmployee.id, newEmployee.toJson());
        
        // Save current user
        await _saveCurrentUser(newEmployee);
        
        return newEmployee;
      }
    }
    
    return null; // Employee not found or wrong password
  }

  // Save current user to auth box
  Future<void> _saveCurrentUser(Employee employee) async {
    final authBox = await Hive.openBox(_authBoxName);
    await authBox.put(_currentUserKey, employee.toJson());
  }

  // Get current logged-in user
  Future<Employee?> getCurrentUser() async {
    final authBox = await Hive.openBox(_authBoxName);
    final userData = authBox.get(_currentUserKey);
    
    if (userData != null) {
      return Employee.fromJson(Map<String, dynamic>.from(userData));
    }
    
    return null;
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final user = await getCurrentUser();
    return user != null;
  }

  // Logout
  Future<void> logout() async {
    final authBox = await Hive.openBox(_authBoxName);
    await authBox.delete(_currentUserKey);
  }

  // Check if current user is a manager (can review others' appraisals)
  Future<bool> isManager() async {
    final user = await getCurrentUser();
    if (user == null) return false;
    
    // A manager is someone who has direct reports
    // Check if anyone reports to this person
    final directReports = await getDirectReports();
    return directReports.isNotEmpty;
  }

  // Get employees who report to current user
  Future<List<Employee>> getDirectReports() async {
    final currentUser = await getCurrentUser();
    if (currentUser == null || _employeesBox == null) return [];
    
    final directReports = <Employee>[];
    final employees = _employeesBox!.values.cast<Map<dynamic, dynamic>>();
    
    for (var employeeData in employees) {
      final employee = Employee.fromJson(Map<String, dynamic>.from(employeeData));
      
      // Check if this employee reports to current user
      if (employee.lineManager == currentUser.designation && 
          employee.id != currentUser.id) {
        directReports.add(employee);
      }
    }
    
    return directReports;
  }

  // Register new employee (for initial setup)
  Future<bool> registerEmployee(Employee employee) async {
    if (_employeesBox == null) {
      await Hive.openBox('employees');
    }
    
    final employeesBox = Hive.box('employees');
    
    // Check if employee number already exists
    final employees = employeesBox.values.cast<Map<dynamic, dynamic>>();
    for (var employeeData in employees) {
      final existingEmployee = Employee.fromJson(Map<String, dynamic>.from(employeeData));
      if (existingEmployee.employeeNumber == employee.employeeNumber) {
        return false; // Employee number already exists
      }
    }
    
    // Save employee
    await employeesBox.put(employee.id, employee.toJson());
    return true;
  }

  // Update employee password and mark as changed
  Future<bool> updatePassword(String employeeNumber, String newPassword) async {
    if (_employeesBox == null) {
      await Hive.openBox('employees');
    }
    
    final employeesBox = Hive.box('employees');
    final employees = employeesBox.values.cast<Map<dynamic, dynamic>>();
    
    for (var employeeData in employees) {
      final employee = Employee.fromJson(Map<String, dynamic>.from(employeeData));
      
      if (employee.employeeNumber == employeeNumber) {
        employee.password = newPassword;
        employee.isFirstLogin = false;
        employee.lastPasswordChange = DateTime.now();
        await employeesBox.put(employee.id, employee.toJson());
        
        // Update Employee Registry to mark password as changed
        final registryEntry = EmployeeRegistryService.getEntry(employeeNumber);
        if (registryEntry != null) {
          final updatedEntry = registryEntry.copyWith(
            passwordChanged: true,
          );
          await EmployeeRegistryService.updateEmployee(employeeNumber, updatedEntry);
        }
        
        // Update current user in auth box if this is the logged-in user
        final currentUser = await getCurrentUser();
        if (currentUser != null && currentUser.employeeNumber == employeeNumber) {
          await _saveCurrentUser(employee);
        }
        
        return true;
      }
    }
    
    return false;
  }
  
  // Change password (verify current password first)
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    final currentUser = await getCurrentUser();
    if (currentUser == null || _employeesBox == null) return false;
    
    // Verify current password
    if (currentUser.password != currentPassword) {
      return false; // Current password is incorrect
    }
    
    // Update password
    return await updatePassword(currentUser.employeeNumber, newPassword);
  }
  
  // Reset password (for forgot password - HR can help)
  Future<String?> resetPasswordToDefault(String employeeNumber) async {
    if (_employeesBox == null) return null;
    
    final employees = _employeesBox!.values.cast<Map<dynamic, dynamic>>();
    
    for (var employeeData in employees) {
      final employee = Employee.fromJson(Map<String, dynamic>.from(employeeData));
      
      if (employee.employeeNumber == employeeNumber) {
        // Generate new temporary password
        final tempPassword = employeeNumber.substring(employeeNumber.length > 4 ? employeeNumber.length - 4 : 0) + '2024';
        employee.password = tempPassword;
        employee.isFirstLogin = true;
        await _employeesBox!.put(employee.id, employee.toJson());
        return tempPassword;
      }
    }
    
    return null;
  }
}
