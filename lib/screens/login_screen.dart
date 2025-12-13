import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../providers/app_provider.dart';
import 'home_screen.dart';
import 'developer_admin_panel.dart';
import 'change_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _employeeNumberController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  int _logoTapCount = 0;

  @override
  void dispose() {
    _employeeNumberController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final employee = await _authService.login(
        _employeeNumberController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (employee != null) {
        // Update AppProvider with logged-in employee
        final appProvider = Provider.of<AppProvider>(context, listen: false);
        await appProvider.setCurrentEmployee(employee);
        
        if (!mounted) return;
        
        // Check if first-time login - force password change
        if (employee.isFirstLogin) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const ChangePasswordScreen(
                isFirstTimeLogin: true,
              ),
            ),
          );
        } else {
          // Normal login - go to home
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      } else {
        // Login failed
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid employee number or password'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showDeveloperLogin() {
    showDialog(
      context: context,
      builder: (context) => _DeveloperLoginDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                // GPMS Logo (tap 7 times to access developer panel)
                Center(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _logoTapCount++;
                      });
                      if (_logoTapCount >= 7) {
                        _logoTapCount = 0;
                        _showDeveloperLogin();
                      }
                    },
                    child: Image.asset(
                      'assets/icons/gpms_logo.png',
                      height: 80,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // App Title
                const Text(
                  'GPMS Performance\nManagement System',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3B6BA6),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Employee Login',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 48),
                // Login Form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Employee Number Field
                      TextFormField(
                        controller: _employeeNumberController,
                        decoration: InputDecoration(
                          labelText: 'Employee Number',
                          prefixIcon: const Icon(Icons.badge, color: Color(0xFF3B6BA6)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF3B6BA6), width: 2),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your employee number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock, color: Color(0xFF3B6BA6)),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF3B6BA6), width: 2),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),
                      // Login Button
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3B6BA6),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Help Text for Employees
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Need access?',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Contact HR to get your Employee Number & Password',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DeveloperLoginDialog extends StatefulWidget {
  @override
  State<_DeveloperLoginDialog> createState() => _DeveloperLoginDialogState();
}

class _DeveloperLoginDialogState extends State<_DeveloperLoginDialog> {
  final _passwordController = TextEditingController();
  final _devPassword = 'gpmsadmin2024'; // Change this to your secure password

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _authenticate() {
    if (_passwordController.text == _devPassword) {
      Navigator.of(context).pop();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const DeveloperAdminPanel(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Incorrect developer password'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.admin_panel_settings, color: Color(0xFF3B6BA6)),
          SizedBox(width: 8),
          Text('Developer Access'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Enter developer password to access admin panel:'),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Developer Password',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.lock),
            ),
            onSubmitted: (_) => _authenticate(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _authenticate,
          child: const Text('Access'),
        ),
      ],
    );
  }
}
