import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/auth_service.dart';
import 'employee_setup_screen.dart';
import 'goal_setting_screen.dart';
import 'feedback_screen.dart';
import 'behavioral_assessment_screen.dart';
import 'kpi_review_screen.dart';
import 'final_appraisal_screen.dart';
import 'change_password_screen.dart';
import 'login_screen.dart';
import 'help_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardTab(),
    const AppraisalsTab(),
    const ProfileTab(),
    const SettingsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.assessment_outlined),
            selectedIcon: Icon(Icons.assessment),
            label: 'Appraisals',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final employee = provider.currentEmployee;

    if (employee == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icons/gpms_logo.png',
              width: 250,
              height: 120,
            ),
            const SizedBox(height: 32),
            const Text(
              'GPMS Performance Review',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF3B6BA6)),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ghana Petroleum Mooring Systems',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            const Text('Please set up your employee profile to begin'),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EmployeeSetupScreen()),
                );
              },
              icon: const Icon(Icons.person_add),
              label: const Text('Setup Profile'),
            ),
          ],
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 220,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              'Hello, ${employee.name.split(' ')[0]}',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF3B6BA6), // GPMS Blue
                    Color(0xFF2C5282),
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/icons/gpms_logo.png',
                      width: 120,
                      height: 60,
                    ),
                    const SizedBox(height: 12),
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 40, color: Color(0xFF3B6BA6)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      employee.designation,
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Performance Summary Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Performance Summary ${provider.currentYear}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Expanded(
                              child: _PerformanceIndicator(
                                label: 'Behavioral',
                                percentage: 0.0,
                                color: Color(0xFF3B6BA6), // GPMS Blue
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: _PerformanceIndicator(
                                label: 'KPI',
                                percentage: 0.0,
                                color: Color(0xFFE67E22), // GPMS Orange
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Performance Cycle Sections
                Text(
                  'Performance Cycle',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),

                // Beginning of Year
                _SectionCard(
                  title: 'Beginning of Year',
                  icon: Icons.flag,
                  color: const Color(0xFFE67E22), // GPMS Orange
                  items: [
                    _ActionItem(
                      title: 'Goal Setting',
                      subtitle: 'Establish clear, measurable objectives',
                      icon: Icons.track_changes,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const GoalSettingScreen()),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Throughout the Year
                _SectionCard(
                  title: 'Throughout the Year',
                  icon: Icons.timeline,
                  color: const Color(0xFF3B6BA6), // GPMS Blue
                  items: [
                    _ActionItem(
                      title: 'Continuous Feedback',
                      subtitle: 'Regular feedback sessions & progress tracking',
                      icon: Icons.feedback,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const FeedbackScreen()),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // End of Year
                _SectionCard(
                  title: 'End of Year',
                  icon: Icons.assessment,
                  color: const Color(0xFF2C5282), // Dark GPMS Blue
                  items: [
                    _ActionItem(
                      title: 'Behavioral Assessment',
                      subtitle: '30% - 27 performance standards',
                      icon: Icons.psychology,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const BehavioralAssessmentScreen()),
                        );
                      },
                    ),
                    _ActionItem(
                      title: 'KPI Review',
                      subtitle: '70% - Goal achievements & deliverables',
                      icon: Icons.show_chart,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const KPIReviewScreen()),
                        );
                      },
                    ),
                    _ActionItem(
                      title: 'Final Appraisal',
                      subtitle: 'Complete performance review & rating',
                      icon: Icons.done_all,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const FinalAppraisalScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PerformanceIndicator extends StatelessWidget {
  final String label;
  final double percentage;
  final Color color;

  const _PerformanceIndicator({
    required this.label,
    required this.percentage,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                value: percentage / 100,
                strokeWidth: 8,
                backgroundColor: color.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
            Text(
              '${percentage.toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<Widget> items;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...items,
          ],
        ),
      ),
    );
  }
}

class _ActionItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Icon(icon, color: Theme.of(context).colorScheme.primary),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

// Placeholder tabs
class AppraisalsTab extends StatelessWidget {
  const AppraisalsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Appraisals History'));
  }
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final employee = provider.currentEmployee;

    if (employee == null) {
      return const Center(child: Text('No profile set up'));
    }

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Center(
          child: CircleAvatar(
            radius: 60,
            child: Icon(Icons.person, size: 60),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          employee.name,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        Text(
          employee.designation,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),
        ),
        const SizedBox(height: 32),
        _ProfileInfoCard(
          title: 'Department',
          value: employee.department,
          icon: Icons.business,
        ),
        _ProfileInfoCard(
          title: 'Job Grade',
          value: employee.jobGrade,
          icon: Icons.grade,
        ),
        _ProfileInfoCard(
          title: 'Line Manager',
          value: employee.lineManager,
          icon: Icons.supervisor_account,
        ),
        _ProfileInfoCard(
          title: 'Email',
          value: employee.email ?? 'Not provided',
          icon: Icons.email,
        ),
      ],
    );
  }
}

class _ProfileInfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _ProfileInfoCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        subtitle: Text(value, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Text(
          'Settings',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 24),
        Card(
          child: ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Review Year'),
            subtitle: Text('Current: ${provider.currentYear}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Show year picker
            },
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.help_outline, color: Color(0xFFE67E22)),
            title: const Text('Performance Review Guide'),
            subtitle: const Text('Instructions and guidelines'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HelpScreen()),
              );
            },
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.lock, color: Color(0xFF3B6BA6)),
            title: const Text('Change Password'),
            subtitle: const Text('Update your account password'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ChangePasswordScreen(isFirstTimeLogin: false),
                ),
              );
            },
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout'),
            subtitle: const Text('Sign out of your account'),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirm Logout'),
                  content: const Text('Are you sure you want to log out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
              
              if (confirm == true && context.mounted) {
                await AuthService().logout();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              }
            },
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'GPMS Performance Management System',
                applicationVersion: '1.0.0',
                applicationIcon: Image.asset(
                  'assets/icons/gpms_logo.png',
                  width: 100,
                  height: 50,
                ),
                children: const [
                  Text('Ghana Petroleum Mooring Systems Limited'),
                  SizedBox(height: 8),
                  Text('Complete Performance Management & Appraisal System'),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
