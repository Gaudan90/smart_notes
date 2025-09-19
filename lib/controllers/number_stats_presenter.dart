import '../states/number_stats_model.dart';

class NumberStatsPresenter {
  final NumberStatsModel model = NumberStatsModel(numbers: []);

  String analyzeNumbers(String input) {
    if (input.isEmpty) return 'Inserisci dei numeri separati da virgola o spazio';

    try {
      final numbers = input
          .split(RegExp(r'[,\s]+'))
          .where((s) => s.isNotEmpty)
          .map((s) => double.parse(s))
          .toList();

      if (numbers.isEmpty) return 'Nessun numero valido trovato';

      final statsModel = NumberStatsModel(numbers: numbers);
      final mostFrequent = statsModel.getMostFrequent();
      final frequencyMap = statsModel.getFrequencyMap();

      String result = 'Numeri analizzati: ${numbers.length}\n\n';
      result += 'Numero più frequente: $mostFrequent\n';
      result += 'Appare ${frequencyMap[mostFrequent]} volte\n\n';
      result += 'Frequenze:\n';

      final sortedEntries = frequencyMap.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      for (final entry in sortedEntries) {
        result += '• ${entry.key}: ${entry.value} volte\n';
      }

      return result;
    } catch (e) {
      return 'Errore: inserisci numeri validi separati da virgola o spazio';
    }
  }
}