import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../states/event_model.dart';
import '../../states/event_occurrence_model.dart';
import 'event_calendar_helpers.dart';

class EventCard extends StatelessWidget {
  final EventModel event;
  final int totalOccurrences;
  final EventOccurrence? nextOccurrence;
  final VoidCallback onTap;

  const EventCard({
    super.key,
    required this.event,
    required this.totalOccurrences,
    this.nextOccurrence,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
          Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          child: Icon(
            EventCalendarHelpers.getRecurrenceIcon(event.recurrenceType),
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(
          event.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(EventCalendarHelpers.getRecurrenceDisplayName(event.recurrenceType)),
            const SizedBox(height: 4),
            Text(
              'dates_generated'.tr(namedArgs: {'count': '$totalOccurrences'}),
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (nextOccurrence != null)
              Text(
                'next_occurrence'.tr(namedArgs: {'date': nextOccurrence!.formattedDate}),
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.orange,
                ),
              ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: onTap,
        ),
        onTap: onTap,
      ),
    );
  }
}