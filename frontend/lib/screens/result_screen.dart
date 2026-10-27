import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../models/analysis.dart';
import '../services/pdf_service.dart'; // Added for PDF generation

class ResultScreen extends StatelessWidget {
  final Analysis result;
  const ResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis Results'),
        centerTitle: true,
        actions: [
          // --- DOWNLOAD PDF BUTTON ---
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Download PDF Report',
            onPressed: () {
              PdfService.generateReport(result);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- SCORE CARDS ROW ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCircularScore(
                  'Overall',
                  result.score.toDouble(),
                  Colors.indigo,
                ),
                _buildCircularScore(
                  'Match',
                  result.matchPercentage,
                  Colors.green,
                ),
                _buildCircularScore(
                  'ATS',
                  result.atsScore.toDouble(),
                  Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(),

            // --- EXPERIENCE & WORD COUNT ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatChip(
                  Icons.work,
                  '${result.experienceYears} Years Exp',
                ),
                _buildStatChip(Icons.text_fields, '${result.wordCount} Words'),
              ],
            ),
            const Divider(height: 32),

            // --- SKILLS ---
            _buildSectionTitle(
              'Matched Skills',
              Icons.check_circle,
              Colors.green,
            ),
            _buildSkillChips(result.matchedSkills, Colors.green),

            const SizedBox(height: 16),
            _buildSectionTitle('Missing Skills', Icons.cancel, Colors.red),
            _buildSkillChips(result.missingSkills, Colors.red),

            const SizedBox(height: 16),
            _buildSectionTitle(
              'Extra Skills',
              Icons.add_circle,
              Colors.blueGrey,
            ),
            _buildSkillChips(result.extraSkills, Colors.blueGrey),

            const Divider(height: 32),

            // --- SUGGESTIONS ---
            _buildSectionTitle('AI Suggestions', Icons.lightbulb, Colors.amber),
            ...result.suggestions.map(
              (s) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '- ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Expanded(child: Text(s)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularScore(String label, double percent, Color color) {
    // Ensure percentage doesn't exceed 100
    final safePercent = percent > 100 ? 100.0 : percent;

    return Column(
      children: [
        CircularPercentIndicator(
          radius: 45.0,
          lineWidth: 8.0,
          animation: true,
          percent: safePercent / 100,
          center: Text(
            '${safePercent.toStringAsFixed(0)}%',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: color,
            ),
          ),
          circularStrokeCap: CircularStrokeCap.round,
          progressColor: color,
          backgroundColor: color.withValues(alpha: 0.2),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildStatChip(IconData icon, String text) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(text),
      backgroundColor: Colors.grey[200],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillChips(List<String> skills, Color color) {
    if (skills.isEmpty) {
      return const Text('None', style: TextStyle(color: Colors.grey));
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: skills.map((skill) {
        return Chip(
          label: Text(skill),
          backgroundColor: color.withValues(alpha: 0.1),
          labelStyle: TextStyle(color: color, fontWeight: FontWeight.w600),
          side: BorderSide(color: color.withValues(alpha: 0.3)),
        );
      }).toList(),
    );
  }
}
