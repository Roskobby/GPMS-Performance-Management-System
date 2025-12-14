import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/appraisal_service.dart';
import '../services/auth_service.dart';
import '../models/appraisal.dart';
import '../models/appraisal_status.dart';
import '../widgets/status_badge.dart';

class TeamAppraisalsScreen extends StatefulWidget {
  const TeamAppraisalsScreen({super.key});

  @override
  State<TeamAppraisalsScreen> createState() => _TeamAppraisalsScreenState();
}

class _TeamAppraisalsScreenState extends State<TeamAppraisalsScreen> {
  final AppraisalService _appraisalService = AppraisalService();
  final AuthService _authService = AuthService();
  List<Appraisal> _teamAppraisals = [];
  List<Appraisal> _filteredAppraisals = [];
  bool _isLoading = true;
  String _searchQuery = '';
  AppraisalStatus? _statusFilter;

  @override
  void initState() {
    super.initState();
    _loadTeamAppraisals();
  }

  Future<void> _loadTeamAppraisals() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<AppProvider>(context, listen: false);
      final currentEmployee = provider.currentEmployee;
      
      if (currentEmployee == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Get direct reports
      final directReports = await _authService.getDirectReports();
      final employeeIds = directReports.map((e) => e.id).toList();
      
      // Get team appraisals
      final year = provider.currentYear;
      final appraisals = await _appraisalService.getTeamAppraisals(employeeIds, year);

      setState(() {
        _teamAppraisals = appraisals;
        _filteredAppraisals = appraisals;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading team appraisals: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterAppraisals() {
    setState(() {
      _filteredAppraisals = _teamAppraisals.where((appraisal) {
        // Search filter
        final searchMatch = _searchQuery.isEmpty ||
            appraisal.employeeName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            appraisal.employeeNumber.toLowerCase().contains(_searchQuery.toLowerCase());

        // Status filter
        final statusMatch = _statusFilter == null || appraisal.status == _statusFilter;

        return searchMatch && statusMatch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Team Appraisals'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by name or employee number...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                    _filterAppraisals();
                  },
                ),
              ),
              // Status Filter
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: _statusFilter == null,
                        onSelected: (selected) {
                          setState(() {
                            _statusFilter = null;
                          });
                          _filterAppraisals();
                        },
                      ),
                      const SizedBox(width: 8),
                      ...AppraisalStatus.values.map((status) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(status.label),
                            selected: _statusFilter == status,
                            onSelected: (selected) {
                              setState(() {
                                _statusFilter = selected ? status : null;
                              });
                              _filterAppraisals();
                            },
                            selectedColor: status.color.withValues(alpha: 0.3),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: _filteredAppraisals.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _searchQuery.isEmpty && _statusFilter == null
                        ? 'No team appraisals found'
                        : 'No appraisals match your search',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  if (_searchQuery.isNotEmpty || _statusFilter != null) ...[
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                          _statusFilter = null;
                        });
                        _filterAppraisals();
                      },
                      child: const Text('Clear Filters'),
                    ),
                  ],
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadTeamAppraisals,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _filteredAppraisals.length,
                itemBuilder: (context, index) {
                  final appraisal = _filteredAppraisals[index];
                  return _AppraisalCard(
                    appraisal: appraisal,
                    onTap: () {
                      // TODO: Navigate to manager review screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Manager review for ${appraisal.employeeName} - Coming in Phase 4'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
    );
  }
}

class _AppraisalCard extends StatelessWidget {
  final Appraisal appraisal;
  final VoidCallback onTap;

  const _AppraisalCard({
    required this.appraisal,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFF3B6BA6),
                    child: Text(
                      appraisal.employeeName.substring(0, 1).toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appraisal.employeeName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          appraisal.employeeNumber,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  StatusBadge(
                    status: appraisal.status,
                    compact: true,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _InfoItem(
                      icon: Icons.calendar_today,
                      label: 'Period',
                      value: '${appraisal.year}',
                    ),
                  ),
                  if (appraisal.submittedToManagerAt != null)
                    Expanded(
                      child: _InfoItem(
                        icon: Icons.schedule,
                        label: 'Submitted',
                        value: _formatDate(appraisal.submittedToManagerAt!),
                      ),
                    ),
                ],
              ),
              if (appraisal.status == AppraisalStatus.submittedToManager) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.notification_important, size: 18, color: Colors.orange),
                      SizedBox(width: 8),
                      Text(
                        'Action Required: Review appraisal',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
