import 'package:flutter/material.dart';
import '../controllers/shopping_list_presenter.dart';
import '../widget/shopping_list/shopping_add_dialog.dart';
import '../widget/shopping_list/shopping_item_card.dart';
import '../widget/shopping_list/shopping_quick_add_sheet.dart';
import '../widget/shopping_list/shopping_stats_tab.dart';

class ShoppingListView extends StatefulWidget {
  const ShoppingListView({super.key});

  @override
  State<ShoppingListView> createState() => _ShoppingListViewState();
}

class _ShoppingListViewState extends State<ShoppingListView>
    with SingleTickerProviderStateMixin {
  final _presenter = ShoppingListPresenter();

  bool _isLoading = true;
  late TabController _tabController;
  bool _showGrouped = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadItems();
  }

  Future<void> _loadItems() async {
    await _presenter.loadItems();
    setState(() {
      _isLoading = false;
    });
  }

  void _showAddItemDialog() {
    showDialog(
      context: context,
      builder: (context) => ShoppingAddDialog(
        presenter: _presenter,
        onItemAdded: () => setState(() {}),
      ),
    );
  }

  void _showQuickAdd() {
    showModalBottomSheet(
      context: context,
      builder: (context) => ShoppingQuickAddSheet(
        presenter: _presenter,
        onItemAdded: () => setState(() {}),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stats = _presenter.calculateStats();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista della Spesa'),
        actions: [
          IconButton(
            icon: Icon(_showGrouped ? Icons.list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _showGrouped = !_showGrouped;
              });
            },
            tooltip: _showGrouped ? 'Vista Lista' : 'Raggruppa',
          ),
          if (_presenter.purchasedItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.cleaning_services),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Svuota comprati'),
                    content: const Text('Rimuovere tutti i prodotti già comprati?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Annulla'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Rimuovi'),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await _presenter.clearPurchased();
                  setState(() {});
                }
              },
              tooltip: 'Rimuovi comprati',
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Lista', icon: Icon(Icons.shopping_cart)),
            Tab(text: 'Statistiche', icon: Icon(Icons.analytics)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: [
          _buildListTab(),
          ShoppingStatsTab(stats: stats),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.small(
            heroTag: 'quick',
            onPressed: _showQuickAdd,
            child: const Icon(Icons.flash_on),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'add',
            onPressed: _showAddItemDialog,
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Widget _buildListTab() {
    if (_presenter.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_basket,
              size: 64,
              color: Theme.of(context).disabledColor,
            ),
            const SizedBox(height: 16),
            const Text(
              'Lista vuota',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'Aggiungi i tuoi prodotti',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (_showGrouped) {
      return _buildGroupedList();
    }

    return _buildFlatList();
  }

  Widget _buildFlatList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _presenter.items.length,
      itemBuilder: (context, index) {
        final item = _presenter.items[index];
        return ShoppingItemCard(
          item: item,
          onTogglePurchased: () async {
            await _presenter.togglePurchased(item.id);
            setState(() {});
          },
          onIncrement: () async {
            await _presenter.incrementQuantity(item.id);
            setState(() {});
          },
          onDecrement: () async {
            await _presenter.decrementQuantity(item.id);
            setState(() {});
          },
          onDelete: () async {
            await _presenter.removeItem(item.id);
            setState(() {});
          },
        );
      },
    );
  }

  Widget _buildGroupedList() {
    final grouped = _presenter.getItemsByCategory();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final category = grouped.keys.elementAt(index);
        final items = grouped[category]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                category,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            ...items.map((item) => ShoppingItemCard(
              item: item,
              onTogglePurchased: () async {
                await _presenter.togglePurchased(item.id);
                setState(() {});
              },
              onIncrement: () async {
                await _presenter.incrementQuantity(item.id);
                setState(() {});
              },
              onDecrement: () async {
                await _presenter.decrementQuantity(item.id);
                setState(() {});
              },
              onDelete: () async {
                await _presenter.removeItem(item.id);
                setState(() {});
              },
            )),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}