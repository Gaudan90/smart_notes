import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../states/shopping_item_model.dart';
import '../states/shopping_list_stats_model.dart';

class ShoppingListPresenter {
  static const String _itemsKey = 'shopping_list_items';
  final List<ShoppingItemModel> _items = [];

  List<ShoppingItemModel> get items => List.unmodifiable(_items);

  static const List<String> categories = [
    'Frutta e Verdura',
    'Latticini',
    'Carne e Pesce',
    'Pane e Cereali',
    'Bevande',
    'Dolci',
    'Surgelati',
    'Igiene Personale',
    'Casa',
    'Altro',
  ];

  Future<void> loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final String? itemsJson = prefs.getString(_itemsKey);

    if (itemsJson != null) {
      final List<dynamic> decodedList = json.decode(itemsJson);
      _items.clear();
      _items.addAll(
        decodedList.map((item) => ShoppingItemModel.fromJson(item)).toList(),
      );
      _sortItems();
    }
  }

  Future<void> _saveItems() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedList = json.encode(
      _items.map((item) => item.toJson()).toList(),
    );
    await prefs.setString(_itemsKey, encodedList);
  }

  void _sortItems() {
    _items.sort((a, b) {
      if (a.isPurchased != b.isPurchased) {
        return a.isPurchased ? 1 : -1;
      }
      return a.category.compareTo(b.category);
    });
  }

  Future<String> addItem({
    required String name,
    required String category,
    int quantity = 1,
    double? price,
  }) async {
    if (name.trim().isEmpty || quantity <= 0) {
      return 'Inserisci dati validi';
    }

    final trimmedName = name.trim();

    final existingItem = _findDuplicateItem(trimmedName);

    if (existingItem != null) {
      existingItem.quantity += quantity;

      if (price != null && price > 0) {
        existingItem.price = price;
      }

      _sortItems();
      await _saveItems();
      return 'Quantità aggiornata: ${existingItem.name} (x${existingItem.quantity})';
    }

    final newItem = ShoppingItemModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: trimmedName,
      quantity: quantity,
      category: category,
      price: price,
      addedAt: DateTime.now(),
    );

    _items.add(newItem);
    _sortItems();
    await _saveItems();
    return 'Prodotto aggiunto: ${newItem.name}';
  }

  ShoppingItemModel? _findDuplicateItem(String name) {
    final lowerName = name.toLowerCase();

    for (int i = 0; i < _items.length; i++) {
      if (_items[i].name.toLowerCase() == lowerName) {
        return _items[i];
      }
    }

    return null;
  }

  Future<void> updateQuantity(String id, int newQuantity) async {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      if (newQuantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = newQuantity;
      }
      await _saveItems();
    }
  }

  Future<void> incrementQuantity(String id) async {
    final item = _items.firstWhere((item) => item.id == id);
    item.quantity++;
    await _saveItems();
  }

  Future<void> decrementQuantity(String id) async {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }
      await _saveItems();
    }
  }

  Future<void> togglePurchased(String id) async {
    final item = _items.firstWhere((item) => item.id == id);
    item.isPurchased = !item.isPurchased;
    _sortItems();
    await _saveItems();
  }

  Future<void> removeItem(String id) async {
    _items.removeWhere((item) => item.id == id);
    await _saveItems();
  }

  Future<void> clearPurchased() async {
    _items.removeWhere((item) => item.isPurchased);
    await _saveItems();
  }

  Future<void> clearAll() async {
    _items.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_itemsKey);
  }

  ShoppingListStats calculateStats() {
    int totalItems = 0;
    int purchasedItems = 0;
    double totalCost = 0.0;
    double purchasedCost = 0.0;

    Map<String, int> itemsByCategory = {};
    Map<String, double> costByCategory = {};

    for (int i = 0; i < _items.length; i++) {
      final item = _items[i];

      totalItems += item.quantity;
      totalCost += item.totalCost;

      if (item.isPurchased) {
        purchasedItems += item.quantity;
        purchasedCost += item.totalCost;
      }

      itemsByCategory[item.category] =
          (itemsByCategory[item.category] ?? 0) + item.quantity;

      costByCategory[item.category] =
          (costByCategory[item.category] ?? 0.0) + item.totalCost;
    }

    return ShoppingListStats(
      totalItems: totalItems,
      purchasedItems: purchasedItems,
      remainingItems: totalItems - purchasedItems,
      totalCost: totalCost,
      purchasedCost: purchasedCost,
      remainingCost: totalCost - purchasedCost,
      itemsByCategory: itemsByCategory,
      costByCategory: costByCategory,
    );
  }

  Map<String, List<ShoppingItemModel>> getItemsByCategory() {
    final Map<String, List<ShoppingItemModel>> grouped = {};

    for (var item in _items) {
      grouped[item.category] = grouped[item.category] ?? [];
      grouped[item.category]!.add(item);
    }

    return grouped;
  }

  List<ShoppingItemModel> get remainingItems {
    return _items.where((item) => !item.isPurchased).toList();
  }

  List<ShoppingItemModel> get purchasedItems {
    return _items.where((item) => item.isPurchased).toList();
  }

  bool itemExists(String name) {
    return _findDuplicateItem(name.trim()) != null;
  }

  int getItemQuantity(String name) {
    final item = _findDuplicateItem(name.trim());
    return item?.quantity ?? 0;
  }

  /// PRODOTTI FREQUENTI (FEATURE BONUS)
  // Questa funzione potrebbe essere estesa per salvare
  // uno storico dei prodotti più acquistati
  List<String> getFrequentProducts() {
    // TODO: Implementare storico prodotti frequenti
    return [
      'Latte',
      'Pane',
      'Uova',
      'Pasta',
      'Pomodori',
      'Banane',
      'Mele',
      'Insalata',
      'Carne macinata',
      'Formaggio',
    ];
  }
}