import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../states/text_analyzer_model.dart';

class TextAnalyzerPresenter {
  static const String _historyKey = 'text_analysis_history';
  static const int _maxHistorySize = 10;

  List<TextAnalysisModel> _history = [];
  List<TextAnalysisModel> get history => List.unmodifiable(_history);

  TextAnalysisModel analyzeText(String text) {
    if (text.trim().isEmpty) {
      return TextAnalysisModel.empty();
    }

    // Conta caratteri (esercizio: length property)
    final characterCountWithSpaces = text.length;
    final characterCount = text.replaceAll(RegExp(r'\s'), '').length;

    // Estrai parole (esercizio: split + filter)
    final words = _extractWords(text);
    final wordCount = words.length;

    // Trova parola più lunga (esercizio: loop + confronto)
    final longestWord = _findLongestWord(words);

    // Conta frasi (esercizio: regex + split)
    final sentenceCount = _countSentences(text);

    // Conta paragrafi (esercizio: split su newline multipli)
    final paragraphCount = _countParagraphs(text);

    // Calcola lunghezza media parole (esercizio: loop + somma + divisione)
    final averageWordLength = wordCount > 0
        ? words.map((w) => w.length).reduce((a, b) => a + b) / wordCount
        : 0.0;

    return TextAnalysisModel(
      text: text,
      wordCount: wordCount,
      characterCount: characterCount,
      characterCountWithSpaces: characterCountWithSpaces,
      longestWord: longestWord,
      sentenceCount: sentenceCount,
      paragraphCount: paragraphCount,
      averageWordLength: averageWordLength,
      analyzedAt: DateTime.now(),
    );
  }

  /// Estrae le parole dal testo
  List<String> _extractWords(String text) {
    // Split su whitespace e rimuovi parole vuote
    return text
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .map((word) => word.replaceAll(RegExp(r'[^\w\sàèéìòùÀÈÉÌÒÙ]'), ''))
        .where((word) => word.isNotEmpty)
        .toList();
  }

  /// Trova la parola più lunga
  String _findLongestWord(List<String> words) {
    if (words.isEmpty) return '';

    String longest = words[0];

    // Loop classico per trovare il massimo
    for (var word in words) {
      if (word.length > longest.length) {
        longest = word;
      }
    }

    return longest;
  }

  /// Conta le frasi nel testo
  int _countSentences(String text) {
    if (text.trim().isEmpty) return 0;

    // Split su . ! ? seguito da spazio o fine stringa
    final sentences = text.split(RegExp(r'[.!?]+(?:\s|$)'))
        .where((s) => s.trim().isNotEmpty)
        .toList();

    return sentences.length;
  }

  /// Conta i paragrafi nel testo
  int _countParagraphs(String text) {
    if (text.trim().isEmpty) return 0;

    // Split su 2 o più newline (paragrafi separati da riga vuota)
    final paragraphs = text.split(RegExp(r'\n\s*\n'))
        .where((p) => p.trim().isNotEmpty)
        .toList();

    return paragraphs.length > 0 ? paragraphs.length : 1;
  }

  /// Salva analisi nella cronologia
  Future<void> addToHistory(TextAnalysisModel analysis) async {
    // Aggiungi in testa
    _history.insert(0, analysis);

    // Limita dimensione cronologia
    if (_history.length > _maxHistorySize) {
      _history = _history.sublist(0, _maxHistorySize);
    }

    await _saveHistory();
  }

  /// Carica cronologia da storage
  Future<void> loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_historyKey);

      if (historyJson != null) {
        final List<dynamic> historyList = json.decode(historyJson);
        _history = historyList
            .map((item) => TextAnalysisModel.fromJson(item))
            .toList();
      }
    } catch (e) {
      print('Errore caricamento cronologia analisi: $e');
      _history = [];
    }
  }

  /// Salva cronologia su storage
  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = json.encode(
        _history.map((item) => item.toJson()).toList(),
      );
      await prefs.setString(_historyKey, historyJson);
    } catch (e) {
      print('Errore salvataggio cronologia analisi: $e');
    }
  }

  /// Cancella cronologia
  Future<void> clearHistory() async {
    _history.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  /// Elimina singolo elemento dalla cronologia
  Future<void> deleteFromHistory(int index) async {
    if (index >= 0 && index < _history.length) {
      _history.removeAt(index);
      await _saveHistory();
    }
  }

  /// Ottiene statistiche aggregate sulla cronologia
  Map<String, dynamic> getHistoryStats() {
    if (_history.isEmpty) {
      return {
        'totalAnalyses': 0,
        'totalWords': 0,
        'totalCharacters': 0,
        'averageWords': 0.0,
        'longestAnalysis': '',
      };
    }

    final totalWords = _history
        .map((a) => a.wordCount)
        .reduce((a, b) => a + b);

    final totalCharacters = _history
        .map((a) => a.characterCount)
        .reduce((a, b) => a + b);

    final averageWords = totalWords / _history.length;

    // Trova l'analisi più lunga
    var longestAnalysis = _history[0];
    for (var analysis in _history) {
      if (analysis.wordCount > longestAnalysis.wordCount) {
        longestAnalysis = analysis;
      }
    }

    return {
      'totalAnalyses': _history.length,
      'totalWords': totalWords,
      'totalCharacters': totalCharacters,
      'averageWords': averageWords,
      'longestAnalysis': longestAnalysis.text.substring(
        0,
        longestAnalysis.text.length > 50 ? 50 : longestAnalysis.text.length,
      ) + (longestAnalysis.text.length > 50 ? '...' : ''),
    };
  }
}