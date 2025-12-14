import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class GoalSettingScreen extends StatefulWidget {
  const GoalSettingScreen({super.key});

  @override
  State<GoalSettingScreen> createState() => _GoalSettingScreenState();
}

class _GoalSettingScreenState extends State<GoalSettingScreen> {
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
      // If goals were loaded from storage, they were previously saved
      _isSaved = goals.isNotEmpty;
    });
  }

  List<Map<String, dynamic>> _getDefaultGoals() {
    return [
      {
        'id': '1',
        'title': 'GOAL 1',
        'description': '',
        'deliverables': [
          {'number': 1, 'description': '', 'priority': 1, 'weight': 23.33, 'threshold': '', 'keyResults': ''},
          {'number': 2, 'description': '', 'priority': 1, 'weight': 23.33, 'threshold': '', 'keyResults': ''},
          {'number': 3, 'description': '', 'priority': 1, 'weight': 23.34, 'threshold': '', 'keyResults': ''},
        ],
      },
      {
        'id': '2',
        'title': 'GOAL 2',
        'description': '',
        'deliverables': [
          {'number': 1, 'description': '', 'priority': 1, 'weight': 23.33, 'threshold': '', 'keyResults': ''},
          {'number': 2, 'description': '', 'priority': 1, 'weight': 23.33, 'threshold': '', 'keyResults': ''},
          {'number': 3, 'description': '', 'priority': 1, 'weight': 23.34, 'threshold': '', 'keyResults': ''},
        ],
      },
      {
        'id': '3',
        'title': 'GOAL 3',
        'description': '',
        'deliverables': [
          {'number': 1, 'description': '', 'priority': 1, 'weight': 23.33, 'threshold': '', 'keyResults': ''},
          {'number': 2, 'description': '', 'priority': 1, 'weight': 23.33, 'threshold': '', 'keyResults': ''},
          {'number': 3, 'description': '', 'priority': 1, 'weight': 23.34, 'threshold': '', 'keyResults': ''},
        ],
      },
    ];
  }

  bool _validateGoals() {
    // Check if at least one goal has content
    bool hasContent = false;
    
    for (var goal in _goals) {
      // Check goal description
      if (goal['description'] != null && goal['description'].toString().trim().isNotEmpty) {
        hasContent = true;
        break;
      }
      
      // Check deliverables
      final deliverables = goal['deliverables'] as List;
      for (var deliverable in deliverables) {
        if ((deliverable['description'] != null && deliverable['description'].toString().trim().isNotEmpty) ||
            (deliverable['threshold'] != null && deliverable['threshold'].toString().trim().isNotEmpty)) {
          hasContent = true;
          break;
        }
      }
      
      if (hasContent) break;
    }
    
    return hasContent;
  }

  Future<void> _saveGoals() async {
    // Validate before saving
    if (!_validateGoals()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter at least one goal or deliverable before saving'),
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
          content: Text('Goals saved successfully! Tap Edit to make changes.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _enableEditing() {
    setState(() {
      _isSaved = false;
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
        title: const Text('Goal Setting'),
        actions: [
          if (_isSaved)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _enableEditing,
              tooltip: 'Edit Goals',
            ),
          if (!_isSaved)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveGoals,
              tooltip: 'Save Goals',
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            color: const Color(0xFFE67E22).withValues(alpha: 0.1),
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Color(0xFFE67E22)),
                      SizedBox(width: 8),
                      Text(
                        'Goal Setting Guidelines',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3B6BA6),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Set 3 main goals aligned with organizational objectives\n'
                    '• Each goal should have clear deliverables\n'
                    '• Define threshold performance (what success looks like)\n'
                    '• Goals contribute 70% to overall performance rating\n'
                    '• Be specific, measurable, and time-bound',
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ..._goals.asMap().entries.map((entry) {
            final index = entry.key;
            final goal = entry.value;
            return _GoalCard(
              goal: goal,
              allGoals: _goals,
              isSaved: _isSaved,
              onUpdate: (updatedGoal) {
                setState(() {
                  _goals[index] = updatedGoal;
                  _isSaved = false; // Reset saved state when editing
                });
              },
            );
          }),
          const SizedBox(height: 16),
          if (!_isSaved)
            ElevatedButton(
              onPressed: _saveGoals,
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Save Goals', style: TextStyle(fontSize: 16)),
              ),
            ),
        ],
      ),
    );
  }
}

class _GoalCard extends StatefulWidget {
  final Map<String, dynamic> goal;
  final Function(Map<String, dynamic>) onUpdate;
  final List<Map<String, dynamic>> allGoals;
  final bool isSaved;

  const _GoalCard({
    required this.goal,
    required this.onUpdate,
    required this.allGoals,
    this.isSaved = false,
  });

  @override
  State<_GoalCard> createState() => _GoalCardState();
}

class _GoalCardState extends State<_GoalCard> {
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(
      text: widget.goal['description'] ?? '',
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _updateGoal() {
    final updatedGoal = Map<String, dynamic>.from(widget.goal);
    updatedGoal['description'] = _descriptionController.text;
    widget.onUpdate(updatedGoal);
  }
  
  void _addDeliverable() {
    final deliverables = List<Map<String, dynamic>>.from(widget.goal['deliverables']);
    final newNumber = deliverables.length + 1;
    
    deliverables.add({
      'number': newNumber,
      'description': '',
      'priority': 1,
      'weight': 0.0,
      'threshold': '',
      'keyResults': '',
    });
    
    _recalculateWeights(deliverables);
    
    final updatedGoal = Map<String, dynamic>.from(widget.goal);
    updatedGoal['deliverables'] = deliverables;
    widget.onUpdate(updatedGoal);
    
    setState(() {});
  }
  
  void _deleteDeliverable(int number) {
    final deliverables = List<Map<String, dynamic>>.from(widget.goal['deliverables']);
    
    if (deliverables.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot delete the last deliverable'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    deliverables.removeWhere((d) => d['number'] == number);
    
    // Renumber deliverables
    for (int i = 0; i < deliverables.length; i++) {
      deliverables[i]['number'] = i + 1;
    }
    
    _recalculateWeights(deliverables);
    
    final updatedGoal = Map<String, dynamic>.from(widget.goal);
    updatedGoal['deliverables'] = deliverables;
    widget.onUpdate(updatedGoal);
    
    setState(() {});
  }
  
  void _recalculateWeights(List<Map<String, dynamic>> deliverables) {
    if (deliverables.isEmpty) return;
    
    // Calculate total priority across ALL goals (not just this goal)
    int totalPriority = 0;
    for (var goal in widget.allGoals) {
      final goalDeliverables = goal['deliverables'] as List;
      for (var d in goalDeliverables) {
        totalPriority += (d['priority'] as int? ?? 1);
      }
    }
    
    if (totalPriority == 0) totalPriority = 1;
    
    // Calculate weights based on priority
    // Formula: Weight = 70% × Priority ÷ Sum(All Priorities)
    // This ensures all deliverables across all goals sum to 70%
    for (var deliverable in deliverables) {
      final priority = deliverable['priority'] as int? ?? 1;
      final weight = 0.70 * (priority / totalPriority) * 100.0; // As percentage
      deliverable['weight'] = double.parse(weight.toStringAsFixed(2));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Text(
          widget.goal['title'] ?? 'Goal',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3B6BA6)),
        ),
        subtitle: Text(
          widget.goal['description']?.isEmpty ?? true
              ? 'Tap to add goal description'
              : widget.goal['description'],
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Goal Description',
                    border: OutlineInputBorder(),
                    hintText: 'Describe the main objective of this goal',
                  ),
                  maxLines: 2,
                  enabled: !widget.isSaved,
                  readOnly: widget.isSaved,
                  onChanged: (_) => _updateGoal(),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Deliverables',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    if (!widget.isSaved)
                      ElevatedButton.icon(
                        onPressed: _addDeliverable,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE67E22),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...(widget.goal['deliverables'] as List).map((deliverable) {
                  return _DeliverableItem(
                    deliverable: deliverable,
                    isSaved: widget.isSaved,
                    onUpdate: (updated) {
                      final deliverables = List<Map<String, dynamic>>.from(
                        widget.goal['deliverables'],
                      );
                      final index = deliverables.indexWhere(
                        (d) => d['number'] == updated['number'],
                      );
                      if (index != -1) {
                        deliverables[index] = updated;
                        final updatedGoal = Map<String, dynamic>.from(widget.goal);
                        updatedGoal['deliverables'] = deliverables;
                        widget.onUpdate(updatedGoal);
                      }
                    },
                    onDelete: () => _deleteDeliverable(deliverable['number']),
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

class _DeliverableItem extends StatefulWidget {
  final Map<String, dynamic> deliverable;
  final Function(Map<String, dynamic>) onUpdate;
  final VoidCallback? onDelete;
  final bool isSaved;

  const _DeliverableItem({
    required this.deliverable,
    required this.onUpdate,
    this.onDelete,
    this.isSaved = false,
  });

  @override
  State<_DeliverableItem> createState() => _DeliverableItemState();
}

class _DeliverableItemState extends State<_DeliverableItem> {
  late TextEditingController _descriptionController;
  late TextEditingController _thresholdController;
  late TextEditingController _keyResultsController;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(
      text: widget.deliverable['description'] ?? '',
    );
    _thresholdController = TextEditingController(
      text: widget.deliverable['threshold'] ?? '',
    );
    _keyResultsController = TextEditingController(
      text: widget.deliverable['keyResults'] ?? '',
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _thresholdController.dispose();
    _keyResultsController.dispose();
    super.dispose();
  }

  void _updateDeliverable() {
    final updated = Map<String, dynamic>.from(widget.deliverable);
    updated['description'] = _descriptionController.text;
    updated['threshold'] = _thresholdController.text;
    updated['keyResults'] = _keyResultsController.text;
    widget.onUpdate(updated);
  }
  
  void _updatePriority(int priority) {
    final updated = Map<String, dynamic>.from(widget.deliverable);
    updated['priority'] = priority;
    widget.onUpdate(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.grey.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color(0xFFE67E22),
                  child: Text(
                    '${widget.deliverable['number']}',
                    style: const TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Deliverable ${widget.deliverable['number']}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                if (widget.onDelete != null && !widget.isSaved) ...[
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                    onPressed: widget.onDelete,
                    tooltip: 'Delete deliverable',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            // Priority Selector
            Row(
              children: [
                const Text('Priority:', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(width: 12),
                ...List.generate(3, (index) {
                  final priority = index + 1;
                  final isSelected = widget.deliverable['priority'] == priority;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text('$priority'),
                      selected: isSelected,
                      onSelected: widget.isSaved ? null : (selected) {
                        if (selected) {
                          _updatePriority(priority);
                        }
                      },
                      backgroundColor: Colors.grey.shade200,
                      selectedColor: const Color(0xFFE67E22),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  );
                }),
                const Spacer(),
                Text(
                  'Weight: ${widget.deliverable['weight'].toStringAsFixed(2)}%',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3B6BA6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Deliverable Description',
                border: OutlineInputBorder(),
                isDense: true,
                hintText: 'What needs to be delivered?',
              ),
              maxLines: 2,
              enabled: !widget.isSaved,
              readOnly: widget.isSaved,
              onChanged: (_) => _updateDeliverable(),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _thresholdController,
              decoration: const InputDecoration(
                labelText: 'Threshold Performance',
                border: OutlineInputBorder(),
                isDense: true,
                hintText: 'What does success look like?',
              ),
              maxLines: 2,
              enabled: !widget.isSaved,
              readOnly: widget.isSaved,
              onChanged: (_) => _updateDeliverable(),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _keyResultsController,
              decoration: const InputDecoration(
                labelText: 'Key Results',
                border: OutlineInputBorder(),
                isDense: true,
                hintText: 'Measurable outcomes and achievements',
              ),
              maxLines: 2,
              onChanged: (_) => _updateDeliverable(),
            ),
          ],
        ),
      ),
    );
  }
}
