import 'package:flutter/material.dart';
import '../utils/hive_setup.dart';
import '../models/employee.dart';

class AppProvider extends ChangeNotifier {
  Employee? _currentEmployee;
  int _currentYear = DateTime.now().year;
  
  Employee? get currentEmployee => _currentEmployee;
  int get currentYear => _currentYear;
  
  AppProvider() {
    _loadCurrentEmployee();
  }
  
  Future<void> _loadCurrentEmployee() async {
    final box = HiveSetup.employeesBox;
    final savedEmployee = box.get('current_employee');
    
    if (savedEmployee != null) {
      _currentEmployee = Employee.fromJson(Map<String, dynamic>.from(savedEmployee));
      notifyListeners();
    }
  }
  
  Future<void> setCurrentEmployee(Employee employee) async {
    _currentEmployee = employee;
    await HiveSetup.employeesBox.put('current_employee', employee.toJson());
    notifyListeners();
  }
  
  void setCurrentYear(int year) {
    _currentYear = year;
    notifyListeners();
  }
  
  // Helper method to ensure employee is logged in
  void _ensureEmployeeLoggedIn() {
    if (_currentEmployee == null) {
      throw StateError('No employee is currently logged in');
    }
  }
  
  // Helper method to get storage key for current employee and year
  String _getStorageKey() {
    _ensureEmployeeLoggedIn();
    return '${_currentEmployee!.id}_$_currentYear';
  }
  
  // Get or create employee goals for the year
  Future<List<Map<String, dynamic>>> getGoals() async {
    final box = HiveSetup.goalsBox;
    final key = _getStorageKey();
    final goals = box.get(key);
    
    if (goals == null) {
      return [];
    }
    
    return List<Map<String, dynamic>>.from(goals);
  }
  
  Future<void> saveGoals(List<Map<String, dynamic>> goals) async {
    final box = HiveSetup.goalsBox;
    final key = _getStorageKey();
    await box.put(key, goals);
    notifyListeners();
  }
  
  // Get feedback for employee
  Future<List<Map<String, dynamic>>> getFeedback() async {
    final box = HiveSetup.feedbackBox;
    final key = _getStorageKey();
    final feedback = box.get(key);
    
    if (feedback == null) {
      return [];
    }
    
    return List<Map<String, dynamic>>.from(feedback);
  }
  
  Future<void> saveFeedback(Map<String, dynamic> feedback) async {
    final box = HiveSetup.feedbackBox;
    final key = _getStorageKey();
    final feedbackList = await getFeedback();
    feedbackList.add(feedback);
    await box.put(key, feedbackList);
    notifyListeners();
  }
  
  // Get behavioral standards
  Future<Map<String, dynamic>?> getBehavioralStandards() async {
    final box = HiveSetup.behavioralStandardsBox;
    final key = _getStorageKey();
    final data = box.get(key);
    
    if (data == null) {
      return null;
    }
    
    return Map<String, dynamic>.from(data);
  }
  
  Future<void> saveBehavioralStandards(Map<String, dynamic> standards) async {
    final box = HiveSetup.behavioralStandardsBox;
    final key = _getStorageKey();
    await box.put(key, standards);
    notifyListeners();
  }
  
  // Get professional development
  Future<Map<String, dynamic>?> getProfessionalDevelopment() async {
    final box = HiveSetup.professionalDevelopmentBox;
    final key = _getStorageKey();
    final data = box.get(key);
    
    if (data == null) {
      return null;
    }
    
    return Map<String, dynamic>.from(data);
  }
  
  Future<void> saveProfessionalDevelopment(Map<String, dynamic> development) async {
    final box = HiveSetup.professionalDevelopmentBox;
    final key = _getStorageKey();
    await box.put(key, development);
    notifyListeners();
  }
  
  // Get appraisal
  Future<Map<String, dynamic>?> getAppraisal() async {
    final box = HiveSetup.appraisalsBox;
    final key = _getStorageKey();
    final data = box.get(key);
    
    if (data == null) {
      return null;
    }
    
    return Map<String, dynamic>.from(data);
  }
  
  Future<void> saveAppraisal(Map<String, dynamic> appraisal) async {
    final box = HiveSetup.appraisalsBox;
    final key = _getStorageKey();
    await box.put(key, appraisal);
    notifyListeners();
  }
}
