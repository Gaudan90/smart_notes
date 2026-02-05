import 'package:easy_localization/easy_localization.dart';
import 'task_filter_enum.dart';

extension TaskFilterExtension on TaskFilter {
  String get label {
    switch (this) {
      case TaskFilter.all:
        return 'filter_all'.tr();
      case TaskFilter.active:
        return 'filter_active'.tr();
      case TaskFilter.overdue:
        return 'filter_overdue'.tr();
      case TaskFilter.completed:
        return 'filter_completed'.tr();
    }
  }
}