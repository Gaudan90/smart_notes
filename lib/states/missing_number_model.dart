class MissingNumbersModel {
  final List<int> sequence;

  MissingNumbersModel({required this.sequence});

  List<int> findMissing() {
    if (sequence.isEmpty) return [];

    final sorted = List<int>.from(sequence)..sort();
    final missing = <int>[];

    for (int i = sorted.first; i < sorted.last; i++) {
      if (!sorted.contains(i)) {
        missing.add(i);
      }
    }

    return missing;
  }
}