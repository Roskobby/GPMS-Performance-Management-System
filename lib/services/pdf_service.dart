import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/appraisal.dart';
import '../models/appraisal_status.dart';

class PdfService {
  /// Generate PDF appraisal report
  static Future<Uint8List> generateAppraisalPdf({
    required Appraisal appraisal,
    required List<Map<String, dynamic>> goals,
    required List<Map<String, dynamic>> behavioralStandards,
  }) async {
    final pdf = pw.Document();

    // Add pages
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          // Header
          _buildHeader(appraisal),
          pw.SizedBox(height: 20),
          
          // Employee Information
          _buildEmployeeInfo(appraisal),
          pw.SizedBox(height: 20),
          
          // Goals & KPI Section
          _buildGoalsSection(goals),
          pw.SizedBox(height: 20),
          
          // Behavioral Assessment Section
          _buildBehavioralSection(behavioralStandards),
          pw.SizedBox(height: 20),
          
          // Manager Comments
          _buildManagerComments(appraisal),
          pw.SizedBox(height: 30),
          
          // Signature Section
          _buildSignatureSection(appraisal),
        ],
        footer: (context) => _buildFooter(context),
      ),
    );

    return pdf.save();
  }

  /// Header with title and logo
  static pw.Widget _buildHeader(Appraisal appraisal) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'GPMS',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue900,
                  ),
                ),
                pw.Text(
                  'General Performance Management System',
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: pw.BoxDecoration(
                color: _getStatusColor(appraisal.status),
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Text(
                appraisal.status.displayText,
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Divider(thickness: 2, color: PdfColors.blue900),
        pw.SizedBox(height: 10),
        pw.Text(
          'PERFORMANCE APPRAISAL REPORT',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// Employee information section
  static pw.Widget _buildEmployeeInfo(Appraisal appraisal) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'EMPLOYEE INFORMATION',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            children: [
              pw.Expanded(
                child: _buildInfoRow('Name:', appraisal.employeeName),
              ),
              pw.Expanded(
                child: _buildInfoRow('Employee #:', appraisal.employeeNumber),
              ),
            ],
          ),
          pw.SizedBox(height: 5),
          pw.Row(
            children: [
              pw.Expanded(
                child: _buildInfoRow('Year:', '${appraisal.year}'),
              ),
              pw.Expanded(
                child: _buildInfoRow(
                  'Period:',
                  '${_formatDate(appraisal.reviewPeriodStart)} - ${_formatDate(appraisal.reviewPeriodEnd)}',
                ),
              ),
            ],
          ),
          if (appraisal.submittedToManagerAt != null) ...[
            pw.SizedBox(height: 5),
            pw.Row(
              children: [
                pw.Expanded(
                  child: _buildInfoRow(
                    'Submitted to Manager:',
                    _formatDate(appraisal.submittedToManagerAt!),
                  ),
                ),
                if (appraisal.submittedToHRAt != null)
                  pw.Expanded(
                    child: _buildInfoRow(
                      'Submitted to HR:',
                      _formatDate(appraisal.submittedToHRAt!),
                    ),
                  ),
              ],
            ),
          ],
          if (appraisal.reviewedByManagerName != null) ...[
            pw.SizedBox(height: 5),
            _buildInfoRow(
              'Reviewed by:',
              '${appraisal.reviewedByManagerName} (${appraisal.reviewedByManagerNumber})',
            ),
          ],
        ],
      ),
    );
  }

  /// Goals and KPI section
  static pw.Widget _buildGoalsSection(List<Map<String, dynamic>> goals) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            color: PdfColors.orange50,
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Row(
            children: [
              pw.Text(
                'GOALS & KPI REVIEW',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.orange900,
                ),
              ),
              pw.Spacer(),
              pw.Text(
                'Weight: 70%',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.orange900,
                ),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 10),
        if (goals.isEmpty)
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            child: pw.Text('No goals submitted'),
          )
        else
          ...goals.map((goal) => _buildGoalCard(goal)),
      ],
    );
  }

  /// Individual goal card
  static pw.Widget _buildGoalCard(Map<String, dynamic> goal) {
    final deliverables = goal['deliverables'] as List? ?? [];
    
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 10),
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            goal['title'] ?? 'Untitled Goal',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          if (goal['description'] != null && goal['description'].toString().isNotEmpty) ...[
            pw.SizedBox(height: 5),
            pw.Text(
              goal['description'],
              style: const pw.TextStyle(fontSize: 10),
            ),
          ],
          if (deliverables.isNotEmpty) ...[
            pw.SizedBox(height: 8),
            pw.Text(
              'Deliverables:',
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 5),
            ...deliverables.map((d) => _buildDeliverableItem(d)),
          ],
        ],
      ),
    );
  }

  /// Individual deliverable item
  static pw.Widget _buildDeliverableItem(Map<String, dynamic> deliverable) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 8),
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: pw.BoxDecoration(
                  color: PdfColors.orange,
                  borderRadius: pw.BorderRadius.circular(2),
                ),
                child: pw.Text(
                  'D${deliverable['number']}',
                  style: pw.TextStyle(
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Text(
                'Priority: ${deliverable['priority']}',
                style: const pw.TextStyle(fontSize: 9),
              ),
              pw.Spacer(),
              pw.Text(
                'Weight: ${deliverable['weight'].toStringAsFixed(2)}%',
                style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue900,
                ),
              ),
            ],
          ),
          if (deliverable['description'] != null && deliverable['description'].toString().isNotEmpty) ...[
            pw.SizedBox(height: 4),
            pw.Text(
              deliverable['description'],
              style: const pw.TextStyle(fontSize: 9),
            ),
          ],
          if (deliverable['threshold'] != null && deliverable['threshold'].toString().isNotEmpty) ...[
            pw.SizedBox(height: 4),
            pw.Text(
              'Threshold: ${deliverable['threshold']}',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
            ),
          ],
          if (deliverable['keyResults'] != null && deliverable['keyResults'].toString().isNotEmpty) ...[
            pw.SizedBox(height: 4),
            pw.Container(
              padding: const pw.EdgeInsets.all(6),
              decoration: pw.BoxDecoration(
                color: PdfColors.blue50,
                borderRadius: pw.BorderRadius.circular(2),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Key Results:',
                    style: pw.TextStyle(
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    deliverable['keyResults'],
                    style: const pw.TextStyle(fontSize: 8),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Behavioral assessment section
  static pw.Widget _buildBehavioralSection(List<Map<String, dynamic>> standards) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            color: PdfColors.blue50,
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Row(
            children: [
              pw.Text(
                'BEHAVIORAL ASSESSMENT',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue900,
                ),
              ),
              pw.Spacer(),
              pw.Text(
                'Weight: 30%',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue900,
                ),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey400),
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Total Standards Assessed: ${standards.length}',
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                'Behavioral standards include competencies such as teamwork, communication, '
                'problem-solving, and adherence to organizational values.',
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Manager comments section
  static pw.Widget _buildManagerComments(Appraisal appraisal) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            color: PdfColors.purple50,
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Text(
            'MANAGER COMMENTS & FEEDBACK',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.purple900,
            ),
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey400),
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Text(
            appraisal.managerComments ?? 'No comments provided',
            style: const pw.TextStyle(fontSize: 10),
          ),
        ),
      ],
    );
  }

  /// Signature section
  static pw.Widget _buildSignatureSection(Appraisal appraisal) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Divider(thickness: 1),
        pw.SizedBox(height: 15),
        pw.Text(
          'SIGNATURES',
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 15),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            // Employee signature
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(
                    height: 60,
                    decoration: pw.BoxDecoration(
                      border: pw.Border(
                        bottom: pw.BorderSide(color: PdfColors.grey800),
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    'Employee Signature',
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    appraisal.employeeName,
                    style: const pw.TextStyle(fontSize: 8),
                  ),
                  if (appraisal.submittedToManagerAt != null)
                    pw.Text(
                      'Date: ${_formatDate(appraisal.submittedToManagerAt!)}',
                      style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                    ),
                ],
              ),
            ),
            pw.SizedBox(width: 40),
            // Manager signature
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(
                    height: 60,
                    decoration: pw.BoxDecoration(
                      border: pw.Border(
                        bottom: pw.BorderSide(color: PdfColors.grey800),
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    'Manager Signature',
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    appraisal.reviewedByManagerName ?? 'Pending',
                    style: const pw.TextStyle(fontSize: 8),
                  ),
                  if (appraisal.submittedToHRAt != null)
                    pw.Text(
                      'Date: ${_formatDate(appraisal.submittedToHRAt!)}',
                      style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Footer with page numbers
  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 10),
      child: pw.Text(
        'Page ${context.pageNumber} of ${context.pagesCount}',
        style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
      ),
    );
  }

  /// Helper: Build info row
  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 100,
          child: pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey700,
            ),
          ),
        ),
        pw.Expanded(
          child: pw.Text(
            value,
            style: const pw.TextStyle(fontSize: 9),
          ),
        ),
      ],
    );
  }

  /// Helper: Get status color
  static PdfColor _getStatusColor(AppraisalStatus status) {
    switch (status) {
      case AppraisalStatus.draft:
        return PdfColors.blue;
      case AppraisalStatus.submittedToManager:
        return PdfColors.amber;
      case AppraisalStatus.managerInProgress:
        return PdfColors.orange;
      case AppraisalStatus.finalSubmittedToHR:
        return PdfColors.green;
    }
  }

  /// Helper: Format date
  static String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Preview PDF (for web/desktop)
  static Future<void> previewPdf({
    required Appraisal appraisal,
    required List<Map<String, dynamic>> goals,
    required List<Map<String, dynamic>> behavioralStandards,
  }) async {
    final pdfData = await generateAppraisalPdf(
      appraisal: appraisal,
      goals: goals,
      behavioralStandards: behavioralStandards,
    );

    await Printing.layoutPdf(
      onLayout: (format) => pdfData,
      name: 'GPMS_Appraisal_${appraisal.year}_${appraisal.employeeNumber}_${appraisal.employeeName.replaceAll(' ', '_')}.pdf',
    );
  }

  /// Download PDF (for web)
  static Future<void> downloadPdf({
    required Appraisal appraisal,
    required List<Map<String, dynamic>> goals,
    required List<Map<String, dynamic>> behavioralStandards,
  }) async {
    final pdfData = await generateAppraisalPdf(
      appraisal: appraisal,
      goals: goals,
      behavioralStandards: behavioralStandards,
    );

    await Printing.sharePdf(
      bytes: pdfData,
      filename: 'GPMS_Appraisal_${appraisal.year}_${appraisal.employeeNumber}_${appraisal.employeeName.replaceAll(' ', '_')}.pdf',
    );
  }
}
