import 'package:easy_localization/easy_localization.dart';
import '../states/missing_number_model.dart';

class MissingNumbersPresenter {
  String findMissingNumbers(String input) {
    if (input.isEmpty) return 'mn_empty_input'.tr();

    try {
      final numbers = input
          .split(RegExp(r'[,\s]+'))
          .where((s) => s.isNotEmpty)
          .map((s) => int.parse(s))
          .toSet()
          .toList();

      if (numbers.length < 2) return 'mn_min_two_numbers'.tr();

      final model = MissingNumbersModel(sequence: numbers);
      final missing = model.findMissing();

      if (missing.isEmpty) {
        return 'mn_no_missing'.tr();
      }

      String result = '${'mn_missing_found'.tr(namedArgs: {
        'count': '${missing.length}',
      })}\n\n';
      result += missing.join(', ');

      return result;
    } catch (e) {
      return 'mn_error_invalid'.tr();
    }
  }
}