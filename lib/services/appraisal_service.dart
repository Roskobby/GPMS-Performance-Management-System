import 'package:hive_flutter/hive_flutter.dart';
import '../models/appraisal.dart';
import '../models/appraisal_status.dart';

/// Service to manage appraisal workflow and status transitions
class AppraisalService {
  static Box? _appraisalsBox;
  
  /// Initialize the service
  static Future<void> initialize() async {
    _appraisalsBox = await Hive.openBox('appraisals');
  }
  
  /// Get or create appraisal for employee and year
  Future<Appraisal?> getOrCreateAppraisal({
    required String employeeId,
    required String employeeNumber,
    required String employeeName,
    required int year,
  }) async {
    if (_appraisalsBox == null) await initialize();
    
    final key = '${employeeId}_$year';
    final data = _appraisalsBox!.get(key);
    
    if (data != null) {
      return Appraisal.fromJson(Map<String, dynamic>.from(data));
    }
    
    // Create new appraisal
    final now = DateTime.now();
    final newAppraisal = Appraisal(
      id: key,
      employeeId: employeeId,
      employeeNumber: employeeNumber,
      employeeName: employeeName,
      year: year,
      reviewPeriodStart: DateTime(year, 1, 1),
      reviewPeriodEnd: DateTime(year, 12, 31),
      status: AppraisalStatus.draft,
      behavioralStandardId: '${employeeId}_behavioral_$year',
      goalIds: [],
      professionalDevelopmentId: '${employeeId}_pd_$year',
      createdAt: now,
    );
    
    await _appraisalsBox!.put(key, newAppraisal.toJson());
    return newAppraisal;
  }
  
  /// Get appraisal by key
  Future<Appraisal?> getAppraisal(String employeeId, int year) async {
    if (_appraisalsBox == null) await initialize();
    
    final key = '${employeeId}_$year';
    final data = _appraisalsBox!.get(key);
    
    if (data != null) {
      return Appraisal.fromJson(Map<String, dynamic>.from(data));
    }
    return null;
  }
  
  /// Save appraisal
  Future<void> saveAppraisal(Appraisal appraisal) async {
    if (_appraisalsBox == null) await initialize();
    
    final key = '${appraisal.employeeId}_${appraisal.year}';
    await _appraisalsBox!.put(key, appraisal.toJson());
  }
  
  /// Employee submits self-assessment to manager
  Future<bool> submitToManager(Appraisal appraisal) async {
    if (appraisal.status != AppraisalStatus.draft) {
      return false; // Can only submit from draft
    }
    
    appraisal.status = AppraisalStatus.submittedToManager;
    appraisal.submittedToManagerAt = DateTime.now();
    
    await saveAppraisal(appraisal);
    return true;
  }
  
  /// Manager starts reviewing a subordinate's appraisal
  Future<bool> startManagerReview(Appraisal appraisal, {
    required String managerId,
    required String managerName,
    required String managerNumber,
  }) async {
    if (appraisal.status != AppraisalStatus.submittedToManager &&
        appraisal.status != AppraisalStatus.managerInProgress) {
      return false;
    }
    
    if (appraisal.status == AppraisalStatus.submittedToManager) {
      appraisal.status = AppraisalStatus.managerInProgress;
      appraisal.managerStartedReviewAt = DateTime.now();
      appraisal.reviewedByManagerId = managerId;
      appraisal.reviewedByManagerName = managerName;
      appraisal.reviewedByManagerNumber = managerNumber;
    }
    
    await saveAppraisal(appraisal);
    return true;
  }
  
  /// Manager submits final appraisal to HR
  Future<bool> submitToHR(Appraisal appraisal) async {
    if (appraisal.status != AppraisalStatus.managerInProgress) {
      return false; // Can only submit from manager in progress
    }
    
    appraisal.status = AppraisalStatus.finalSubmittedToHR;
    appraisal.submittedToHRAt = DateTime.now();
    
    await saveAppraisal(appraisal);
    return true;
  }
  
  /// Get all appraisals for a manager's direct reports
  Future<List<Appraisal>> getTeamAppraisals(List<String> employeeIds, int year) async {
    if (_appraisalsBox == null) await initialize();
    
    final appraisals = <Appraisal>[];
    
    for (final employeeId in employeeIds) {
      final appraisal = await getAppraisal(employeeId, year);
      if (appraisal != null) {
        appraisals.add(appraisal);
      }
    }
    
    return appraisals;
  }
  
  /// Get pending appraisals for manager (submitted to manager or in progress)
  Future<List<Appraisal>> getPendingManagerAppraisals(List<String> employeeIds, int year) async {
    final allAppraisals = await getTeamAppraisals(employeeIds, year);
    
    return allAppraisals.where((a) => 
      a.status == AppraisalStatus.submittedToManager ||
      a.status == AppraisalStatus.managerInProgress
    ).toList();
  }
  
  /// Get completed appraisals (submitted to HR)
  Future<List<Appraisal>> getCompletedAppraisals(List<String> employeeIds, int year) async {
    final allAppraisals = await getTeamAppraisals(employeeIds, year);
    
    return allAppraisals.where((a) => 
      a.status == AppraisalStatus.finalSubmittedToHR
    ).toList();
  }
  
  /// Check if employee can edit their appraisal
  bool canEmployeeEdit(Appraisal appraisal) {
    return appraisal.status.isEditableByEmployee;
  }
  
  /// Check if manager can edit appraisal
  bool canManagerEdit(Appraisal appraisal) {
    return appraisal.status.isEditableByManager;
  }
  
  /// Check if appraisal is locked (final submission)
  bool isLocked(Appraisal appraisal) {
    return appraisal.status.isLocked;
  }
}
