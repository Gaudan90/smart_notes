import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../states/event_model.dart';

mixin EventCalendarHelpers {
  static List<String> get weekDayNames => [
    'weekday_mon'.tr(),
    'weekday_tue'.tr(),
    'weekday_wed'.tr(),
    'weekday_thu'.tr(),
    'weekday_fri'.tr(),
    'weekday_sat'.tr(),
    'weekday_sun'.tr(),
  ];

  static String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  static String getMonthName(int month) {
    const monthKeys = [
      'month_january', 'month_february', 'month_march', 'month_april',
      'month_may', 'month_june', 'month_july', 'month_august',
      'month_september', 'month_october', 'month_november', 'month_december'
    ];
    return monthKeys[month - 1].tr();
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

  // Mappa per tradurre i tipi di ricorrenza
  static const Map<RecurrenceType, String> _recurrenceTranslationKeys = {
    RecurrenceType.once: 'recurrence_once',
    RecurrenceType.daily: 'recurrence_daily',
    RecurrenceType.weekly: 'recurrence_weekly',
    RecurrenceType.monthly: 'recurrence_monthly',
  };

  static String getRecurrenceDisplayName(RecurrenceType type) {
    final key = _recurrenceTranslationKeys[type];
    return key != null ? key.tr() : type.displayName;
  }
}