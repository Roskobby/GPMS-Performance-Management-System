import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Review Guide'),
        backgroundColor: const Color(0xFF3B6BA6),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeaderCard(),
          const SizedBox(height: 16),
          _buildInstructionsCard(),
          const SizedBox(height: 16),
          _buildBehavioralStandardsCard(),
          const SizedBox(height: 16),
          _buildKPIReviewCard(),
          const SizedBox(height: 16),
          _buildProfessionalDevelopmentCard(),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      color: const Color(0xFF3B6BA6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.white, size: 32),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'END OF YEAR PERFORMANCE\nREVIEW/APPRAISAL FORM',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Document No: GPMS-HR-F-014', style: TextStyle(color: Colors.white, fontSize: 11)),
                  Text('Revision: 4.0', style: TextStyle(color: Colors.white, fontSize: 11)),
                  Text('Issued: 15.06.2021', style: TextStyle(color: Colors.white, fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.assignment, color: Color(0xFFE67E22)),
                SizedBox(width: 8),
                Text(
                  'INSTRUCTIONS',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3B6BA6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildResponsibilitySection(
              'Employee\'s Responsibilities:',
              'Please complete the SELF ASSESSMENTS of these appraisal forms. Then submit to and meet up with your Supervisor or Line Manager for a one-on-one Performance Appraisal Review. The purpose of preparation is to help you have a fruitful discussion with your line manager on your performance, career interest(s) and development needs.',
              const Color(0xFF3B6BA6),
            ),
            const SizedBox(height: 12),
            _buildResponsibilitySection(
              'Line Manager\'s Responsibilities:',
              'Please schedule individual 1:1 with each Employee in your team for formal discussions. Then accord the right scores for each behavioural standard and KPI achieved. Then submit forms to HR for calibration exercise. After management review, please schedule a 2nd 1:1 with the Employee to communicate finalized overall performance assessment rating and sign-off performance appraisal form.',
              const Color(0xFFE67E22),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsibilitySection(String title, String content, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: const TextStyle(fontSize: 12, height: 1.4),
        ),
      ],
    );
  }

  Widget _buildBehavioralStandardsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B6BA6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '30%',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3B6BA6),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Behavioural Standards\n(Section A)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3B6BA6),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'These are the official behavioural expectations for all staff of GPMS, regardless of role or designation.',
              style: TextStyle(fontSize: 12, height: 1.4),
            ),
            const SizedBox(height: 8),
            const Text(
              'The assessment is used for training and development planning and for bonus rating. Be honest and objective so that development gaps and needs can be clearly identified and addressed in the coming year.',
              style: TextStyle(fontSize: 12, height: 1.4),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF3B6BA6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Behavioural Standards contribute 30% of the overall performance rating.',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3B6BA6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKPIReviewCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE67E22).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '70%',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE67E22),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'KPI / Performance Reviews\n(Section B)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE67E22),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'This is a final annual assessment of your goals or KPIs set at the beginning of the year.',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text('Guidelines:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            _buildGuideline('a)', 'If your goals are more than three (3), group and reduce them to three (3) main goals.'),
            _buildGuideline('b)', 'Under each big goal, list the specific activities or deliverables.'),
            _buildGuideline('c)', 'For each deliverable, select a Goal Priority (1-3), with a default of 1. The Weight (%) will be calculated automatically so all deliverables add up to 70% of the total appraisal score.'),
            _buildGuideline('d)', 'In Threshold Performance, describe what successful achievement looks like at a score of 3 (Average/Good).'),
            _buildGuideline('e)', 'In Key Results, record what was actually achieved by year-end, including evidence (figures, timelines, outputs, impact).'),
            _buildGuideline('f)', 'Use the 1-5 rating scale to score each deliverable based on actual Key Results.'),
            const SizedBox(height: 12),
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
                    'Scoring Scale:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  SizedBox(height: 8),
                  Text('1 – Need Improvement', style: TextStyle(fontSize: 11)),
                  Text('2 – Below Average', style: TextStyle(fontSize: 11)),
                  Text('3 – Average/Good (Threshold Target achieved)', style: TextStyle(fontSize: 11)),
                  Text('4 – Above Average (Threshold Target exceeded)', style: TextStyle(fontSize: 11)),
                  Text('5 – Excellent (Threshold Target far exceeded)', style: TextStyle(fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideline(String prefix, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            prefix,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalDevelopmentCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.school, color: Color(0xFF3B6BA6)),
                SizedBox(width: 8),
                Text(
                  'Professional Development',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3B6BA6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildResponsibilitySection(
              'SELF:',
              'List all development activities you undertook within the year. This includes not only formal training but also new skills learned on the job that helped improve your work.',
              const Color(0xFF3B6BA6),
            ),
            const SizedBox(height: 12),
            _buildResponsibilitySection(
              'TEAM:',
              'For Supervisors/Managers: List trainings you ensured your team took and skills they developed. For Employees: Indicate what development your supervisor ensured you took as a team.',
              const Color(0xFFE67E22),
            ),
          ],
        ),
      ),
    );
  }
}
