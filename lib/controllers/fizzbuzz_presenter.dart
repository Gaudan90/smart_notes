import '../states/fizzbuzz_model.dart';

class FizzBuzzPresenter {
  String generateRoutine(String limitStr, String fizz, String buzz, String both) {
    if (limitStr.isEmpty) return 'Inserisci il numero di giorni';

    try {
      final limit = int.parse(limitStr);
      if (limit <= 0) return 'Inserisci un numero positivo';
      if (limit > 365) return 'Massimo 365 giorni';

      final model = FizzBuzzModel(
        limit: limit,
        fizzLabel: fizz.isEmpty ? 'Studio' : fizz,
        buzzLabel: buzz.isEmpty ? 'Allenamento' : buzz,
        fizzBuzzLabel: both.isEmpty ? 'Riposo' : both,
      );

      final routine = model.generate();
      return routine.join('\n');
    } catch (e) {
      return 'Errore: inserisci un numero valido';
    }
  }
}
