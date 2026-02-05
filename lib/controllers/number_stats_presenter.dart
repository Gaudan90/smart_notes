import 'package:easy_localization/easy_localization.dart';
import '../states/number_stats_model.dart';

class NumberStatsPresenter {
  final NumberStatsModel model = NumberStatsModel(numbers: []);

  String analyzeNumbers(String input) {
    if (input.isEmpty) return 'ns_empty_input'.tr();

    try {
      final numbers = input
          .split(RegExp(r'[,\s]+'))
          .where((s) => s.isNotEmpty)
          .map((s) => double.parse(s))
          .toList();

      if (numbers.isEmpty) return 'ns_no_valid_numbers'.tr();

      final statsModel = NumberStatsModel(numbers: numbers);
      final mostFrequent = statsModel.getMostFrequent();
      final frequencyMap = statsModel.getFrequencyMap();

      String result = '${'ns_numbers_analyzed'.tr(namedArgs: {
        'count': '${numbers.length}',
      })}\n\n';
      result += '${'ns_most_frequent'.tr(namedArgs: {
        'number': '$mostFrequent',
      })}\n';
      result += '${'ns_appears_times'.tr(namedArgs: {
        'count': '${frequencyMap[mostFrequent]}',
      })}\n\n';
      result += '${'ns_frequencies'.tr()}\n';

      final sortedEntries = frequencyMap.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      for (final entry in sortedEntries) {
        result += '${'ns_frequency_entry'.tr(namedArgs: {
          'number': '${entry.key}',
          'count': '${entry.value}',
        })}\n';
      }

      return result;
    } catch (e) {
      return 'ns_error_invalid'.tr();
    }
  }
}