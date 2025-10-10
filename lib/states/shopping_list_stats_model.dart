class ShoppingListStats {
  final int totalItems;
  final int purchasedItems;
  final int remainingItems;
  final double totalCost;
  final double purchasedCost;
  final double remainingCost;
  final Map<String, int> itemsByCategory;
  final Map<String, double> costByCategory;

  ShoppingListStats({
    required this.totalItems,
    required this.purchasedItems,
    required this.remainingItems,
    required this.totalCost,
    required this.purchasedCost,
    required this.remainingCost,
    required this.itemsByCategory,
    required this.costByCategory,
  });

  double get completionPercentage {
    if (totalItems == 0) return 0.0;
    return (purchasedItems / totalItems) * 100;
  }

  String get completionText {
    return '$purchasedItems/$totalItems prodotti';
  }

  String get totalCostText {
    return totalCost > 0 ? '€${totalCost.toStringAsFixed(2)}' : 'N/A';
  }

  bool get isComplete {
    return totalItems > 0 && purchasedItems == totalItems;
  }
}