import 'package:flutter/material.dart';
import '../utils/hive_setup.dart';
import '../models/employee.dart';
import '../models/appraisal.dart';
import '../models/appraisal_status.dart';
import '../services/appraisal_service.dart';

class AppProvider extends ChangeNotifier {
  Employee? _currentEmployee;
  int _currentYear = DateTime.now().year;
  Appraisal? _currentAppraisal;
  final AppraisalService _appraisalService = AppraisalService();
  
  Employee? get currentEmployee => _currentEmployee;
  int get currentYear => _currentYear;
  Appraisal? get currentAppraisal => _currentAppraisal;
  
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
    await _loadOrCreateAppraisal();
    notifyListeners();
  }
  
  /// Load or create appraisal for current employee and year
  Future<void> _loadOrCreateAppraisal() async {
    if (_currentEmployee == null) return;
    
    _currentAppraisal = await _appraisalService.getOrCreateAppraisal(
      employeeId: _currentEmployee!.id,
      employeeNumber: _currentEmployee!.employeeNumber,
      employeeName: _currentEmployee!.name,
      year: _currentYear,
    );
    notifyListeners();
  }
  
  /// Get current appraisal status
  AppraisalStatus? get currentAppraisalStatus => _currentAppraisal?.status;
  
  /// Check if current appraisal can be edited by employee
  bool get canEmployeeEdit => _currentAppraisal != null && 
      _appraisalService.canEmployeeEdit(_currentAppraisal!);
  
  /// Check if current appraisal is locked
  bool get isAppraisalLocked => _currentAppraisal != null && 
      _appraisalService.isLocked(_currentAppraisal!);
  
  /// Submit appraisal to manager
  Future<bool> submitToManager() async {
    if (_currentAppraisal == null) return false;
    
    final success = await _appraisalService.submitToManager(_currentAppraisal!);
    if (success) {
      await _loadOrCreateAppraisal();
    }
    return success;
  }
  
  /// Refresh appraisal from storage
  Future<void> refreshAppraisal() async {
    await _loadOrCreateAppraisal();
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
