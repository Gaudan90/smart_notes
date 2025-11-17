import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/import_result.dart';
import '../states/supermarket_purchase_model.dart';

class SupermarketTrackerPresenter {
  static const String _purchasesKey = 'supermarket_purchases';
  final List<SupermarketPurchaseModel> _purchases = [];
  final Random _random = Random();

  List<SupermarketPurchaseModel> get purchases => List.unmodifiable(_purchases);

  // Genera un ID veramente univoco combinando timestamp e numero casuale
  String _generateUniqueId() {
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final randomSuffix = _random.nextInt(999999);
    return '${timestamp}_$randomSuffix';
  }

  static const List<String> supermarkets = [
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

  Future<void> loadPurchases() async {
    final prefs = await SharedPreferences.getInstance();
    final String? purchasesJson = prefs.getString(_purchasesKey);

    if (purchasesJson != null) {
      final List<dynamic> decodedList = json.decode(purchasesJson);
      _purchases.clear();
      _purchases.addAll(
        decodedList.map((item) => SupermarketPurchaseModel.fromJson(item)).toList(),
      );

      // Rigenera ID duplicati (fix retroattivo)
      await _migrateAndFixDuplicateIds();

      _sortPurchases();
    }
  }

  // Migrazione automatica per fix ID duplicati
  Future<void> _migrateAndFixDuplicateIds() async {
    // Trova ID duplicati
    final Set<String> seenIds = {};
    final List<int> duplicateIndexes = [];

    for (int i = 0; i < _purchases.length; i++) {
      final id = _purchases[i].id;
      if (seenIds.contains(id)) {
        duplicateIndexes.add(i);
      } else {
        seenIds.add(id);
      }
    }

    // Se ci sono duplicati, rigenera gli ID
    if (duplicateIndexes.isNotEmpty) {
      print('Migrazione: Trovati ${duplicateIndexes.length} ID duplicati. Rigenerazione in corso...');

      for (final index in duplicateIndexes) {
        final oldPurchase = _purchases[index];
        _purchases[index] = SupermarketPurchaseModel(
          id: _generateUniqueId(),  // Nuovo ID univoco
          productName: oldPurchase.productName,
          supermarket: oldPurchase.supermarket,
          purchaseDate: oldPurchase.purchaseDate,
          price: oldPurchase.price,
          quantity: oldPurchase.quantity,
        );
      }

      // Salva i dati migrati
      await _savePurchases();
      print('Migrazione completata: ${duplicateIndexes.length} ID rigenerati');
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
    _purchases.sort((a, b) {
      // Prima per data (più recente prima)
      final dateComparison = b.purchaseDate.compareTo(a.purchaseDate);

      // Se le date sono uguali, ordina alfabeticamente per nome prodotto
      if (dateComparison == 0) {
        return a.productName.toLowerCase().compareTo(b.productName.toLowerCase());
      }

      return dateComparison;
    });
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
      id: _generateUniqueId(),  // ID univoco con timestamp + random
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
    for (var supermarket in supermarkets) {
      counts[supermarket] = _purchases.where((p) => p.supermarket == supermarket).length;
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
    buffer.writeln('# Export Supermercati - ${DateTime.now().toString().split('.')[0]}');
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

