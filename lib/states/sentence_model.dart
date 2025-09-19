class SentenceModel {
  final String sentence;

  SentenceModel({required this.sentence});

  String reverse() {
    return sentence.split(' ').reversed.join(' ');
  }
}