class ShoppingItemModel {
  final String id;
  final String name;
  int quantity;
  final String category;
  double? price;
  bool isPurchased;
  final DateTime addedAt;

  ShoppingItemModel({
    required this.id,
    required this.name,
    this.quantity = 1,
    required this.category,
    this.price,
    this.isPurchased = false,
    required this.addedAt,
  });

  double get totalCost {
    if (price == null) return 0.0;
    return price! * quantity;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'category': category,
      'price': price,
      'isPurchased': isPurchased,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  factory ShoppingItemModel.fromJson(Map<String, dynamic> json) {
    return ShoppingItemModel(
      id: json['id'],
      name: json['name'],
      quantity: json['quantity'] ?? 1,
      category: json['category'],
      price: json['price']?.toDouble(),
      isPurchased: json['isPurchased'] ?? false,
      addedAt: DateTime.parse(json['addedAt']),
    );
  }

  ShoppingItemModel copyWith({
    String? name,
    int? quantity,
    String? category,
    double? price,
    bool? isPurchased,
  }) {
    return ShoppingItemModel(
      id: id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      category: category ?? this.category,
      price: price ?? this.price,
      isPurchased: isPurchased ?? this.isPurchased,
      addedAt: addedAt,
    );
  }
}