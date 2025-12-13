import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:html' as html;
import '../models/employee_registry.dart';
import '../services/employee_registry_service.dart';
import '../utils/gpms_org_structure.dart';
import 'bulk_import_dialog.dart';

class DeveloperAdminPanel extends StatefulWidget {
  const DeveloperAdminPanel({super.key});

  @override
  State<DeveloperAdminPanel> createState() => _DeveloperAdminPanelState();
}

class _DeveloperAdminPanelState extends State<DeveloperAdminPanel> {
  List<EmployeeRegistryEntry> _employees = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      // Add a small delay to ensure Hive is ready
      await Future.delayed(const Duration(milliseconds: 100));
      
      final employees = EmployeeRegistryService.getAllEntries();

      if (mounted) {
        setState(() {
          _employees = employees;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _employees = [];
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading employees: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<EmployeeRegistryEntry> get _filteredEmployees {
    if (_searchQuery.isEmpty) return _employees;
    return _employees
        .where((e) =>
            e.employeeNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            e.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            e.designation.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            e.department.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  Future<void> _showAddEmployeeDialog() async {
    final result = await showDialog<EmployeeRegistryEntry>(
      context: context,
      builder: (context) => const _EmployeeFormDialog(),
    );

    if (result != null) {
      await EmployeeRegistryService.addEmployee(result);
      _loadEmployees();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Employee ${result.employeeNumber} added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _showEditEmployeeDialog(EmployeeRegistryEntry employee) async {
    final result = await showDialog<EmployeeRegistryEntry>(
      context: context,
      builder: (context) => _EmployeeFormDialog(employee: employee),
    );

    if (result != null) {
      await EmployeeRegistryService.updateEmployee(employee.employeeNumber, result);
      _loadEmployees();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Employee ${result.employeeNumber} updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _deleteEmployee(EmployeeRegistryEntry employee) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Employee'),
        content: Text('Are you sure you want to delete ${employee.employeeNumber}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await EmployeeRegistryService.deleteEmployee(employee.employeeNumber);
      _loadEmployees();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Employee ${employee.employeeNumber} deleted'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showBulkImportDialog() async {
    final result = await showDialog<int>(
      context: context,
      builder: (context) => const BulkImportDialog(),
    );
    
    if (result != null) {
      _loadEmployees();
    }
  }

  Future<void> _populateSampleData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Load Sample Data?'),
        content: const Text(
          'This will add 10 sample employees to the registry for testing purposes. '
          'You can delete them later if needed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Load Sample Data'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Show loading indicator
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 16),
              Text('Loading sample data...'),
            ],
          ),
          duration: Duration(seconds: 30),
        ),
      );
    }

    try {
      // Sample employees with all required fields
      final sampleEmployees = [
        EmployeeRegistryEntry(
          employeeNumber: 'GM001',
          name: 'John Smith',
          designation: 'General Manager',
          jobGrade: 'M7',
          department: 'HR & Admin',
          lineManager: 'Board of Directors',
          email: 'gm@gpms.com',
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
          employeeNumber: 'FIN001',
          name: 'Robert Taylor',
          designation: 'Finance Manager',
          jobGrade: 'M6',
          department: 'Finance',
          lineManager: 'General Manager',
          email: 'finance.manager@gpms.com',
        ),
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
          employeeNumber: 'OPS001',
          name: 'William Garcia',
          designation: 'Ops. & Maint. Manager',
          jobGrade: 'M6',
          department: 'Operations & Maintenance',
          lineManager: 'General Manager',
          email: 'ops.manager@gpms.com',
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
        EmployeeRegistryEntry(
          employeeNumber: 'OPS002',
          name: 'Thomas Rodriguez',
          designation: 'Operations Supervisor',
          jobGrade: 'M3',
          department: 'Operations & Maintenance',
          lineManager: 'Ops. & Maint. Manager',
          email: null,
        ),
        EmployeeRegistryEntry(
          employeeNumber: 'QHSSE002',
          name: 'Emily Davis',
          designation: 'QHSSE Advisor',
          jobGrade: 'M4',
          department: 'QHSSE',
          lineManager: 'QHSSE Manager',
          email: null,
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
      ];

      final count = await EmployeeRegistryService.bulkImport(sampleEmployees);
      await _loadEmployees();

      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ Successfully loaded $count sample employees!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading sample data: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _exportData() {
    try {
      // Get all employees
      final employees = EmployeeRegistryService.getAllEntries();
      
      if (employees.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No employees to export'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      
      // Create CSV format
      final csvHeader = 'Employee Number,Name,Designation/Role,Job Grade,Department,Line Manager/Supervisor,Email,Initial Password,Password Changed';
      final csvRows = employees.map((e) {
        return '${e.employeeNumber},'
               '${e.name},'
               '${e.designation},'
               '${e.jobGrade},'
               '${e.department},'
               '${e.lineManager},'
               '${e.email ?? ""},'
               '${e.initialPassword ?? ""},'
               '${e.passwordChanged ? "Yes" : "No"}';
      }).join('\n');
      
      final csvText = '$csvHeader\n$csvRows';
      
      // Download CSV file
      _downloadFile(csvText, 'gpms_employees_${DateTime.now().millisecondsSinceEpoch}.csv');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${employees.length} employee(s) exported! Check your downloads.'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error exporting data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  void _downloadFile(String content, String filename) {
    // For web platform, use HTML download
    // ignore: avoid_web_libraries_in_flutter
    // ignore: undefined_prefixed_name
    final bytes = utf8.encode(content);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..style.display = 'none'
      ..download = filename;
    html.document.body?.children.add(anchor);
    anchor.click();
    html.document.body?.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Developer Admin Panel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            tooltip: 'Bulk Import',
            onPressed: _showBulkImportDialog,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Download CSV File',
            onPressed: _exportData,
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats Card
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(
                    icon: Icons.people,
                    label: 'Total Employees',
                    value: _employees.length.toString(),
                  ),
                  _StatItem(
                    icon: Icons.business,
                    label: 'Departments',
                    value: '4',
                  ),
                  _StatItem(
                    icon: Icons.admin_panel_settings,
                    label: 'Registry',
                    value: 'Active',
                    valueColor: Colors.green,
                  ),
                ],
              ),
            ),
          ),
          
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by name, employee number, role, or department',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          const SizedBox(height: 16),
          
          // Hint for viewing passwords
          if (_employees.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  border: Border.all(color: Colors.blue.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Tap on any employee card to view their initial password',
                        style: TextStyle(
                          color: Colors.blue.shade900,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // Employee List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredEmployees.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.people_outline,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No employees in registry',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Add employees using one of these methods:',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: _populateSampleData,
                              icon: const Icon(Icons.auto_awesome),
                              label: const Text('Load Sample Employees'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: _showAddEmployeeDialog,
                              icon: const Icon(Icons.person_add),
                              label: const Text('Add Single Employee'),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: _showBulkImportDialog,
                              icon: const Icon(Icons.upload_file),
                              label: const Text('Bulk Import (CSV/Excel)'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredEmployees.length,
                        itemBuilder: (context, index) {
                          final employee = _filteredEmployees[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ExpansionTile(
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xFF3B6BA6),
                                child: Text(
                                  employee.employeeNumber.substring(0, 2),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      employee.employeeNumber,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  if (!employee.passwordChanged) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.shade100,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'First Login',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.orange.shade900,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                  const SizedBox(width: 8),
                                  Tooltip(
                                    message: 'Tap to view password',
                                    child: Icon(
                                      Icons.lock_outline,
                                      size: 18,
                                      color: Colors.blue.shade600,
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(employee.name),
                                  Text(employee.designation),
                                  Text(
                                    '${employee.department} • ${employee.jobGrade}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Color(0xFF3B6BA6)),
                                    onPressed: () => _showEditEmployeeDialog(employee),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteEmployee(employee),
                                  ),
                                ],
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Initial Password Section
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade50,
                                          border: Border.all(color: Colors.blue.shade200),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(Icons.lock, size: 16, color: Colors.blue.shade700),
                                                const SizedBox(width: 8),
                                                Text(
                                                  'Initial Password:',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.blue.shade900,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: SelectableText(
                                                    employee.initialPassword,
                                                    style: const TextStyle(
                                                      fontFamily: 'monospace',
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.copy, size: 20),
                                                  onPressed: () {
                                                    Clipboard.setData(ClipboardData(
                                                      text: employee.initialPassword,
                                                    ));
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      const SnackBar(
                                                        content: Text('Password copied to clipboard!'),
                                                        duration: Duration(seconds: 2),
                                                      ),
                                                    );
                                                  },
                                                  tooltip: 'Copy Password',
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              employee.passwordChanged 
                                                  ? '✓ Employee has changed their password'
                                                  : '⚠ Employee must change password on first login',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: employee.passwordChanged 
                                                    ? Colors.green.shade700 
                                                    : Colors.orange.shade700,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      // Additional Info
                                      _buildInfoRow('Line Manager', employee.lineManager),
                                      if (employee.email != null)
                                        _buildInfoRow('Email', employee.email!),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddEmployeeDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Employee'),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF3B6BA6), size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: valueColor ?? Colors.black,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}

class _EmployeeFormDialog extends StatefulWidget {
  final EmployeeRegistryEntry? employee;

  const _EmployeeFormDialog({this.employee});

  @override
  State<_EmployeeFormDialog> createState() => _EmployeeFormDialogState();
}

class _EmployeeFormDialogState extends State<_EmployeeFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _employeeNumberController;
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  String? _selectedDepartment;
  String? _selectedDesignation;
  String? _selectedJobGrade;
  String? _selectedLineManager;

  List<String> _availableRoles = [];
  List<String> _availableLineManagers = [];
  
  final List<String> _jobGrades = [
    'M1',
    'M2',
    'M3',
    'M4',
    'M5',
    'M6',
    'M7',
  ];

  @override
  void initState() {
    super.initState();
    _employeeNumberController = TextEditingController(
      text: widget.employee?.employeeNumber ?? '',
    );
    _nameController = TextEditingController(
      text: widget.employee?.name ?? '',
    );
    _emailController = TextEditingController(
      text: widget.employee?.email ?? '',
    );
    _selectedDepartment = widget.employee?.department;
    _selectedDesignation = widget.employee?.designation;
    _selectedJobGrade = widget.employee?.jobGrade;
    _selectedLineManager = widget.employee?.lineManager;

    if (_selectedDepartment != null) {
      _availableRoles = GPMSOrgStructure.getRolesForDepartment(_selectedDepartment!);
    }
    if (_selectedDepartment != null && _selectedDesignation != null) {
      _availableLineManagers = GPMSOrgStructure.getPotentialLineManagers(
        _selectedDepartment!,
        _selectedDesignation!,
      );
    }
  }

  @override
  void dispose() {
    _employeeNumberController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _onDepartmentChanged(String? department) {
    setState(() {
      _selectedDepartment = department;
      _selectedDesignation = null;
      _selectedLineManager = null;
      _availableRoles = department != null
          ? GPMSOrgStructure.getRolesForDepartment(department)
          : [];
      _availableLineManagers = [];
    });
  }

  void _onDesignationChanged(String? designation) {
    setState(() {
      _selectedDesignation = designation;

      if (designation != null && _selectedDepartment != null) {
        _availableLineManagers = GPMSOrgStructure.getPotentialLineManagers(
          _selectedDepartment!,
          designation,
        );

        if (_availableLineManagers.length == 1) {
          _selectedLineManager = _availableLineManagers.first;
        } else {
          _selectedLineManager = null;
        }
      } else {
        _selectedLineManager = null;
        _availableLineManagers = [];
      }
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final entry = EmployeeRegistryEntry(
      employeeNumber: _employeeNumberController.text.trim().toUpperCase(),
      name: _nameController.text.trim(),
      department: _selectedDepartment!,
      designation: _selectedDesignation!,
      jobGrade: _selectedJobGrade!,
      lineManager: _selectedLineManager!,
      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
    );

    Navigator.of(context).pop(entry);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.employee == null ? 'Add Employee' : 'Edit Employee'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _employeeNumberController,
                decoration: const InputDecoration(
                  labelText: 'Employee Number *',
                  hintText: 'e.g., FIN001',
                  border: OutlineInputBorder(),
                ),
                enabled: widget.employee == null,
                textCapitalization: TextCapitalization.characters,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name *',
                  hintText: 'e.g., John Mensah',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email (Optional)',
                  hintText: 'john.mensah@gpms.com',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedDepartment,
                decoration: const InputDecoration(
                  labelText: 'Department *',
                  border: OutlineInputBorder(),
                ),
                items: GPMSOrgStructure.getDepartmentNames()
                    .map((dept) => DropdownMenuItem(
                          value: dept,
                          child: Text(dept),
                        ))
                    .toList(),
                onChanged: _onDepartmentChanged,
                validator: (value) => value == null ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedDesignation,
                decoration: const InputDecoration(
                  labelText: 'Designation/Role *',
                  border: OutlineInputBorder(),
                ),
                items: _availableRoles
                    .map((role) => DropdownMenuItem(
                          value: role,
                          child: Text(role),
                        ))
                    .toList(),
                onChanged: _availableRoles.isEmpty ? null : _onDesignationChanged,
                validator: (value) => value == null ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedJobGrade,
                decoration: const InputDecoration(
                  labelText: 'Job Grade *',
                  border: OutlineInputBorder(),
                ),
                items: _jobGrades
                    .map((grade) => DropdownMenuItem(
                          value: grade,
                          child: Text(grade),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedJobGrade = value;
                  });
                },
                validator: (value) => value == null ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedLineManager,
                decoration: const InputDecoration(
                  labelText: 'Line Manager *',
                  border: OutlineInputBorder(),
                ),
                items: _availableLineManagers
                    .map((manager) => DropdownMenuItem(
                          value: manager,
                          child: Text(manager),
                        ))
                    .toList(),
                onChanged: _availableLineManagers.isEmpty
                    ? null
                    : (value) {
                        setState(() {
                          _selectedLineManager = value;
                        });
                      },
                validator: (value) => value == null ? 'Required' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}

