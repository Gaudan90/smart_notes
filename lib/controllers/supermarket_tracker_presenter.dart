import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/import_result.dart';
import '../states/supermarket_purchase_model.dart';
import '../states/custom_supermarket_model.dart';

class SupermarketTrackerPresenter {
  static const String _purchasesKey = 'supermarket_purchases';
  static const String _customSupermarketsKey = 'custom_supermarkets';
  final List<SupermarketPurchaseModel> _purchases = [];
  final List<CustomSupermarketModel> _customSupermarkets = [];

  List<SupermarketPurchaseModel> get purchases => List.unmodifiable(_purchases);
  List<CustomSupermarketModel> get customSupermarkets => List.unmodifiable(_customSupermarkets);

  // Supermercati di default
  static const List<String> defaultSupermarkets = [
    'U2',
    'Gigante',
    'Bennet',
    'Carrefour',
    'Mercato',
    'Ipercoop',
    'Coop',
    'Lidl',
    'Action',
  ];

  // Lista unificata: default + custom (senza duplicati)
  List<String> get allSupermarkets {
    return [
      ...defaultSupermarkets,
      ..._customSupermarkets.map((s) => s.name),
    ].toSet().toList();
  }

  // Backward compatibility
  static List<String> get supermarkets => defaultSupermarkets;

  Future<void> loadPurchases() async {
    final prefs = await SharedPreferences.getInstance();
    final String? purchasesJson = prefs.getString(_purchasesKey);

    if (purchasesJson != null) {
      final List<dynamic> decodedList = json.decode(purchasesJson);
      _purchases.clear();
      _purchases.addAll(
        decodedList.map((item) => SupermarketPurchaseModel.fromJson(item)).toList(),
      );
      _sortPurchases();
    }
  }

  Future<void> loadCustomSupermarkets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? customJson = prefs.getString(_customSupermarketsKey);

      if (customJson != null) {
        final List<dynamic> decodedList = json.decode(customJson);
        _customSupermarkets.clear();
        _customSupermarkets.addAll(
          decodedList.map((item) => CustomSupermarketModel.fromJson(item)).toList(),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Errore caricamento supermercati custom: $e');
      }
      _customSupermarkets.clear();
    }
  }

  Future<void> _saveCustomSupermarkets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encodedList = json.encode(
        _customSupermarkets.map((s) => s.toJson()).toList(),
      );
      await prefs.setString(_customSupermarketsKey, encodedList);
    } catch (e) {
      if (kDebugMode) {
        print('Errore salvataggio supermercati custom: $e');
      }
    }
  }

  Future<void> addCustomSupermarket(String name, int colorValue) async {
    if (name.trim().isEmpty) return;

    // Check duplicati
    if (defaultSupermarkets.contains(name.trim()) ||
        _customSupermarkets.any((s) => s.name == name.trim())) {
      throw Exception('Supermercato già esistente');
    }

    final customSupermarket = CustomSupermarketModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
      colorValue: colorValue,
    );

    _customSupermarkets.add(customSupermarket);
    await _saveCustomSupermarkets();
  }

  Future<void> deleteCustomSupermarket(String id) async {
    _customSupermarkets.removeWhere((s) => s.id == id);
    await _saveCustomSupermarkets();
  }

  Future<void> updateCustomSupermarket
      (String id, String newName, int newColorValue) async {
    final index = _customSupermarkets.indexWhere((s) => s.id == id);
    if (index == -1) return;

    // Check duplicati (escluso l'elemento corrente)
    if (defaultSupermarkets.contains(newName.trim()) ||
        _customSupermarkets.any((s) => s.id != id && s.name == newName.trim())) {
      throw Exception('Nome supermercato già esistente');
    }

    _customSupermarkets[index] = CustomSupermarketModel(
      id: id,
      name: newName.trim(),
      colorValue: newColorValue,
    );

    await _saveCustomSupermarkets();
  }

  CustomSupermarketModel? getCustomSupermarket(String name) {
    try {
      return _customSupermarkets.firstWhere((s) => s.name == name);
    } catch (e) {
      return null;
    }
  }

  Future<void> _savePurchases() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedList = json.encode(
      _purchases.map((purchase) => purchase.toJson()).toList(),
    );
    await prefs.setString(_purchasesKey, encodedList);
  }

  void _sortPurchases() {
    _purchases.sort((a, b) => b.purchaseDate.compareTo(a.purchaseDate));
  }

  Future<void> addPurchase({
    required String productName,
    required String supermarket,
    required DateTime purchaseDate,
    double? price,
    int quantity = 1,
  }) async {
    if (productName.trim().isEmpty) return;

    final purchase = SupermarketPurchaseModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      productName: productName.trim(),
      supermarket: supermarket,
      purchaseDate: purchaseDate,
      price: price,
      quantity: quantity,
    );

    _purchases.add(purchase);
    _sortPurchases();
    await _savePurchases();
  }

  Future<void> updatePurchase({
    required String id,
    required String productName,
    required String supermarket,
    required DateTime purchaseDate,
    double? price,
    int quantity = 1,
  }) async {
    final index = _purchases.indexWhere((purchase) => purchase.id == id);
    if (index == -1) return;

    _purchases[index] = SupermarketPurchaseModel(
      id: id,
      productName: productName.trim(),
      supermarket: supermarket,
      purchaseDate: purchaseDate,
      price: price,
      quantity: quantity,
    );

    _sortPurchases();
    await _savePurchases();
  }

  Future<void> deletePurchase(String id) async {
    _purchases.removeWhere((purchase) => purchase.id == id);
    await _savePurchases();
  }

  Future<void> clearAll() async {
    _purchases.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_purchasesKey);
  }

  // RICERCA E FILTRI
  List<SupermarketPurchaseModel> searchPurchases(String query) {
    if (query.trim().isEmpty) return _purchases;

    final lowerQuery = query.toLowerCase();
    return _purchases.where((purchase) {
      return purchase.productName.toLowerCase().contains(lowerQuery) ||
          purchase.supermarket.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  Map<String, List<SupermarketPurchaseModel>> getPurchasesBySupermarket() {
    final Map<String, List<SupermarketPurchaseModel>> grouped = {};

    for (var purchase in _purchases) {
      grouped[purchase.supermarket] = grouped[purchase.supermarket] ?? [];
      grouped[purchase.supermarket]!.add(purchase);
    }

    return grouped;
  }

  List<SupermarketPurchaseModel> getPurchasesForSupermarket(String supermarket) {
    return _purchases.where((p) => p.supermarket == supermarket).toList();
  }

  // STATISTICHE
  Map<String, int> getProductCountBySupermarket() {
    final Map<String, int> counts = {};
    for (var supermarket in allSupermarkets) {
      counts[supermarket] = _purchases.where((p) =>
      p.supermarket == supermarket).length;
    }
    return counts;
  }

  double getTotalSpentInSupermarket(String supermarket) {
    return _purchases
        .where((p) => p.supermarket == supermarket && p.price != null)
        .fold(0.0, (sum, p) => sum + (p.price! * p.quantity));
  }

  // EXPORT / IMPORT TXT
  String exportToText() {
    if (_purchases.isEmpty) {
      return '# Nessun acquisto registrato\n';
    }

    final buffer = StringBuffer();
    buffer.writeln('# Export Supermercati - '
        '${DateTime.now().toString().split('.')[0]}');
    buffer.writeln('# Formato: Supermercato|Prodotto|Data|Quantità|Prezzo');
    buffer.writeln('# ========================================\n');

    for (var purchase in _purchases) {
      buffer.writeln(purchase.toTextLine());
    }

    buffer.writeln('\n# ========================================');
    buffer.writeln('# Totale acquisti: ${_purchases.length}');

    return buffer.toString();
  }

  Future<ImportResult> importFromText(String textContent) async {
    final lines = textContent.split('\n');
    int imported = 0;
    int skipped = 0;

    for (var line in lines) {
      final trimmed = line.trim();

      // Salta righe vuote e commenti
      if (trimmed.isEmpty || trimmed.startsWith('#')) continue;

      final purchase = SupermarketPurchaseModel.fromTextLine(trimmed);
      if (purchase != null) {
        _purchases.add(purchase);
        imported++;
      } else {
        skipped++;
      }
    }

    if (imported > 0) {
      _sortPurchases();
      await _savePurchases();
    }

    return ImportResult(
      imported: imported,
      skipped: skipped,
      total: imported + skipped,
    );
  }
}

