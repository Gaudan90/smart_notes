import 'package:easy_localization/easy_localization.dart';
import '../states/sentence_model.dart';

class SentencePresenter {
  String reverseSentence(String input) {
    if (input.trim().isEmpty) return 'sr_empty_input'.tr();

    final model = SentenceModel(sentence: input.trim());
    return model.reverse();
  }
}