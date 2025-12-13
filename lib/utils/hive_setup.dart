import 'package:hive_flutter/hive_flutter.dart';

class HiveSetup {
  static Future<void> initialize() async {
    await Hive.initFlutter();
    
    // Register adapters would go here if using TypeAdapters
    // For now, we'll use simple Maps for storage
    
    // Open boxes
    await Hive.openBox('employees');
    await Hive.openBox('goals');
    await Hive.openBox('feedback');
    await Hive.openBox('behavioral_standards');
    await Hive.openBox('professional_development');
    await Hive.openBox('appraisals');
    await Hive.openBox('app_settings');
  }
  
  static Box<dynamic> get employeesBox => Hive.box('employees');
  static Box<dynamic> get goalsBox => Hive.box('goals');
  static Box<dynamic> get feedbackBox => Hive.box('feedback');
  static Box<dynamic> get behavioralStandardsBox => Hive.box('behavioral_standards');
  static Box<dynamic> get professionalDevelopmentBox => Hive.box('professional_development');
  static Box<dynamic> get appraisalsBox => Hive.box('appraisals');
  static Box<dynamic> get appSettingsBox => Hive.box('app_settings');
}
