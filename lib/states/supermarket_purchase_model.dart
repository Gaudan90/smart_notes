class SupermarketPurchaseModel {
  final String id;
  final String productName;
  final String supermarket;
  final DateTime purchaseDate;
  final double? price;
  final int quantity;

  SupermarketPurchaseModel({
    required this.id,
    required this.productName,
    required this.supermarket,
    required this.purchaseDate,
    this.price,
    this.quantity = 1,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productName': productName,
      'supermarket': supermarket,
      'purchaseDate': purchaseDate.toIso8601String(),
      'price': price,
      'quantity': quantity,
    };
  }

  factory SupermarketPurchaseModel.fromJson(Map<String, dynamic> json) {
    return SupermarketPurchaseModel(
      id: json['id'],
      productName: json['productName'],
      supermarket: json['supermarket'],
      purchaseDate: DateTime.parse(json['purchaseDate']),
      price: json['price']?.toDouble(),
      quantity: json['quantity'] ?? 1,
    );
  }

  String toTextLine() {
    final priceText = price != null ? '€${price!.toStringAsFixed(2)}' : 'N/A';
    return '$supermarket|$productName|${_formatDate(purchaseDate)}|$quantity|$priceText';
  }

  static SupermarketPurchaseModel? fromTextLine(String line) {
    try {
      final parts = line.split('|');
      if (parts.length < 4) return null;

      final supermarket = parts[0];
      final productName = parts[1];
      final dateStr = parts[2];
      final quantity = int.tryParse(parts[3]) ?? 1;
      final priceStr = parts.length > 4 ? parts[4] : null;

      final dateParts = dateStr.split('/');
      if (dateParts.length != 3) return null;

      final day = int.parse(dateParts[0]);
      final month = int.parse(dateParts[1]);
      final year = int.parse(dateParts[2]);
      final purchaseDate = DateTime(year, month, day);

      double? price;
      if (priceStr != null && priceStr != 'N/A') {
        price = double.tryParse(priceStr.replaceAll('€', '').trim());
      }

      return SupermarketPurchaseModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        productName: productName,
        supermarket: supermarket,
        purchaseDate: purchaseDate,
        price: price,
        quantity: quantity,
      );
    } catch (e) {
      return null;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}