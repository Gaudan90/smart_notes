import 'package:flutter/material.dart';
import '../../states/event_occurrence_model.dart';
import 'event_calendar_helpers.dart';

class EventOccurrenceCard extends StatelessWidget {
  final EventOccurrence occurrence;

  const EventOccurrenceCard({
    super.key,
    required this.occurrence,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: _buildDateBadge(context),
        title: Text(occurrence.eventTitle),
        subtitle: Text(
          'Occorrenza #${occurrence.occurrenceNumber}',
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildDateBadge(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${occurrence.date.day}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          Text(
            EventCalendarHelpers.weekDayNames[occurrence.date.weekday - 1],
            style: const TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class EventOccurrenceMonthSection extends StatelessWidget {
  final String monthKey;
  final List<EventOccurrence> occurrences;

  const EventOccurrenceMonthSection({
    super.key,
    required this.monthKey,
    required this.occurrences,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            monthKey,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        ...occurrences.map(
              (occ) => EventOccurrenceCard(occurrence: occ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}