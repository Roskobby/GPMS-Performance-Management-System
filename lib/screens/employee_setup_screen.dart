import 'package:flutter/material.dart';
import '../models/employee.dart';
import '../services/auth_service.dart';
import '../services/employee_registry_service.dart';
import '../utils/gpms_org_structure.dart';

class EmployeeSetupScreen extends StatefulWidget {
  const EmployeeSetupScreen({super.key});

  @override
  State<EmployeeSetupScreen> createState() => _EmployeeSetupScreenState();
}

class _EmployeeSetupScreenState extends State<EmployeeSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _employeeNumberController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  String? _selectedDepartment;
  String? _selectedDesignation;
  String? _selectedJobGrade;
  String? _selectedLineManager;
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _employeeNumberVerified = false;

  @override
  void dispose() {
    _employeeNumberController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _verifyEmployeeNumber() {
    final empNumber = _employeeNumberController.text.trim();
    if (empNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your employee number'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final entry = EmployeeRegistryService.getEntry(empNumber);
    
    setState(() {
      _employeeNumberVerified = entry != null;
      
      if (entry != null) {
        // Auto-populate from registry
        _selectedDepartment = entry.department;
        _selectedDesignation = entry.designation;
        _selectedLineManager = entry.lineManager;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ Verified: ${entry.designation} - ${entry.department}'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        _selectedDepartment = null;
        _selectedDesignation = null;
        _selectedLineManager = null;
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Employee number not found in registry. Please contact HR.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }
    });
  }



  Future<void> _saveEmployee() async {
    if (!_formKey.currentState!.validate()) return;

    // Create employee object
    final employee = Employee(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      employeeNumber: _employeeNumberController.text.trim(),
      name: _nameController.text.trim(),
      department: _selectedDepartment!,
      jobGrade: _selectedJobGrade!,
      designation: _selectedDesignation!,
      lineManager: _selectedLineManager!,
      email: _emailController.text.trim().isNotEmpty 
          ? _emailController.text.trim() 
          : null,
      password: _passwordController.text,
    );

    // Register employee
    final authService = AuthService();
    final success = await authService.registerEmployee(employee);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Employee registered successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Navigate back or to login
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Employee number already exists'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Registration'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // GPMS Logo
                Center(
                  child: Image.asset(
                    'assets/icons/gpms_logo.png',
                    height: 60,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Info Card
                Card(
                  color: Colors.blue.shade50,
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: Color(0xFF3B6BA6)),
                            SizedBox(width: 8),
                            Text(
                              'Employee Registration',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF3B6BA6),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          '1. Enter your Employee Number (provided by HR)\n'
                          '2. Click "Verify" to check the employee registry\n'
                          '3. Your department, role, and line manager will be auto-populated\n'
                          '4. Select your job grade (M1-M7)\n'
                          '5. Complete your profile and set a password',
                          style: TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Employee Number
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _employeeNumberController,
                        decoration: InputDecoration(
                          labelText: 'Employee Number *',
                          hintText: 'Enter your employee number',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.badge),
                          suffixIcon: _employeeNumberVerified
                              ? const Icon(Icons.check_circle, color: Colors.green)
                              : null,
                        ),
                        enabled: !_employeeNumberVerified,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter employee number';
                          }
                          if (!_employeeNumberVerified) {
                            return 'Please verify employee number';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _employeeNumberVerified ? null : _verifyEmployeeNumber,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      ),
                      child: Text(_employeeNumberVerified ? 'Verified' : 'Verify'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Full Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name *',
                    hintText: 'Enter your full name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Email (Optional)
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email (Optional)',
                    hintText: 'Enter your email address',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                
                // Department (read-only if from registry)
                TextFormField(
                  initialValue: _selectedDepartment,
                  decoration: InputDecoration(
                    labelText: 'Department *',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.business),
                    helperText: _employeeNumberVerified 
                        ? 'Auto-populated from employee registry'
                        : 'Verify employee number first',
                  ),
                  enabled: false,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please verify employee number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Designation/Role (read-only if from registry)
                TextFormField(
                  initialValue: _selectedDesignation,
                  decoration: InputDecoration(
                    labelText: 'Designation/Role *',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.work),
                    helperText: _employeeNumberVerified
                        ? 'Auto-populated from employee registry'
                        : 'Verify employee number first',
                  ),
                  enabled: false,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please verify employee number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Job Grade (Selectable - M1 to M7)
                DropdownButtonFormField<String>(
                  value: _selectedJobGrade,
                  decoration: const InputDecoration(
                    labelText: 'Job Grade *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.grade),
                    helperText: 'Select your job grade (M1 lowest to M7 highest)',
                  ),
                  items: GPMSOrgStructure.jobGrades
                      .map((grade) => DropdownMenuItem(
                            value: grade,
                            child: Text(grade),
                          ))
                      .toList(),
                  onChanged: _employeeNumberVerified
                      ? (value) {
                          setState(() {
                            _selectedJobGrade = value;
                          });
                        }
                      : null,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a job grade';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Line Manager (read-only if from registry)
                TextFormField(
                  initialValue: _selectedLineManager,
                  decoration: InputDecoration(
                    labelText: 'Line Manager/Supervisor *',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.supervisor_account),
                    helperText: _employeeNumberVerified
                        ? 'Auto-populated from employee registry'
                        : 'Verify employee number first',
                  ),
                  enabled: false,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please verify employee number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                
                // Password Section Header
                const Divider(),
                const Text(
                  'Set Your Password',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3B6BA6),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password *',
                    hintText: 'Enter your password',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Confirm Password
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password *',
                    hintText: 'Re-enter your password',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                
                // Submit Button
                ElevatedButton(
                  onPressed: _saveEmployee,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Register Employee',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
