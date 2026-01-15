import 'package:flutter/material.dart';
import '../../states/event_model.dart';

mixin EventCalendarHelpers {
  static const List<String> weekDayNames = [
    'Lun', 'Mar', 'Mer', 'Gio', 'Ven', 'Sab', 'Dom'
  ];

  static String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  static String getMonthName(int month) {
    const months = [
      'Gennaio', 'Febbraio', 'Marzo', 'Aprile', 'Maggio', 'Giugno',
      'Luglio', 'Agosto', 'Settembre', 'Ottobre', 'Novembre', 'Dicembre'
    ];
    return months[month - 1];
  }

  static IconData getRecurrenceIcon(RecurrenceType type) {
    switch (type) {
      case RecurrenceType.once:
        return Icons.event;
      case RecurrenceType.daily:
        return Icons.today;
      case RecurrenceType.weekly:
        return Icons.date_range;
      case RecurrenceType.monthly:
        return Icons.calendar_today;
    }
  }
}