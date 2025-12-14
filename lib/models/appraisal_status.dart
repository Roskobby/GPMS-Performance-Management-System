import 'package:flutter/material.dart';

/// Workflow status for performance appraisals
enum AppraisalStatus {
  /// Employee is still working on self-assessment
  draft,
  
  /// Employee has submitted to their line manager for review
  submittedToManager,
  
  /// Manager is currently reviewing and completing their assessment
  managerInProgress,
  
  /// Manager has submitted final appraisal to HR (locked)
  finalSubmittedToHR,
}

/// Extension to provide display text and colors for status
extension AppraisalStatusExtension on AppraisalStatus {
  /// Display text for the status
  String get displayText {
    switch (this) {
      case AppraisalStatus.draft:
        return 'Draft';
      case AppraisalStatus.submittedToManager:
        return 'Submitted to Manager';
      case AppraisalStatus.managerInProgress:
        return 'Manager In Progress';
      case AppraisalStatus.finalSubmittedToHR:
        return 'Submitted to HR';
    }
  }
  
  /// Short label for the status (alias for displayText)
  String get label => displayText;
  
  /// Color object for status
  Color get color => Color(colorValue);
  
  /// Color for status badge
  int get colorValue {
    switch (this) {
      case AppraisalStatus.draft:
        return 0xFF2196F3; // Blue
      case AppraisalStatus.submittedToManager:
        return 0xFFFFC107; // Amber/Yellow
      case AppraisalStatus.managerInProgress:
        return 0xFFFF9800; // Orange
      case AppraisalStatus.finalSubmittedToHR:
        return 0xFF4CAF50; // Green
    }
  }
  
  /// Icon for status
  int get iconCodePoint {
    switch (this) {
      case AppraisalStatus.draft:
        return 0xe3c9; // Icons.edit
      case AppraisalStatus.submittedToManager:
        return 0xe163; // Icons.send
      case AppraisalStatus.managerInProgress:
        return 0xe8f4; // Icons.rate_review
      case AppraisalStatus.finalSubmittedToHR:
        return 0xe5ca; // Icons.check_circle
    }
  }
  
  /// Whether the appraisal is editable by employee
  bool get isEditableByEmployee {
    return this == AppraisalStatus.draft;
  }
  
  /// Whether the appraisal is editable by manager
  bool get isEditableByManager {
    return this == AppraisalStatus.submittedToManager || 
           this == AppraisalStatus.managerInProgress;
  }
  
  /// Whether the appraisal is locked (final submission)
  bool get isLocked {
    return this == AppraisalStatus.finalSubmittedToHR;
  }
  
  /// Convert from string
  static AppraisalStatus fromString(String value) {
    switch (value) {
      case 'draft':
        return AppraisalStatus.draft;
      case 'submittedToManager':
        return AppraisalStatus.submittedToManager;
      case 'managerInProgress':
        return AppraisalStatus.managerInProgress;
      case 'finalSubmittedToHR':
        return AppraisalStatus.finalSubmittedToHR;
      default:
        return AppraisalStatus.draft;
    }
  }
  
  /// Convert to string for storage
  String toStorageString() {
    return toString().split('.').last;
  }
}
