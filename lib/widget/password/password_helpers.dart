import 'package:easy_localization/easy_localization.dart';

class PasswordHelpers {
  static String translateStrengthLabel(int strength) {
    if (strength >= 80) return 'strength_very_strong'.tr();
    if (strength >= 60) return 'strength_strong'.tr();
    if (strength >= 40) return 'strength_medium'.tr();
    if (strength >= 20) return 'strength_weak'.tr();
    return 'strength_very_weak'.tr();
  }

  static String formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) return 'time_now'.tr();
    if (difference.inHours < 1) {
      return 'time_minutes_ago'.tr(namedArgs: {'min': '${difference.inMinutes}'});
    }
    if (difference.inDays < 1) {
      return 'time_hours_ago'.tr(namedArgs: {'hours': '${difference.inHours}'});
    }
    if (difference.inDays < 7) {
      return 'time_days_ago'.tr(namedArgs: {'days': '${difference.inDays}'});
    }

    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}