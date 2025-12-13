import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class BehavioralAssessmentScreen extends StatefulWidget {
  const BehavioralAssessmentScreen({super.key});

  @override
  State<BehavioralAssessmentScreen> createState() => _BehavioralAssessmentScreenState();
}

class _BehavioralAssessmentScreenState extends State<BehavioralAssessmentScreen> {
  final Map<String, int> _selfScores = {};
  final Map<String, int> _managerScores = {};
  bool _isLoading = true;
  String _mode = 'self'; // 'self' or 'manager'

  // Behavioral standards from the Excel form
  final List<Map<String, dynamic>> _standards = [
    // PART I: HSSE
    {'category': 'HSSE', 'statement': 'Exhibit positive behaviors that comply with HSSE requirements'},
    {'category': 'HSSE', 'statement': 'Proactively promote safety at the workplace'},
    
    // PART II: CUSTOMERS / EMPLOYEES
    {'category': 'Customer Focus/Teamwork', 'statement': 'Develop good relations with external customers (If applicable)'},
    {'category': 'Customer Focus/Teamwork', 'statement': 'Develop and ensure good working relations with other departments'},
    {'category': 'Customer Focus/Teamwork', 'statement': 'Ensure teamwork & co-operation within department'},
    {'category': 'Soft Skills', 'statement': 'Communicate effectively to share information &/or skills with colleagues'},
    
    // PART III: COMPETENCIES - Job Knowledge
    {'category': 'Job Knowledge', 'statement': 'Possess knowledge of work procedures & requirements of job'},
    {'category': 'Job Knowledge', 'statement': 'Show technical competence/skill in area of specialization'},
    {'category': 'Job Knowledge', 'statement': 'Is able to work independently'},
    
    // Work Attitude
    {'category': 'Work Attitude', 'statement': 'Display a willingness to learn (on the job & any other training opportunity)'},
    {'category': 'Work Attitude', 'statement': 'Is proactive & display positive attitude'},
    {'category': 'Work Attitude', 'statement': "Follow instructions to the supervisor's / line manager's satisfaction"},
    {'category': 'Work Attitude', 'statement': 'Is responsible & reliable'},
    {'category': 'Work Attitude', 'statement': 'Is adaptable & willing to accept new responsibilities'},
    
    // Quality & Quantity of Work
    {'category': 'Quality & Quantity', 'statement': 'Is accurate, thorough & careful with work performed'},
    {'category': 'Quality & Quantity', 'statement': 'Is able to handle a reasonable volume of work'},
    {'category': 'Quality & Quantity', 'statement': 'Plan and organize work effectively (able to meet deadlines)'},
    
    // Process Improvement
    {'category': 'Process Improvement', 'statement': 'Seek to continually improve processes & work methods generally'},
    
    // Problem Solving
    {'category': 'Problem Solving', 'statement': 'Is able to handle conflicts / problems at work'},
    {'category': 'Problem Solving', 'statement': 'Help resolve team problems on work-related matters'},
    
    // Supervision/Motivation
    {'category': 'Supervision', 'statement': 'Is a positive role model for other staff'},
    {'category': 'Supervision', 'statement': 'Proactively supervise work of subordinates / contractors (if applicable)'},
    
    // PART IV: PERFORMANCE
    {'category': 'Attendance/Punctuality', 'statement': 'Has good attendance (5=0 days MC, 4=1-2 days, 3=3-4 days, 2=5 days, 1=>6 days)'},
    {'category': 'Attendance/Punctuality', 'statement': 'Is punctual (5=No lateness, 4=1-2 times, 3=3-4 times, 2=5-6 times, 1=>7 times)'},
    
    // PART V: OTHER CONTRIBUTIONS
    {'category': 'Other Contributions', 'statement': 'Use practices that save company resources and minimize wastage'},
    {'category': 'Other Contributions', 'statement': 'Participate or contribute to additional or adhoc projects/committees'},
  ];

  @override
  void initState() {
    super.initState();
    _loadAssessment();
  }

  Future<void> _loadAssessment() async {
    final provider = Provider.of<AppProvider>(context, listen: false);
    final data = await provider.getBehavioralStandards();
    
    if (data != null) {
      setState(() {
        _selfScores.addAll(Map<String, int>.from(data['selfScores'] ?? {}));
        _managerScores.addAll(Map<String, int>.from(data['managerScores'] ?? {}));
      });
    }
    
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveAssessment() async {
    // Validate that at least one standard has been scored
    if (_selfScores.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please rate at least one behavioral standard before saving'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }
    
    final provider = Provider.of<AppProvider>(context, listen: false);
    await provider.saveBehavioralStandards({
      'selfScores': _selfScores,
      'managerScores': _managerScores,
      'lastUpdated': DateTime.now().toIso8601String(),
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Assessment saved successfully!'),
          backgroundColor: Color(0xFF4CAF50),
        ),
      );
    }
  }

  double _calculateScore(Map<String, int> scores) {
    if (scores.isEmpty) return 0.0;
    final total = scores.values.fold(0, (sum, score) => sum + score);
    final maxScore = _standards.length * 5;
    return (total / maxScore) * 30; // 30% weight
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final employee = provider.currentEmployee;

    if (employee == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Behavioral Assessment')),
        body: const Center(
          child: Text('Please set up your employee profile first'),
        ),
      );
    }

    final selfScore = _calculateScore(_selfScores);
    final managerScore = _calculateScore(_managerScores);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Behavioral Assessment'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveAssessment,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Score Summary Card
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
                        'Behavioral Standards (30% Weight)',
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
                          _ScoreDisplay(
                            label: 'Self Assessment',
                            score: selfScore,
                            color: Colors.white,
                          ),
                          const SizedBox(
                            height: 40,
                            child: VerticalDivider(color: Colors.white30, thickness: 2),
                          ),
                          _ScoreDisplay(
                            label: 'Manager Assessment',
                            score: managerScore,
                            color: const Color(0xFFE67E22),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${_selfScores.length}/${_standards.length} criteria assessed',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),

                // Mode Selector
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF3B6BA6)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _mode = 'self'),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _mode == 'self'
                                  ? const Color(0xFF3B6BA6)
                                  : Colors.transparent,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(7),
                                bottomLeft: Radius.circular(7),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.person,
                                  color: _mode == 'self' ? Colors.white : const Color(0xFF3B6BA6),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Self Assessment',
                                  style: TextStyle(
                                    color: _mode == 'self' ? Colors.white : const Color(0xFF3B6BA6),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _mode = 'manager'),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _mode == 'manager'
                                  ? const Color(0xFFE67E22)
                                  : Colors.transparent,
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(7),
                                bottomRight: Radius.circular(7),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.supervisor_account,
                                  color: _mode == 'manager' ? Colors.white : const Color(0xFFE67E22),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Manager Review',
                                  style: TextStyle(
                                    color: _mode == 'manager' ? Colors.white : const Color(0xFFE67E22),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Standards List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _standards.length,
                    itemBuilder: (context, index) {
                      final standard = _standards[index];
                      final key = '${standard['category']}_$index';
                      final score = _mode == 'self'
                          ? _selfScores[key] ?? 0
                          : _managerScores[key] ?? 0;

                      return _StandardCard(
                        standard: standard,
                        score: score,
                        mode: _mode,
                        onScoreChanged: (newScore) {
                          setState(() {
                            if (_mode == 'self') {
                              _selfScores[key] = newScore;
                            } else {
                              _managerScores[key] = newScore;
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveAssessment,
        icon: const Icon(Icons.save),
        label: const Text('Save Assessment'),
      ),
    );
  }
}

class _ScoreDisplay extends StatelessWidget {
  final String label;
  final double score;
  final Color color;

  const _ScoreDisplay({
    required this.label,
    required this.score,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(color: color, fontSize: 12),
        ),
        const SizedBox(height: 8),
        Text(
          '${score.toStringAsFixed(1)}%',
          style: TextStyle(
            color: color,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _StandardCard extends StatelessWidget {
  final Map<String, dynamic> standard;
  final int score;
  final String mode;
  final Function(int) onScoreChanged;

  const _StandardCard({
    required this.standard,
    required this.score,
    required this.mode,
    required this.onScoreChanged,
  });

  @override
  Widget build(BuildContext context) {
    final color = mode == 'self' ? const Color(0xFF3B6BA6) : const Color(0xFFE67E22);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                standard['category'],
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              standard['statement'],
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(5, (index) {
                final rating = index + 1;
                final isSelected = score == rating;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Material(
                      color: isSelected ? color : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        onTap: () => onScoreChanged(rating),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            rating.toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.grey.shade600,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 4),
            const Text(
              '1=Need Improvement  •  3=Average/Good  •  5=Excellent',
              style: TextStyle(fontSize: 10, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
