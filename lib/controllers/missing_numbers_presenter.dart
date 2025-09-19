import '../states/missing_number_model.dart';

class MissingNumbersPresenter {
  String findMissingNumbers(String input) {
    if (input.isEmpty) return 'Inserisci una sequenza di numeri';

    try {
      final numbers = input
          .split(RegExp(r'[,\s]+'))
          .where((s) => s.isNotEmpty)
          .map((s) => int.parse(s))
          .toSet()
          .toList();

      if (numbers.length < 2) return 'Inserisci almeno 2 numeri';

      final model = MissingNumbersModel(sequence: numbers);
      final missing = model.findMissing();

      if (missing.isEmpty) {
        return 'Nessun numero mancante nella sequenza!';
      }

      String result = 'Numeri mancanti trovati: ${missing.length}\n\n';
      result += missing.join(', ');

      return result;
    } catch (e) {
      return 'Errore: inserisci numeri interi validi';
    }
  }
}