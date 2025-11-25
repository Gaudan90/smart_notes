import 'package:flutter/material.dart';
import '../../states/text_analyzer_model.dart';

class AnalysisResultCard extends StatelessWidget {
  final TextAnalysisModel analysis;

  const AnalysisResultCard({
    super.key,
    required this.analysis,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Risultati Analisi',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Statistiche principali
            _buildStatRow(
              Icons.format_quote,
              'Parole',
              analysis.wordCount.toString(),
              Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildStatRow(
              Icons.text_fields,
              'Caratteri (senza spazi)',
              analysis.characterCount.toString(),
              Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildStatRow(
              Icons.space_bar,
              'Caratteri (con spazi)',
              analysis.characterCountWithSpaces.toString(),
              Colors.purple,
            ),
            const SizedBox(height: 12),
            _buildStatRow(
              Icons.trending_up,
              'Parola più lunga',
              analysis.longestWord,
              Colors.green,
            ),

            const Divider(height: 24),

            // Statistiche aggiuntive
            Text(
              'Statistiche Avanzate',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildStatChip(
                  'Frasi',
                  analysis.sentenceCount.toString(),
                  Colors.teal,
                ),
                _buildStatChip(
                  'Paragrafi',
                  analysis.paragraphCount.toString(),
                  Colors.indigo,
                ),
                _buildStatChip(
                  'Media lunghezza parole',
                  analysis.averageWordLength.toStringAsFixed(1),
                  Colors.deepOrange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Chip(
      avatar: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.2),
        child: Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      label: Text(label),
      backgroundColor: color.withValues(alpha: 0.1),
    );
  }
}