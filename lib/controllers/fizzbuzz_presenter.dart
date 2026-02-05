import 'package:easy_localization/easy_localization.dart';
import '../states/fizzbuzz_model.dart';

class FizzBuzzPresenter {
  String generateRoutine(String limitStr, String fizz, String buzz, String both) {
    if (limitStr.isEmpty) return 'fb_enter_days'.tr();

    try {
      final limit = int.parse(limitStr);
      if (limit <= 0) return 'fb_positive_number'.tr();
      if (limit > 365) return 'fb_max_365'.tr();

      final model = FizzBuzzModel(
        limit: limit,
        fizzLabel: fizz.isEmpty ? 'fb_default_study'.tr() : fizz,
        buzzLabel: buzz.isEmpty ? 'fb_default_workout'.tr() : buzz,
        fizzBuzzLabel: both.isEmpty ? 'fb_default_rest'.tr() : both,
      );

      final routine = model.generate();
      return routine.join('\n');
    } catch (e) {
      return 'fb_error_invalid'.tr();
    }
  }
}
