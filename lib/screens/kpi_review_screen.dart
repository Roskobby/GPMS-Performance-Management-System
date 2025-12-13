import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class KPIReviewScreen extends StatefulWidget {
  const KPIReviewScreen({super.key});

  @override
  State<KPIReviewScreen> createState() => _KPIReviewScreenState();
}

class _KPIReviewScreenState extends State<KPIReviewScreen> {
  List<Map<String, dynamic>> _goals = [];
  bool _isLoading = true;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    final provider = Provider.of<AppProvider>(context, listen: false);
    final goals = await provider.getGoals();
    
    setState(() {
      _goals = goals.isEmpty ? _getDefaultGoals() : goals;
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> _getDefaultGoals() {
    return [
      {
        'id': '1',
        'title': 'GOAL 1',
        'description': '',
        'deliverables': [
          {'number': 1, 'description': '', 'weight': 23.33, 'threshold': '', 'keyResults': '', 'selfScore': 0, 'managerScore': 0},
          {'number': 2, 'description': '', 'weight': 23.33, 'threshold': '', 'keyResults': '', 'selfScore': 0, 'managerScore': 0},
          {'number': 3, 'description': '', 'weight': 23.34, 'threshold': '', 'keyResults': '', 'selfScore': 0, 'managerScore': 0},
        ],
      },
      {
        'id': '2',
        'title': 'GOAL 2',
        'description': '',
        'deliverables': [
          {'number': 1, 'description': '', 'weight': 23.33, 'threshold': '', 'keyResults': '', 'selfScore': 0, 'managerScore': 0},
          {'number': 2, 'description': '', 'weight': 23.33, 'threshold': '', 'keyResults': '', 'selfScore': 0, 'managerScore': 0},
          {'number': 3, 'description': '', 'weight': 23.34, 'threshold': '', 'keyResults': '', 'selfScore': 0, 'managerScore': 0},
        ],
      },
      {
        'id': '3',
        'title': 'GOAL 3',
        'description': '',
        'deliverables': [
          {'number': 1, 'description': '', 'weight': 23.33, 'threshold': '', 'keyResults': '', 'selfScore': 0, 'managerScore': 0},
          {'number': 2, 'description': '', 'weight': 23.33, 'threshold': '', 'keyResults': '', 'selfScore': 0, 'managerScore': 0},
          {'number': 3, 'description': '', 'weight': 23.34, 'threshold': '', 'keyResults': '', 'selfScore': 0, 'managerScore': 0},
        ],
      },
    ];
  }

  bool _validateReview() {
    // Check if at least one deliverable has been scored
    bool hasScoring = false;
    
    for (var goal in _goals) {
      final deliverables = goal['deliverables'] as List;
      for (var deliverable in deliverables) {
        if ((deliverable['selfScore'] ?? 0) > 0 || 
            (deliverable['keyResults'] != null && deliverable['keyResults'].toString().trim().isNotEmpty)) {
          hasScoring = true;
          break;
        }
      }
      if (hasScoring) break;
    }
    
    return hasScoring;
  }

  Future<void> _saveGoals() async {
    // Validate before saving
    if (!_validateReview()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter key results or score at least one deliverable before saving'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }
    
    final provider = Provider.of<AppProvider>(context, listen: false);
    await provider.saveGoals(_goals);
    
    setState(() {
      _isSaved = true;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('KPI Review saved successfully! You can still edit if needed.'),
          backgroundColor: Color(0xFF4CAF50),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
  
  void _enableEditing() {
    setState(() {
      _isSaved = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Editing enabled. Remember to save your changes.'),
        backgroundColor: Color(0xFF3B6BA6),
      ),
    );
  }

  double _calculateScore(String type) {
    double totalScore = 0.0;
    
    for (var goal in _goals) {
      final deliverables = goal['deliverables'] as List;
      for (var d in deliverables) {
        final score = type == 'self' ? (d['selfScore'] ?? 0) : (d['managerScore'] ?? 0);
        final weight = d['weight'] ?? 0.0;
        totalScore += (score * weight) / 100;
      }
    }
    
    return totalScore;
  }
  
  void _showScoringGuidelines() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Scoring Guidelines', style: TextStyle(color: Color(0xFF3B6BA6))),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Use the 1-5 rating scale to score each deliverable based on actual achievements:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildGuidelineItem('1', 'Need Improvement', 'Performance significantly below expectations. Key objectives not met.', Colors.red),
              _buildGuidelineItem('2', 'Below Average', 'Performance partially meets expectations. Some objectives achieved.', Colors.orange),
              _buildGuidelineItem('3', 'Average/Good', 'Threshold target achieved. Performance meets expectations.', Colors.blue),
              _buildGuidelineItem('4', 'Above Average', 'Threshold target clearly exceeded. Performance exceeds expectations.', Colors.green),
              _buildGuidelineItem('5', 'Excellent', 'Threshold target far exceeded with exceptional results. Outstanding performance.', Colors.purple),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE67E22).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE67E22)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Important Notes:',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE67E22)),
                    ),
                    SizedBox(height: 8),
                    Text('• KPI Performance contributes 70% to overall rating', style: TextStyle(fontSize: 12)),
                    Text('• Behavioral Standards contribute 30% to overall rating', style: TextStyle(fontSize: 12)),
                    Text('• Score 3 means threshold performance was achieved', style: TextStyle(fontSize: 12)),
                    Text('• Use Key Results to justify your scores with evidence', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildGuidelineItem(String score, String label, String description, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                score,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 14,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final employee = provider.currentEmployee;

    if (employee == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('KPI Review')),
        body: const Center(
          child: Text('Please set up your employee profile first'),
        ),
      );
    }

    final selfScore = _calculateScore('self');
    final managerScore = _calculateScore('manager');

    return Scaffold(
      appBar: AppBar(
        title: const Text('KPI Review'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showScoringGuidelines,
            tooltip: 'Scoring Guidelines',
          ),
          if (!_isSaved)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveGoals,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Saved State Banner
                if (_isSaved)
                  Container(
                    width: double.infinity,
                    color: const Color(0xFF4CAF50),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'KPI Review Saved',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _enableEditing,
                          icon: const Icon(Icons.edit, color: Colors.white, size: 18),
                          label: const Text(
                            'Edit',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.2),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          ),
                        ),
                      ],
                    ),
                  ),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE67E22), Color(0xFFD35400)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'KPI Performance (70% Weight)',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              const Text(
                                'Self Assessment',
                                style: TextStyle(color: Colors.white, fontSize: 12),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${selfScore.toStringAsFixed(1)}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 40,
                            child: VerticalDivider(color: Colors.white30, thickness: 2),
                          ),
                          Column(
                            children: [
                              const Text(
                                'Manager Assessment',
                                style: TextStyle(color: Colors.white, fontSize: 12),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${managerScore.toStringAsFixed(1)}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _goals.length,
                    itemBuilder: (context, index) {
                      return _GoalReviewCard(
                        goal: _goals[index],
                        isSaved: _isSaved,
                        onUpdate: (updatedGoal) {
                          setState(() {
                            _goals[index] = updatedGoal;
                            _isSaved = false; // Reset saved state when editing
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: _isSaved ? null : FloatingActionButton.extended(
        onPressed: _saveGoals,
        icon: const Icon(Icons.save),
        label: const Text('Save KPI Review'),
      ),
    );
  }
}

class _GoalReviewCard extends StatefulWidget {
  final Map<String, dynamic> goal;
  final Function(Map<String, dynamic>) onUpdate;
  final bool isSaved;

  const _GoalReviewCard({
    required this.goal,
    required this.onUpdate,
    this.isSaved = false,
  });

  @override
  State<_GoalReviewCard> createState() => _GoalReviewCardState();
}

class _GoalReviewCardState extends State<_GoalReviewCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Text(
          widget.goal['title'] ?? 'Goal',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE67E22)),
        ),
        subtitle: Text(
          widget.goal['description'] ?? 'No description',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Deliverables & Key Results',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 16),
                ...(widget.goal['deliverables'] as List).map((deliverable) {
                  return _DeliverableReviewItem(
                    deliverable: deliverable,
                    isReadOnly: widget.isSaved,
                    onUpdate: (updated) {
                      final deliverables = List<Map<String, dynamic>>.from(
                        widget.goal['deliverables'],
                      );
                      final idx = deliverables.indexWhere(
                        (d) => d['number'] == updated['number'],
                      );
                      if (idx != -1) {
                        deliverables[idx] = updated;
                        final updatedGoal = Map<String, dynamic>.from(widget.goal);
                        updatedGoal['deliverables'] = deliverables;
                        widget.onUpdate(updatedGoal);
                      }
                    },
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DeliverableReviewItem extends StatefulWidget {
  final Map<String, dynamic> deliverable;
  final Function(Map<String, dynamic>) onUpdate;
  final bool isReadOnly;

  const _DeliverableReviewItem({
    required this.deliverable,
    required this.onUpdate,
    this.isReadOnly = false,
  });

  @override
  State<_DeliverableReviewItem> createState() => _DeliverableReviewItemState();
}

class _DeliverableReviewItemState extends State<_DeliverableReviewItem> {
  late TextEditingController _keyResultsController;

  @override
  void initState() {
    super.initState();
    _keyResultsController = TextEditingController(
      text: widget.deliverable['keyResults'] ?? '',
    );
  }

  @override
  void dispose() {
    _keyResultsController.dispose();
    super.dispose();
  }

  void _updateDeliverable() {
    final updated = Map<String, dynamic>.from(widget.deliverable);
    updated['keyResults'] = _keyResultsController.text;
    widget.onUpdate(updated);
  }

  void _updateScore(String type, int score) {
    final updated = Map<String, dynamic>.from(widget.deliverable);
    if (type == 'self') {
      updated['selfScore'] = score;
    } else {
      updated['managerScore'] = score;
    }
    widget.onUpdate(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.grey.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 16,
                  backgroundColor: Color(0xFFE67E22),
                  child: Text(
                    '1',
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Deliverable ${widget.deliverable['number']}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  'Weight: ${widget.deliverable['weight'].toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              widget.deliverable['description'] ?? 'No description',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              'Threshold: ${widget.deliverable['threshold'] ?? 'Not set'}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _keyResultsController,
              decoration: const InputDecoration(
                labelText: 'Key Results Achieved',
                border: OutlineInputBorder(),
                isDense: true,
                hintText: 'Describe what was actually achieved...',
              ),
              maxLines: 2,
              enabled: !widget.isReadOnly,
              readOnly: widget.isReadOnly,
              onChanged: (_) => _updateDeliverable(),
            ),
            const SizedBox(height: 12),
            const Text(
              'Self Assessment',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF3B6BA6)),
            ),
            const SizedBox(height: 4),
            Row(
              children: List.generate(5, (index) {
                final rating = index + 1;
                final isSelected = (widget.deliverable['selfScore'] ?? 0) == rating;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Material(
                      color: isSelected ? const Color(0xFF3B6BA6) : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                      child: InkWell(
                        onTap: widget.isReadOnly ? null : () => _updateScore('self', rating),
                        borderRadius: BorderRadius.circular(4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            rating.toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.grey.shade600,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),
            const Text(
              'Manager Assessment',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFE67E22)),
            ),
            const SizedBox(height: 4),
            Row(
              children: List.generate(5, (index) {
                final rating = index + 1;
                final isSelected = (widget.deliverable['managerScore'] ?? 0) == rating;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Material(
                      color: isSelected ? const Color(0xFFE67E22) : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                      child: InkWell(
                        onTap: widget.isReadOnly ? null : () => _updateScore('manager', rating),
                        borderRadius: BorderRadius.circular(4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            rating.toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.grey.shade600,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
