import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/analysis.dart';

class PdfService {
  static Future<void> generateReport(Analysis result) async {
    final pdf = pw.Document();

    // Define colors
    final primaryColor = PdfColor.fromHex('#3F51B5'); // Indigo
    final greenColor = PdfColor.fromHex('#4CAF50'); // Green
    final redColor = PdfColor.fromHex('#F44336'); // Red

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // --- HEADER ---
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'AI Resume Analysis Report',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  pw.Text(
                    DateTime.now().toString().split(' ')[0],
                    style: const pw.TextStyle(color: PdfColors.grey),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // --- SCORES ---
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                _buildScoreBox(
                  'Overall Score',
                  '${result.score}/100',
                  primaryColor,
                ),
                _buildScoreBox(
                  'Match Rate',
                  '${result.matchPercentage.toStringAsFixed(1)}%',
                  greenColor,
                ),
                _buildScoreBox(
                  'ATS Score',
                  '${result.atsScore}/100',
                  PdfColors.orange,
                ),
              ],
            ),
            pw.SizedBox(height: 30),
            pw.Divider(),
            pw.SizedBox(height: 20),

            // --- SKILLS ---
            _buildSectionTitle('Matched Skills', greenColor),
            _buildSkillList(result.matchedSkills, greenColor),
            pw.SizedBox(height: 15),

            _buildSectionTitle('Missing Skills', redColor),
            _buildSkillList(result.missingSkills, redColor),
            pw.SizedBox(height: 15),

            _buildSectionTitle('Extra Skills', PdfColors.blueGrey),
            _buildSkillList(result.extraSkills, PdfColors.blueGrey),

            pw.SizedBox(height: 30),
            pw.Divider(),
            pw.SizedBox(height: 20),

            // --- SUGGESTIONS ---
            _buildSectionTitle('AI Suggestions', PdfColors.amber),
            pw.SizedBox(height: 10),
            ...result.suggestions.map(
              (s) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 8),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      '- ',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        s,
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ];
        },
      ),
    );

    // Open the print/share dialog
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Resume_Analysis_Report.pdf',
    );
  }

  static pw.Widget _buildScoreBox(String label, String value, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: color, width: 2),
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(label, style: const pw.TextStyle(color: PdfColors.grey700)),
        ],
      ),
    );
  }

  static pw.Widget _buildSectionTitle(String title, PdfColor color) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 16,
          fontWeight: pw.FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  static pw.Widget _buildSkillList(List<String> skills, PdfColor color) {
    if (skills.isEmpty) {
      return pw.Text('None', style: const pw.TextStyle(color: PdfColors.grey));
    }

    return pw.Wrap(
      spacing: 8,
      runSpacing: 8,
      children: skills.map((skill) {
        return pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: pw.BoxDecoration(
            color: color.shade(0.1), // <--- FIXED: Removed the extra `, 1.0`
            borderRadius: pw.BorderRadius.circular(15),
            border: pw.Border.all(color: color, width: 1),
          ),
          child: pw.Text(
            skill,
            style: pw.TextStyle(fontSize: 10, color: color),
          ),
        );
      }).toList(),
    );
  }
}
