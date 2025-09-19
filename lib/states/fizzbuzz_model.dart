class FizzBuzzModel {
  final int limit;
  final String fizzLabel;
  final String buzzLabel;
  final String fizzBuzzLabel;

  FizzBuzzModel({
    required this.limit,
    this.fizzLabel = 'Studio',
    this.buzzLabel = 'Allenamento',
    this.fizzBuzzLabel = 'Riposo',
  });

  List<String> generate() {
    final result = <String>[];

    for (int i = 1; i <= limit; i++) {
      if (i % 15 == 0) {
        result.add('Giorno $i: $fizzBuzzLabel');
      } else if (i % 3 == 0) {
        result.add('Giorno $i: $fizzLabel');
      } else if (i % 5 == 0) {
        result.add('Giorno $i: $buzzLabel');
      } else {
        result.add('Giorno $i: Normale');
      }
    }

    return result;
  }
}