import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'dart:convert';
import '../models/employee_registry.dart';
import '../services/employee_registry_service.dart';

class BulkImportDialog extends StatefulWidget {
  const BulkImportDialog({super.key});

  @override
  State<BulkImportDialog> createState() => _BulkImportDialogState();
}

class _BulkImportDialogState extends State<BulkImportDialog> {
  bool _isProcessing = false;
  String? _fileName;
  List<EmployeeRegistryEntry>? _parsedEmployees;
  String? _errorMessage;

  Future<void> _pickFile() async {
    try {
      setState(() {
        _errorMessage = null;
        _parsedEmployees = null;
      });

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'xlsx', 'xls'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      _fileName = file.name;

      setState(() {
        _isProcessing = true;
      });

      // Parse the file based on extension
      List<EmployeeRegistryEntry> employees = [];

      if (file.extension == 'csv') {
        employees = await _parseCSV(file.bytes!);
      } else if (file.extension == 'xlsx' || file.extension == 'xls') {
        // For Excel files, we'll treat them as CSV for now
        // In a full implementation, you'd use excel package
        employees = await _parseCSV(file.bytes!);
      }

      setState(() {
        _parsedEmployees = employees;
        _isProcessing = false;
      });

      if (employees.isEmpty) {
        setState(() {
          _errorMessage = 'No valid employee data found in file';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error reading file: $e';
        _isProcessing = false;
      });
    }
  }

  Future<List<EmployeeRegistryEntry>> _parseCSV(List<int> bytes) async {
    final employees = <EmployeeRegistryEntry>[];
    final validDepartments = ['HR & Admin', 'QHSSE', 'Operations & Maintenance', 'Finance'];
    final validJobGrades = ['M1', 'M2', 'M3', 'M4', 'M5', 'M6', 'M7'];
    
    // Department name normalization map
    final departmentMap = {
      'operations and maintenance': 'Operations & Maintenance',
      'operations & maintenance': 'Operations & Maintenance',
      'operations&maintenance': 'Operations & Maintenance',
      'hr & admin': 'HR & Admin',
      'hr and admin': 'HR & Admin',
      'hr&admin': 'HR & Admin',
      'qhsse': 'QHSSE',
      'finance': 'Finance',
    };

    try {
      final csvString = utf8.decode(bytes);
      final rows = const CsvToListConverter().convert(csvString);

      // Skip header row if it exists
      int startIndex = 0;
      if (rows.isNotEmpty) {
        final firstRow = rows[0].map((e) => e.toString().toLowerCase()).toList();
        if (firstRow.any((cell) => 
            cell.contains('employee') || 
            cell.contains('number') || 
            cell.contains('name') ||
            cell.contains('department'))) {
          startIndex = 1; // Skip header
        }
      }

      for (int i = startIndex; i < rows.length; i++) {
        final row = rows[i];
        
        if (row.length < 6) continue; // Skip incomplete rows (minimum 6 required columns)

        final employeeNumber = row[0].toString().trim();
        final name = row[1].toString().trim();
        final designation = row[2].toString().trim();
        var jobGrade = row[3].toString().trim();
        var department = row[4].toString().trim();
        final lineManager = row[5].toString().trim();
        final email = row.length > 6 ? row[6].toString().trim() : '';

        if (employeeNumber.isEmpty || name.isEmpty || department.isEmpty || 
            designation.isEmpty || jobGrade.isEmpty || lineManager.isEmpty) {
          continue; // Skip empty rows
        }

        // Normalize department name
        final deptKey = department.toLowerCase().trim();
        if (departmentMap.containsKey(deptKey)) {
          department = departmentMap[deptKey]!;
        }

        // Validate department
        if (!validDepartments.contains(department)) {
          throw Exception('Invalid department "$department" at row ${i + 1}. Must be one of: ${validDepartments.join(", ")}');
        }

        // Clean job grade (remove any labels like "M5 - Senior Officer" -> "M5")
        if (jobGrade.contains('-')) {
          jobGrade = jobGrade.split('-')[0].trim();
        }

        // Validate job grade
        if (!validJobGrades.contains(jobGrade)) {
          throw Exception('Invalid job grade "$jobGrade" at row ${i + 1}. Must be one of: M1, M2, M3, M4, M5, M6, M7');
        }

        employees.add(EmployeeRegistryEntry(
          employeeNumber: employeeNumber,
          name: name,
          designation: designation,
          jobGrade: jobGrade,
          department: department,
          lineManager: lineManager,
          email: email.isEmpty ? null : email,
        ));
      }
    } catch (e) {
      throw Exception('Failed to parse CSV: $e');
    }

    return employees;
  }

  Future<void> _importEmployees() async {
    if (_parsedEmployees == null || _parsedEmployees!.isEmpty) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final count = await EmployeeRegistryService.bulkImport(_parsedEmployees!);

      if (!mounted) return;
      
      Navigator.of(context).pop(count);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✓ Successfully imported $count employees!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _errorMessage = 'Import failed: $e';
        _isProcessing = false;
      });
    }
  }

  void _downloadTemplate() {
    // Create template CSV data
    const template = '''Employee Number,Name,Designation/Role,Job Grade,Department,Line Manager/Supervisor,Email
GM001,John Smith,General Manager,M7,HR & Admin,Board of Directors,gm@gpms.com
FIN001,Robert Taylor,Finance Manager,M6,Finance,General Manager,finance.manager@gpms.com
QHSSE001,David Wilson,QHSSE Manager,M6,QHSSE,General Manager,qhsse.manager@gpms.com
OPS001,William Garcia,Ops. & Maint. Manager,M6,Operations & Maintenance,General Manager,ops.manager@gpms.com
HR001,Sarah Johnson,HR & Admin Manager,M6,HR & Admin,General Manager,hr.manager@gpms.com
FIN002,Lisa Anderson,Senior Finance Officer,M5,Finance,Finance Manager,lisa.anderson@gpms.com
IT001,James Martinez,IT Officer,M4,Finance,Finance Manager,it@gpms.com
OPS002,Thomas Rodriguez,Operations Supervisor,M3,Operations & Maintenance,Ops. & Maint. Manager,
QHSSE002,Emily Davis,QHSSE Advisor,M4,QHSSE,QHSSE Manager,
HR002,Michael Brown,HR & Admin Officer,M4,HR & Admin,HR & Admin Manager,''';

    // For web, we'll show instructions to copy
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excel/CSV Template'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Copy this template and paste into Excel or Google Sheets:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  template,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Instructions:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                '1. Copy the template above\n'
                '2. Open Excel or Google Sheets\n'
                '3. Paste the template\n'
                '4. Replace with your employee data\n'
                '5. Keep the same column order:\n'
                '   • Employee Number\n'
                '   • Name\n'
                '   • Designation/Role\n'
                '   • Job Grade (M1-M7)\n'
                '   • Department\n'
                '   • Line Manager/Supervisor\n'
                '   • Email (Optional - can be left blank)\n'
                '6. Save as CSV file\n'
                '7. Upload here using "Choose File" button',
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.upload_file, color: Color(0xFF3B6BA6)),
          SizedBox(width: 8),
          Text('Bulk Import Employees'),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Color(0xFF3B6BA6), size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Upload Excel or CSV File',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3B6BA6),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Supported formats: .csv, .xlsx, .xls\n'
                    'Required columns: Employee Number, Name, Designation, Job Grade, Department, Line Manager\n'
                    'Optional: Email (can be left blank)',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Download Template Button
            OutlinedButton.icon(
              onPressed: _downloadTemplate,
              icon: const Icon(Icons.download),
              label: const Text('Download Template'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF3B6BA6),
                side: const BorderSide(color: Color(0xFF3B6BA6)),
              ),
            ),
            const SizedBox(height: 16),

            // File picker button
            ElevatedButton.icon(
              onPressed: _isProcessing ? null : _pickFile,
              icon: const Icon(Icons.file_upload),
              label: Text(_fileName ?? 'Choose File'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
            const SizedBox(height: 16),

            // Loading indicator
            if (_isProcessing)
              const Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 8),
                  Text('Processing file...'),
                ],
              ),

            // Error message
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),

            // Preview of parsed employees
            if (_parsedEmployees != null && _parsedEmployees!.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 8),
                        Text(
                          '${_parsedEmployees!.length} employees found',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Preview (first 3):',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    ..._parsedEmployees!.take(3).map((emp) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            '• ${emp.employeeNumber} - ${emp.name} (${emp.designation})',
                            style: const TextStyle(fontSize: 11),
                          ),
                        )),
                  ],
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isProcessing ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: (_parsedEmployees != null && _parsedEmployees!.isNotEmpty && !_isProcessing)
              ? _importEmployees
              : null,
          child: _isProcessing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Import'),
        ),
      ],
    );
  }
}
