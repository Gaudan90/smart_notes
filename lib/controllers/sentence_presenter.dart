import '../states/sentence_model.dart';

class SentencePresenter {
  String reverseSentence(String input) {
    if (input.trim().isEmpty) return 'Inserisci una frase';

    final model = SentenceModel(sentence: input.trim());
    return model.reverse();
  }
}