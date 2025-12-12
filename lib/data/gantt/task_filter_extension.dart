import 'package:smart_notes/data/gantt/task_filter_enum.dart';

extension TaskFilterExtension on TaskFilter {
  String get label {
    switch (this) {
      case TaskFilter.all:
        return 'Tutti';
      case TaskFilter.active:
        return 'Attivi';
      case TaskFilter.overdue:
        return 'Scaduti';
      case TaskFilter.completed:
        return 'Completati';
    }
  }
}