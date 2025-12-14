import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';

class FinalAppraisalScreen extends StatefulWidget {
  const FinalAppraisalScreen({super.key});

  @override
  State<FinalAppraisalScreen> createState() => _FinalAppraisalScreenState();
}

class _FinalAppraisalScreenState extends State<FinalAppraisalScreen> {
  bool _isLoading = true;
  double _behavioralScore = 0.0;
  double _kpiScore = 0.0;
  String _employeeComments = '';
  String _managerComments = '';

  @override
  void initState() {
    super.initState();
    _loadAppraisalData();
  }

  Future<void> _loadAppraisalData() async {
    final provider = Provider.of<AppProvider>(context, listen: false);
    
    // Load behavioral standards (use employee self scores; fallback to manager if none)
    final behavioral = await provider.getBehavioralStandards();
    if (behavioral != null) {
      final selfScores = Map<String, int>.from(behavioral['selfScores'] ?? {});
      final managerScores = Map<String, int>.from(behavioral['managerScores'] ?? {});
      final sourceScores = selfScores.isNotEmpty ? selfScores : managerScores;
      if (sourceScores.isNotEmpty) {
        final total = sourceScores.values.fold(0, (sum, score) => sum + score);
        final maxScore = 26 * 5; // 26 standards * 5 max score
        _behavioralScore = (total / maxScore) * 30; // 30% weight
      }
    }
    
    // Load KPI scores (use employee self scores; fallback to manager if none)
    final goals = await provider.getGoals();
    if (goals.isNotEmpty) {
      double totalScore = 0.0;
      for (var goal in goals) {
        final deliverables = goal['deliverables'] as List;
        for (var d in deliverables) {
          final score = d['selfScore'] ?? d['managerScore'] ?? 0;
          final weight = d['weight'] ?? 0.0;
          totalScore += (score * weight) / 100;
        }
      }
      _kpiScore = totalScore;
    }
    
    // Load appraisal data if exists
    final appraisal = await provider.getAppraisal();
    if (appraisal != null) {
      _employeeComments = appraisal['employeeComments'] ?? '';
      _managerComments = appraisal['managerComments'] ?? '';
    }
    
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveAppraisal() async {
    final provider = Provider.of<AppProvider>(context, listen: false);
    await provider.saveAppraisal({
      'behavioralScore': _behavioralScore,
      'kpiScore': _kpiScore,
      'overallScore': _behavioralScore + _kpiScore,
      'employeeComments': _employeeComments,
      'managerComments': _managerComments,
      'submittedDate': DateTime.now().toIso8601String(),
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Final appraisal saved successfully!'),
          backgroundColor: Color(0xFF4CAF50),
        ),
      );
    }
  }

  String _getPerformanceRating(double score) {
    if (score >= 4.5) return 'Excellent';
    if (score >= 4.0) return 'Above Average';
    if (score >= 3.0) return 'Average/Good';
    if (score >= 2.0) return 'Below Average';
    return 'Need Improvement';
  }

  Color _getRatingColor(String rating) {
    switch (rating) {
      case 'Excellent':
        return const Color(0xFF4CAF50);
      case 'Above Average':
        return const Color(0xFF2196F3);
      case 'Average/Good':
        return const Color(0xFFE67E22);
      case 'Below Average':
        return const Color(0xFFFF9800);
      default:
        return const Color(0xFFF44336);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final employee = provider.currentEmployee;

    if (employee == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Final Appraisal')),
        body: const Center(
          child: Text('Please set up your employee profile first'),
        ),
      );
    }

    final overallScore = _behavioralScore + _kpiScore;
    final rating = _getPerformanceRating(overallScore);
    final ratingColor = _getRatingColor(rating);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Final Appraisal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveAppraisal,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/icons/gpms_logo.png',
                            width: 150,
                            height: 75,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'END OF YEAR PERFORMANCE APPRAISAL',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3B6BA6),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow('Employee', employee.name),
                          _buildInfoRow('Department', employee.department),
                          _buildInfoRow('Designation', employee.designation),
                          _buildInfoRow('Line Manager', employee.lineManager),
                          _buildInfoRow('Review Period', '${provider.currentYear}'),
                          _buildInfoRow('Date', DateFormat('MMM dd, yyyy').format(DateTime.now())),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Overall Rating Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [ratingColor, ratingColor.withValues(alpha: 0.8)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'OVERALL PERFORMANCE RATING',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          overallScore.toStringAsFixed(2),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            rating,
                            style: TextStyle(
                              color: ratingColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Score Breakdown
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Score Breakdown',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3B6BA6),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _ScoreRow(
                            label: 'Behavioral Standards',
                            weight: '30%',
                            score: _behavioralScore,
                            color: const Color(0xFF3B6BA6),
                          ),
                          const SizedBox(height: 12),
                          _ScoreRow(
                            label: 'KPI Performance',
                            weight: '70%',
                            score: _kpiScore,
                            color: const Color(0xFFE67E22),
                          ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'TOTAL SCORE',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${overallScore.toStringAsFixed(2)}%',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: ratingColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Performance Scale Guide
                  Card(
                    color: const Color(0xFF3B6BA6).withValues(alpha: 0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Performance Rating Scale',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3B6BA6),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _RatingScaleItem('4.5 - 5.0', 'Excellent', const Color(0xFF4CAF50)),
                          _RatingScaleItem('4.0 - 4.4', 'Above Average', const Color(0xFF2196F3)),
                          _RatingScaleItem('3.0 - 3.9', 'Average/Good', const Color(0xFFE67E22)),
                          _RatingScaleItem('2.0 - 2.9', 'Below Average', const Color(0xFFFF9800)),
                          _RatingScaleItem('1.0 - 1.9', 'Need Improvement', const Color(0xFFF44336)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Employee Comments
                  const Text(
                    "EMPLOYEE'S COMMENTS",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3B6BA6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Enter your comments about this year\'s performance...',
                          border: InputBorder.none,
                        ),
                        maxLines: 5,
                        onChanged: (value) {
                          _employeeComments = value;
                        },
                        controller: TextEditingController(text: _employeeComments),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Manager Comments
                  const Text(
                    "LINE MANAGER'S COMMENTS",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE67E22),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Manager feedback and recommendations...',
                          border: InputBorder.none,
                        ),
                        maxLines: 5,
                        onChanged: (value) {
                          _managerComments = value;
                        },
                        controller: TextEditingController(text: _managerComments),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveAppraisal,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                      child: const Text(
                        'SUBMIT FINAL APPRAISAL',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  final String label;
  final String weight;
  final double score;
  final Color color;

  const _ScoreRow({
    required this.label,
    required this.weight,
    required this.score,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                'Weight: $weight',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        Text(
          '${score.toStringAsFixed(2)}%',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _RatingScaleItem extends StatelessWidget {
  final String range;
  final String label;
  final Color color;

  const _RatingScaleItem(this.range, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 80,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              range,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }
}
