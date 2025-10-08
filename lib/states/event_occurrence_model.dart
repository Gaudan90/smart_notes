class EventOccurrence {
  final String eventId;
  final String eventTitle;
  final DateTime date;
  final int occurrenceNumber;

  EventOccurrence({
    required this.eventId,
    required this.eventTitle,
    required this.date,
    required this.occurrenceNumber,
  });

  String get formattedDate {
    final weekDay = _weekDayName(date.weekday);
    return '$weekDay ${date.day}/${date.month}/${date.year}';
  }

  String _weekDayName(int weekday) {
    const days = ['Lun', 'Mar', 'Mer', 'Gio', 'Ven', 'Sab', 'Dom'];
    return days[weekday - 1];
  }
}