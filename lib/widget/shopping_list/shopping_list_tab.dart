import 'package:flutter/material.dart';
import '../../controllers/shopping_list_presenter.dart';
import '../../states/shopping_item_model.dart';
import 'shopping_add_dialog.dart';
import 'shopping_edit_dialog.dart';
import 'shopping_item_card.dart';
import 'shopping_quick_add_sheet.dart';

class ShoppingListTab extends StatefulWidget {
  final ShoppingListPresenter presenter;
  final VoidCallback onUpdate;

  const ShoppingListTab({
    super.key,
    required this.presenter,
    required this.onUpdate,
  });

  @override
  State<ShoppingListTab> createState() => _ShoppingListTabState();
}

class _ShoppingListTabState extends State<ShoppingListTab> {
  bool _showGrouped = false;

  void _showAddItemDialog() {
    showDialog(
      context: context,
      builder: (context) => ShoppingAddDialog(
        presenter: widget.presenter,
        onItemAdded: widget.onUpdate,
      ),
    );
  }

  void _showQuickAdd() {
    showModalBottomSheet(
      context: context,
      builder: (context) => ShoppingQuickAddSheet(
        presenter: widget.presenter,
        onItemAdded: widget.onUpdate,
      ),
    );
  }

  void _showEditItemDialog(ShoppingItemModel item) {
    showDialog(
      context: context,
      builder: (context) => ShoppingEditDialog(
        presenter: widget.presenter,
        item: item,
        onItemUpdated: widget.onUpdate,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _showQuickAdd,
                  icon: const Icon(Icons.flash_on, size: 18),
                  label: const Text('Rapido'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _showAddItemDialog,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Aggiungi'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Toggle vista
              IconButton(
                icon: Icon(_showGrouped ? Icons.list : Icons.grid_view),
                onPressed: () {
                  setState(() {
                    _showGrouped = !_showGrouped;
                  });
                },
                tooltip: _showGrouped ? 'Vista Lista' : 'Raggruppa',
              ),
              if (widget.presenter.purchasedItems.isNotEmpty)
                PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: const Row(
                        children: [
                          Icon(Icons.cleaning_services, size: 20),
                          SizedBox(width: 8),
                          Text('Rimuovi comprati'),
                        ],
                      ),
                      onTap: () async {
                        await Future.delayed(Duration.zero);
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
                          await widget.presenter.clearPurchased();
                          widget.onUpdate();
                        }
                      },
                    ),
                  ],
                ),
            ],
          ),
        ),

        // Lista prodotti
        Expanded(
          child: widget.presenter.items.isEmpty
              ? _buildEmptyState()
              : _showGrouped
              ? _buildGroupedList()
              : _buildFlatList(),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
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
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showAddItemDialog,
            icon: const Icon(Icons.add),
            label: const Text('Aggiungi primo prodotto'),
          ),
        ],
      ),
    );
  }

  Widget _buildFlatList() {
    return ListView.builder(
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: 16,
      ),
      itemCount: widget.presenter.items.length,
      itemBuilder: (context, index) {
        final item = widget.presenter.items[index];
        return ShoppingItemCard(
          item: item,
          onTogglePurchased: () async {
            await widget.presenter.togglePurchased(item.id);
            widget.onUpdate();
          },
          onIncrement: () async {
            await widget.presenter.incrementQuantity(item.id);
            widget.onUpdate();
          },
          onDecrement: () async {
            await widget.presenter.decrementQuantity(item.id);
            widget.onUpdate();
          },
          onDelete: () async {
            await widget.presenter.removeItem(item.id);
            widget.onUpdate();
          },
          onEdit: () => _showEditItemDialog(item),
        );
      },
    );
  }

  Widget _buildGroupedList() {
    final grouped = widget.presenter.getItemsByCategory();

    return ListView.builder(
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: 16,
      ),
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
                await widget.presenter.togglePurchased(item.id);
                widget.onUpdate();
              },
              onIncrement: () async {
                await widget.presenter.incrementQuantity(item.id);
                widget.onUpdate();
              },
              onDecrement: () async {
                await widget.presenter.decrementQuantity(item.id);
                widget.onUpdate();
              },
              onDelete: () async {
                await widget.presenter.removeItem(item.id);
                widget.onUpdate();
              },
              onEdit: () => _showEditItemDialog(item),
            )),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}