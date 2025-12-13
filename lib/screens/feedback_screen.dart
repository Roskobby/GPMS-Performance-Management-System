import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  List<Map<String, dynamic>> _feedbackList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFeedback();
  }

  Future<void> _loadFeedback() async {
    final provider = Provider.of<AppProvider>(context, listen: false);
    final feedback = await provider.getFeedback();
    
    setState(() {
      _feedbackList = feedback;
      _isLoading = false;
    });
  }

  Future<void> _addFeedback() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const _AddFeedbackDialog(),
    );

    if (result != null) {
      final provider = Provider.of<AppProvider>(context, listen: false);
      await provider.saveFeedback(result);
      await _loadFeedback();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Feedback saved successfully!'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final employee = provider.currentEmployee;

    if (employee == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Continuous Feedback')),
        body: const Center(
          child: Text('Please set up your employee profile first'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Continuous Feedback'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Row(
                    children: [
                      Icon(Icons.info, color: Color(0xFF3B6BA6)),
                      SizedBox(width: 8),
                      Text('About Continuous Feedback'),
                    ],
                  ),
                  content: const Text(
                    'Regular feedback sessions help track progress throughout the year.\n\n'
                    '• Document achievements and improvements\n'
                    '• Record developmental conversations\n'
                    '• Track progress on goals\n'
                    '• Build evidence for year-end review',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Got it'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Summary Card
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3B6BA6), Color(0xFF2C5282)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Feedback Summary',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _SummaryItem(
                            icon: Icons.feedback,
                            count: _feedbackList.length,
                            label: 'Total Entries',
                          ),
                          _SummaryItem(
                            icon: Icons.calendar_today,
                            count: _feedbackList
                                .where((f) => DateTime.parse(f['date'])
                                    .isAfter(DateTime.now()
                                        .subtract(const Duration(days: 30))))
                                .length,
                            label: 'This Month',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Feedback List
                Expanded(
                  child: _feedbackList.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.feedback_outlined,
                                size: 80,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No feedback recorded yet',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Start documenting your progress',
                                style: TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: _addFeedback,
                                icon: const Icon(Icons.add),
                                label: const Text('Add First Feedback'),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _feedbackList.length,
                          itemBuilder: (context, index) {
                            final feedback = _feedbackList[
                                _feedbackList.length - 1 - index];
                            return _FeedbackCard(feedback: feedback);
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addFeedback,
        icon: const Icon(Icons.add),
        label: const Text('Add Feedback'),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final int count;
  final String label;

  const _SummaryItem({
    required this.icon,
    required this.count,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 32),
        const SizedBox(height: 8),
        Text(
          count.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  final Map<String, dynamic> feedback;

  const _FeedbackCard({required this.feedback});

  @override
  Widget build(BuildContext context) {
    final date = DateTime.parse(feedback['date']);
    final type = feedback['type'] ?? 'General';
    final content = feedback['content'] ?? '';
    final from = feedback['from'] ?? 'Self';

    Color typeColor = const Color(0xFF3B6BA6);
    IconData typeIcon = Icons.feedback;

    switch (type) {
      case 'Achievement':
        typeColor = const Color(0xFF4CAF50);
        typeIcon = Icons.emoji_events;
        break;
      case 'Improvement':
        typeColor = const Color(0xFFE67E22);
        typeIcon = Icons.trending_up;
        break;
      case 'Challenge':
        typeColor = const Color(0xFFF44336);
        typeIcon = Icons.warning;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: typeColor.withValues(alpha: 0.2),
                  child: Icon(typeIcon, color: typeColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        type,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: typeColor,
                        ),
                      ),
                      Text(
                        DateFormat('MMM dd, yyyy').format(date),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Chip(
                  label: Text(
                    from,
                    style: const TextStyle(fontSize: 11),
                  ),
                  backgroundColor: const Color(0xFFE67E22).withValues(alpha: 0.2),
                  labelStyle: const TextStyle(color: Color(0xFFE67E22)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddFeedbackDialog extends StatefulWidget {
  const _AddFeedbackDialog();

  @override
  State<_AddFeedbackDialog> createState() => _AddFeedbackDialogState();
}

class _AddFeedbackDialogState extends State<_AddFeedbackDialog> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  String _selectedType = 'Achievement';
  String _selectedFrom = 'Self';
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final feedback = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'type': _selectedType,
        'from': _selectedFrom,
        'content': _contentController.text,
        'date': _selectedDate.toIso8601String(),
      };
      Navigator.pop(context, feedback);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Feedback Entry'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Type',
                  border: OutlineInputBorder(),
                ),
                items: ['Achievement', 'Improvement', 'Challenge', 'General']
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedFrom,
                decoration: const InputDecoration(
                  labelText: 'From',
                  border: OutlineInputBorder(),
                ),
                items: ['Self', 'Manager', 'Peer', '1:1 Meeting']
                    .map((from) => DropdownMenuItem(
                          value: from,
                          child: Text(from),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedFrom = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Date'),
                subtitle: Text(DateFormat('MMM dd, yyyy').format(_selectedDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() {
                      _selectedDate = date;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Feedback Content',
                  border: OutlineInputBorder(),
                  hintText: 'Describe the achievement, improvement, or challenge...',
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter feedback content';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
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
