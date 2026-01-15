import 'package:flutter/material.dart';
import '../../states/event_model.dart';
import '../../states/event_occurrence_model.dart';
import 'event_calendar_helpers.dart';

class EventDetailsDialog extends StatelessWidget {
  final EventModel event;
  final List<EventOccurrence> occurrences;
  final Future<void> Function() onDelete;

  const EventDetailsDialog({
    super.key,
    required this.event,
    required this.occurrences,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(event.title),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event.description.isNotEmpty) ...[
              Text(
                event.description,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),
            ],
            _buildInfoRow(
              Icons.event,
              'Tipo',
              event.recurrenceType.displayName,
            ),
            _buildInfoRow(
              Icons.calendar_today,
              'Periodo',
              '${EventCalendarHelpers.formatDate(event.startDate)} - ${EventCalendarHelpers.formatDate(event.endDate)}',
            ),
            _buildInfoRow(
              Icons.repeat,
              'Ripetizioni generate',
              '${occurrences.length} date',
            ),
            if (occurrences.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildOccurrencesList(context),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => _confirmDelete(context),
          child: const Text(
            'Elimina',
            style: TextStyle(color: Colors.red),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Chiudi'),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOccurrencesList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Prime date:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: occurrences.length > 10 ? 10 : occurrences.length,
            itemBuilder: (context, index) {
              final occ = occurrences[index];
              return ListTile(
                dense: true,
                leading: CircleAvatar(
                  radius: 16,
                  child: Text(
                    '${occ.occurrenceNumber}',
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
                title: Text(occ.formattedDate),
              );
            },
          ),
        ),
        if (occurrences.length > 10)
          Text(
            '... e altre ${occurrences.length - 10} date',
            style: const TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: Colors.grey,
            ),
          ),
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Conferma eliminazione'),
        content: Text(
          'Vuoi eliminare l\'evento "${event.title}" e tutte le sue occorrenze?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      Navigator.pop(context);
      await onDelete();
    }
  }
}