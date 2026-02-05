import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../controllers/shopping_list_presenter.dart';
import '../../data/shopping_list/sort_type_enum.dart';
import '../../states/shopping_item_model.dart';
import 'shopping_add_dialog.dart';
import 'shopping_edit_dialog.dart';
import 'shopping_item_card.dart';
import 'shopping_quick_add_sheet.dart';
import 'shopping_search_bar.dart';

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
  bool _showSearch = false;

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

  void _toggleSortOrder() {
    setState(() {
      widget.presenter.toggleSortType();
    });
    widget.onUpdate();
  }

  void _onSearchQueryChanged(String query) {
    setState(() {
      widget.presenter.setSearchQuery(query);
    });
  }

  void _clearSearch() {
    setState(() {
      widget.presenter.clearSearch();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isAlphabetical = widget.presenter
        .currentSortType == SortType.alphabetical;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          isAlphabetical ? 'sort_alphabetical'.tr() : 'sort_category'.tr(),
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showSearch ? Icons.search_off : Icons.search,
              color: _showSearch ? Colors.blue : null,
            ),
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _clearSearch();
                }
              });
            },
            tooltip: _showSearch ? 'hide_search'.tr() : 'search_products'.tr(),
          ),
          IconButton(
            icon: Icon(
              isAlphabetical ? Icons.sort_by_alpha : Icons.category,
              color: isAlphabetical ? Colors.green : null,
            ),
            onPressed: _toggleSortOrder,
            tooltip: isAlphabetical
                ? 'sort_by_category'.tr()
                : 'sort_alphabetically'.tr(),
          ),
          IconButton(
            icon: Icon(_showGrouped ? Icons.list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _showGrouped = !_showGrouped;
              });
            },
            tooltip: _showGrouped ? 'list_view'.tr() : 'group_view'.tr(),
          ),
          if (widget.presenter.purchasedItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.cleaning_services),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('clear_purchased'.tr()),
                    content: Text('clear_purchased_confirm'.tr()),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text('cancel'.tr()),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text('remove'.tr()),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await widget.presenter.clearPurchased();
                  widget.onUpdate();
                }
              },
              tooltip: 'remove_purchased'.tr(),
            ),
        ],
      ),
      body: Column(
        children: [
          if (_showSearch)
            ShoppingSearchBar(
              initialQuery: widget.presenter.searchQuery,
              onQueryChanged: _onSearchQueryChanged,
              onClear: _clearSearch,
            ),
          Expanded(child: _buildBody()),
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

  Widget _buildBody() {
    if (widget.presenter.filteredItems.isEmpty) {
      if (widget.presenter.searchQuery.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 64,
                color: Theme.of(context).disabledColor,
              ),
              const SizedBox(height: 16),
              Text(
                'no_results'.tr(),
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'try_another_search'.tr(),
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        );
      }

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
            Text(
              'empty_list'.tr(),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'add_your_products'.tr(),
              style: const TextStyle(fontSize: 14, color: Colors.grey),
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
    final items = widget.presenter.filteredItems;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
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
    final allItems = widget.presenter.filteredItems;
    final Map<String, List<ShoppingItemModel>> grouped = {};

    for (var item in allItems) {
      grouped[item.category] = grouped[item.category] ?? [];
      grouped[item.category]!.add(item);
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
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