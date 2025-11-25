import 'package:flutter/material.dart';

class HistoryStatsHeader extends StatelessWidget {
  final Map<String, dynamic> stats;
  final VoidCallback onClearAll;

  const HistoryStatsHeader({
    super.key,
    required this.stats,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Statistiche Cronologia',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Conferma'),
                      content: const Text('Cancellare tutta la cronologia?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Annulla'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text('Elimina'),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    onClearAll();
                  }
                },
                icon: const Icon(Icons.delete_sweep),
                label: const Text('Cancella tutto'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildStatChip(
                'Analisi',
                stats['totalAnalyses'].toString(),
                Colors.blue,
              ),
              _buildStatChip(
                'Parole totali',
                stats['totalWords'].toString(),
                Colors.orange,
              ),
              _buildStatChip(
                'Media parole',
                stats['averageWords'].toStringAsFixed(0),
                Colors.green,
              ),
            ],
          ),
        ],
      ),
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