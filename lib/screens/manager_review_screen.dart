import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/appraisal_service.dart';
import '../models/appraisal.dart';
import '../models/appraisal_status.dart';
import '../widgets/status_badge.dart';

class ManagerReviewScreen extends StatefulWidget {
  final Appraisal appraisal;

  const ManagerReviewScreen({
    super.key,
    required this.appraisal,
  });

  @override
  State<ManagerReviewScreen> createState() => _ManagerReviewScreenState();
}

class _ManagerReviewScreenState extends State<ManagerReviewScreen> {
  final AppraisalService _appraisalService = AppraisalService();
  late Appraisal _appraisal;
  final TextEditingController _managerCommentsController = TextEditingController();
  bool _isSubmitting = false;
  bool _hasChanges = false;

  List<Map<String, dynamic>> _goals = [];
  List<Map<String, dynamic>> _behavioralStandards = [];

  @override
  void initState() {
    super.initState();
    _appraisal = widget.appraisal;
    _managerCommentsController.text = _appraisal.managerComments ?? '';
    _loadData();
    
    // Mark as "In Progress" when manager opens it
    _startReview();
  }

  Future<void> _startReview() async {
    if (_appraisal.status == AppraisalStatus.submittedToManager) {
      final provider = Provider.of<AppProvider>(context, listen: false);
      final manager = provider.currentEmployee;
      
      if (manager != null) {
        final success = await _appraisalService.startManagerReview(
          _appraisal,
          managerId: manager.id,
          managerName: manager.name,
          managerNumber: manager.employeeNumber,
        );
        
        if (success) {
          // Reload appraisal to get updated status
          final updated = await _appraisalService.getAppraisal(
            _appraisal.employeeId,
            _appraisal.year,
          );
          if (updated != null) {
            setState(() {
              _appraisal = updated;
            });
          }
        }
      }
    }
  }

  Future<void> _loadData() async {
    final provider = Provider.of<AppProvider>(context, listen: false);
    
    // Load goals
    final goals = await provider.getGoalsForEmployee(_appraisal.employeeId);
    
    // Load behavioral standards
    final behavioral = await provider.getBehavioralStandardsForEmployee(_appraisal.employeeId);
    
    setState(() {
      _goals = goals;
      _behavioralStandards = behavioral;
    });
  }

  Future<void> _submitToHR() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit to HR'),
        content: const Text(
          'Are you sure you want to submit this appraisal to HR? '
          'Once submitted, it cannot be edited by you or the employee.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
            ),
            child: const Text('Submit to HR'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Update manager comments
      _appraisal.managerComments = _managerCommentsController.text;
      
      // Submit to HR
      final success = await _appraisalService.submitToHR(_appraisal);
      
      if (success) {
        setState(() {
          _isSubmitting = false;
          _hasChanges = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Appraisal submitted to HR successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Go back to team appraisals
          Navigator.pop(context, true);
        }
      } else {
        throw Exception('Failed to submit appraisal');
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting appraisal: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditable = _appraisal.status == AppraisalStatus.submittedToManager ||
                       _appraisal.status == AppraisalStatus.managerInProgress;

    return Scaffold(
      appBar: AppBar(
        title: Text('Review: ${_appraisal.employeeName}'),
        actions: [
          if (isEditable && !_isSubmitting)
            IconButton(
              icon: const Icon(Icons.check_circle),
              onPressed: _submitToHR,
              tooltip: 'Submit to HR',
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Status Badge
          StatusBadge(status: _appraisal.status),
          const SizedBox(height: 16),

          // Employee Information Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person, color: Color(0xFF3B6BA6)),
                      const SizedBox(width: 8),
                      Text(
                        'Employee Information',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _InfoRow(label: 'Name', value: _appraisal.employeeName),
                  _InfoRow(label: 'Employee #', value: _appraisal.employeeNumber),
                  _InfoRow(label: 'Year', value: '${_appraisal.year}'),
                  if (_appraisal.submittedToManagerAt != null)
                    _InfoRow(
                      label: 'Submitted',
                      value: _formatDate(_appraisal.submittedToManagerAt!),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Goals & KPI Section
          Card(
            child: ExpansionTile(
              initiallyExpanded: true,
              leading: const Icon(Icons.track_changes, color: Color(0xFFE67E22)),
              title: const Text(
                'Goals & KPI Review (70%)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_goals.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('No goals submitted by employee'),
                          ),
                        )
                      else
                        ..._goals.map((goal) => _GoalReviewCard(
                              goal: goal,
                              isReadOnly: true,
                            )),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Behavioral Assessment Section
          Card(
            child: ExpansionTile(
              initiallyExpanded: false,
              leading: const Icon(Icons.psychology, color: Color(0xFF3B6BA6)),
              title: const Text(
                'Behavioral Assessment (30%)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_behavioralStandards.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('No behavioral standards submitted'),
                          ),
                        )
                      else
                        Text(
                          '${_behavioralStandards.length} standards completed',
                          style: const TextStyle(fontSize: 14),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Manager Comments Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.comment, color: Color(0xFF9B59B6)),
                      const SizedBox(width: 8),
                      Text(
                        'Manager Comments',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _managerCommentsController,
                    decoration: InputDecoration(
                      labelText: 'Your Comments & Feedback',
                      border: const OutlineInputBorder(),
                      hintText: 'Provide feedback on employee performance...',
                      enabled: isEditable,
                    ),
                    maxLines: 6,
                    readOnly: !isEditable,
                    onChanged: (_) {
                      setState(() {
                        _hasChanges = true;
                      });
                    },
                  ),
                  if (!isEditable)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'This appraisal has been submitted to HR and is now read-only',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Submit to HR Button
          if (isEditable)
            ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _submitToHR,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.send),
              label: Text(_isSubmitting ? 'Submitting...' : 'Submit to HR'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  void dispose() {
    _managerCommentsController.dispose();
    super.dispose();
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalReviewCard extends StatelessWidget {
  final Map<String, dynamic> goal;
  final bool isReadOnly;

  const _GoalReviewCard({
    required this.goal,
    this.isReadOnly = true,
  });

  @override
  Widget build(BuildContext context) {
    final deliverables = goal['deliverables'] as List? ?? [];
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: const Color(0xFFE67E22).withValues(alpha: 0.05),
      child: ExpansionTile(
        title: Text(
          goal['title'] ?? 'Untitled Goal',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(goal['description'] ?? ''),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (deliverables.isEmpty)
                  const Text('No deliverables')
                else
                  ...deliverables.map((deliverable) => Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE67E22),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'Deliverable ${deliverable['number']}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Priority: ${deliverable['priority']}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  const Spacer(),
                                  Text(
                                    'Weight: ${deliverable['weight'].toStringAsFixed(2)}%',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF3B6BA6),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                deliverable['description'] ?? 'No description',
                                style: const TextStyle(fontSize: 13),
                              ),
                              if (deliverable['threshold'] != null &&
                                  deliverable['threshold'].toString().isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Threshold: ${deliverable['threshold']}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                              if (deliverable['keyResults'] != null &&
                                  deliverable['keyResults'].toString().isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Key Results:',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        deliverable['keyResults'],
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
