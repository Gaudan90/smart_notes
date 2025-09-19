class NumberStatsModel {
  final List<double> numbers;

  NumberStatsModel({required this.numbers});

  Map<double, int> getFrequencyMap() {
    final frequencyMap = <double, int>{};
    for (final num in numbers) {
      frequencyMap[num] = (frequencyMap[num] ?? 0) + 1;
    }
    return frequencyMap;
  }

  double? getMostFrequent() {
    if (numbers.isEmpty) return null;

    final frequencyMap = getFrequencyMap();
    double? mostFrequent;
    int maxCount = 0;

    frequencyMap.forEach((num, count) {
      if (count > maxCount) {
        maxCount = count;
        mostFrequent = num;
      }
    });

    return mostFrequent;
  }
}