class TextAnalysisModel {
  final String text;
  final int wordCount;
  final int characterCount;
  final int characterCountWithSpaces;
  final String longestWord;
  final int sentenceCount;
  final int paragraphCount;
  final double averageWordLength;
  final DateTime analyzedAt;

  TextAnalysisModel({
    required this.text,
    required this.wordCount,
    required this.characterCount,
    required this.characterCountWithSpaces,
    required this.longestWord,
    required this.sentenceCount,
    required this.paragraphCount,
    required this.averageWordLength,
    required this.analyzedAt,
  });

  factory TextAnalysisModel.empty() {
    return TextAnalysisModel(
      text: '',
      wordCount: 0,
      characterCount: 0,
      characterCountWithSpaces: 0,
      longestWord: '',
      sentenceCount: 0,
      paragraphCount: 0,
      averageWordLength: 0.0,
      analyzedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'wordCount': wordCount,
      'characterCount': characterCount,
      'characterCountWithSpaces': characterCountWithSpaces,
      'longestWord': longestWord,
      'sentenceCount': sentenceCount,
      'paragraphCount': paragraphCount,
      'averageWordLength': averageWordLength,
      'analyzedAt': analyzedAt.toIso8601String(),
    };
  }

  factory TextAnalysisModel.fromJson(Map<String, dynamic> json) {
    return TextAnalysisModel(
      text: json['text'] ?? '',
      wordCount: json['wordCount'] ?? 0,
      characterCount: json['characterCount'] ?? 0,
      characterCountWithSpaces: json['characterCountWithSpaces'] ?? 0,
      longestWord: json['longestWord'] ?? '',
      sentenceCount: json['sentenceCount'] ?? 0,
      paragraphCount: json['paragraphCount'] ?? 0,
      averageWordLength: (json['averageWordLength'] ?? 0.0).toDouble(),
      analyzedAt: DateTime.parse(json['analyzedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  TextAnalysisModel copyWith({
    String? text,
    int? wordCount,
    int? characterCount,
    int? characterCountWithSpaces,
    String? longestWord,
    int? sentenceCount,
    int? paragraphCount,
    double? averageWordLength,
    DateTime? analyzedAt,
  }) {
    return TextAnalysisModel(
      text: text ?? this.text,
      wordCount: wordCount ?? this.wordCount,
      characterCount: characterCount ?? this.characterCount,
      characterCountWithSpaces: characterCountWithSpaces ?? this.characterCountWithSpaces,
      longestWord: longestWord ?? this.longestWord,
      sentenceCount: sentenceCount ?? this.sentenceCount,
      paragraphCount: paragraphCount ?? this.paragraphCount,
      averageWordLength: averageWordLength ?? this.averageWordLength,
      analyzedAt: analyzedAt ?? this.analyzedAt,
    );
  }
}