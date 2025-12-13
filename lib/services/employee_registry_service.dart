import 'package:hive/hive.dart';
import '../models/employee_registry.dart';

/// Employee Registry Service
/// Manages persistent storage of employee registry data using Hive
class EmployeeRegistryService {
  static const String _boxName = 'employee_registry';
  
  /// Initialize the employee registry box
  static Future<void> initialize() async {
    try {
      if (!Hive.isBoxOpen(_boxName)) {
        await Hive.openBox(_boxName);
      }
      
      // Check if registry is empty, populate with sample data
      final box = Hive.box(_boxName);
      if (box.isEmpty) {
        await _populateSampleData();
      }
    } catch (e) {
      // Silently handle initialization errors - box might already be open
      if (!Hive.isBoxOpen(_boxName)) {
        rethrow;
      }
    }
  }
  
  /// Get the registry box - ensure it's open
  static Future<Box> get _boxAsync async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox(_boxName);
    }
    return Hive.box(_boxName);
  }
  
  /// Get the registry box (synchronous, assumes already open)
  static Box get _box => Hive.box(_boxName);
  
  /// Get employee registry entry by employee number
  static EmployeeRegistryEntry? getEntry(String employeeNumber) {
    final data = _box.get(employeeNumber.toUpperCase());
    if (data == null) return null;
    return EmployeeRegistryEntry.fromJson(Map<String, dynamic>.from(data));
  }
  
  /// Check if employee number exists
  static bool exists(String employeeNumber) {
    return _box.containsKey(employeeNumber.toUpperCase());
  }
  
  /// Get all employee registry entries
  static List<EmployeeRegistryEntry> getAllEntries() {
    final entries = <EmployeeRegistryEntry>[];
    for (var key in _box.keys) {
      final data = _box.get(key);
      if (data != null) {
        entries.add(EmployeeRegistryEntry.fromJson(Map<String, dynamic>.from(data)));
      }
    }
    entries.sort((a, b) => a.employeeNumber.compareTo(b.employeeNumber));
    return entries;
  }
  
  /// Get all employee numbers
  static List<String> getAllEmployeeNumbers() {
    return _box.keys.cast<String>().toList()..sort();
  }
  
  /// Add new employee to registry
  static Future<void> addEmployee(EmployeeRegistryEntry entry) async {
    final box = await _boxAsync;
    await box.put(entry.employeeNumber.toUpperCase(), entry.toJson());
  }
  
  /// Update employee registry entry
  static Future<void> updateEmployee(String employeeNumber, EmployeeRegistryEntry entry) async {
    final box = await _boxAsync;
    await box.put(employeeNumber.toUpperCase(), entry.toJson());
  }
  
  /// Delete employee from registry
  static Future<void> deleteEmployee(String employeeNumber) async {
    final box = await _boxAsync;
    await box.delete(employeeNumber.toUpperCase());
  }
  
  /// Get employees by department
  static List<EmployeeRegistryEntry> getEmployeesByDepartment(String department) {
    return getAllEntries()
        .where((entry) => entry.department == department)
        .toList();
  }
  
  /// Get employees by line manager
  static List<EmployeeRegistryEntry> getEmployeesByLineManager(String lineManager) {
    return getAllEntries()
        .where((entry) => entry.lineManager == lineManager)
        .toList();
  }
  
  /// Clear all registry data (use with caution!)
  static Future<void> clearAll() async {
    final box = await _boxAsync;
    await box.clear();
  }
  
  /// Get total count
  static int getCount() {
    return _box.length;
  }
  
  /// Bulk import employees
  static Future<int> bulkImport(List<EmployeeRegistryEntry> entries) async {
    int count = 0;
    for (var entry in entries) {
      await addEmployee(entry);
      count++;
    }
    return count;
  }
  
  /// Export all data as JSON
  static Map<String, dynamic> exportData() {
    final data = <String, dynamic>{};
    for (var key in _box.keys) {
      data[key] = _box.get(key);
    }
    return data;
  }
  
  /// Populate with sample data (for first-time setup)
  static Future<void> _populateSampleData() async {
    final sampleData = [
      // HR & Admin Department
      EmployeeRegistryEntry(
        employeeNumber: 'GM001',
        name: 'John Smith',
        designation: 'General Manager',
        jobGrade: 'M7',
        department: 'HR & Admin',
        lineManager: 'Board of Directors',
        email: 'gm@gpms.com',
        // initialPassword will be auto-generated if not provided
      ),
      EmployeeRegistryEntry(
        employeeNumber: 'HR001',
        name: 'Sarah Johnson',
        designation: 'HR & Admin Manager',
        jobGrade: 'M6',
        department: 'HR & Admin',
        lineManager: 'General Manager',
        email: 'hr.manager@gpms.com',
      ),
      EmployeeRegistryEntry(
        employeeNumber: 'HR002',
        name: 'Michael Brown',
        designation: 'HR & Admin Officer',
        jobGrade: 'M4',
        department: 'HR & Admin',
        lineManager: 'HR & Admin Manager',
        email: null,
      ),
      
      // QHSSE Department
      EmployeeRegistryEntry(
        employeeNumber: 'QHSSE001',
        name: 'David Wilson',
        designation: 'QHSSE Manager',
        jobGrade: 'M6',
        department: 'QHSSE',
        lineManager: 'General Manager',
        email: 'qhsse.manager@gpms.com',
      ),
      EmployeeRegistryEntry(
        employeeNumber: 'QHSSE002',
        name: 'Emily Davis',
        designation: 'QHSSE Advisors',
        jobGrade: 'M4',
        department: 'QHSSE',
        lineManager: 'QHSSE Manager',
        email: null,
      ),
      
      // Finance Department
      EmployeeRegistryEntry(
        employeeNumber: 'FIN001',
        name: 'Robert Taylor',
        designation: 'Finance Manager',
        jobGrade: 'M6',
        department: 'Finance',
        lineManager: 'General Manager',
        email: 'finance.manager@gpms.com',
      ),
      EmployeeRegistryEntry(
        employeeNumber: 'FIN002',
        name: 'Lisa Anderson',
        designation: 'Senior Finance Officer',
        jobGrade: 'M5',
        department: 'Finance',
        lineManager: 'Finance Manager',
        email: 'lisa.anderson@gpms.com',
      ),
      EmployeeRegistryEntry(
        employeeNumber: 'IT001',
        name: 'James Martinez',
        designation: 'IT Officer',
        jobGrade: 'M4',
        department: 'Finance',
        lineManager: 'Finance Manager',
        email: 'it@gpms.com',
      ),
      
      // Operations & Maintenance Department
      EmployeeRegistryEntry(
        employeeNumber: 'OPS001',
        name: 'William Garcia',
        designation: 'Ops. & Maint. Manager',
        jobGrade: 'M6',
        department: 'Operations & Maintenance',
        lineManager: 'General Manager',
        email: 'ops.manager@gpms.com',
      ),
      EmployeeRegistryEntry(
        employeeNumber: 'OPS002',
        name: 'Thomas Rodriguez',
        designation: 'Operations Supervisors',
        jobGrade: 'M3',
        department: 'Operations & Maintenance',
        lineManager: 'Ops. & Maint. Manager',
        email: null,
      ),
    ];
    
    await bulkImport(sampleData);
  }
}
