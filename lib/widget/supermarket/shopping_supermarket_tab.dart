import 'package:flutter/material.dart';
import '../../controllers/shopping_list_presenter.dart';
import '../../controllers/supermarket_tracker_presenter.dart';
import '../../states/supermarket_purchase_model.dart';
import 'supermarket_purchase_card.dart';
import 'supermarket_header_controls.dart';
import 'supermarket_search_bar.dart';
import 'supermarket_empty_state.dart';
import 'supermarket_tab_selection_mixin.dart';
import 'supermarket_tab_actions_mixin.dart';
import 'supermarket_tab_dialogs_mixin.dart';
import 'delete_custom_supermarkets_dialog.dart';

class ShoppingSupermarketTab extends StatefulWidget {
  final SupermarketTrackerPresenter presenter;
  final ShoppingListPresenter shoppingPresenter;
  final List<String> availableProducts;
  final Future<void> Function() onUpdate;

  const ShoppingSupermarketTab({
    super.key,
    required this.presenter,
    required this.shoppingPresenter,
    required this.availableProducts,
    required this.onUpdate,
  });

  @override
  State<ShoppingSupermarketTab> createState() => _ShoppingSupermarketTabState();
}

class _ShoppingSupermarketTabState extends State<ShoppingSupermarketTab>
    with
        SupermarketTabSelectionMixin,
        SupermarketTabActionsMixin,
        SupermarketTabDialogsMixin {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isAlphabeticalSort = false;

  bool _isSelectionMode = false;
  final Set<String> _selectedIds = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }


  bool get _isLandscape => MediaQuery.of(context).orientation == Orientation.landscape;

  @override
  bool get isSelectionMode => _isSelectionMode;
  @override
  Set<String> get selectedIds => _selectedIds;
  @override
  SupermarketTrackerPresenter get presenter => widget.presenter;
  @override
  ShoppingListPresenter get shoppingPresenter => widget.shoppingPresenter;
  @override
  List<String> get availableProducts => widget.availableProducts;
  @override
  Future<void> Function() get onUpdate => widget.onUpdate;

  List<SupermarketPurchaseModel> get _filteredAndSortedPurchases {
    final filteredPurchases = _searchQuery.isEmpty
        ? widget.presenter.purchases
        : widget.presenter.searchPurchases(_searchQuery);
    return _getSortedPurchases(filteredPurchases);
  }

  @override
  void setSelectionState(bool selectionMode) {
    setState(() {
      _isSelectionMode = selectionMode;
    });
  }

  @override
  void updateSelectedIds(Set<String> ids) {
    setState(() {
      _selectedIds
        ..clear()
        ..addAll(ids);
    });
  }

  @override
  void showSnackBarMessage(String message, Color? backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _toggleSortOrder() {
    setState(() {
      _isAlphabeticalSort = !_isAlphabeticalSort;
    });
  }

  void _toggleSelectAll() {
    final allPurchases = _filteredAndSortedPurchases;

    if (_selectedIds.length == allPurchases.length) {
      updateSelectedIds(<String>{});
      setSelectionState(false);
    } else {
      final allIds = allPurchases.map((p) => p.id).toSet();
      updateSelectedIds(allIds);
    }
  }

  void _showDeleteCustomSupermarkets() {
    showDialog(
      context: context,
      builder: (context) => DeleteCustomSupermarketsDialog(
        presenter: widget.presenter,
        onDeleted: () async {
          await widget.onUpdate();
          setState(() {});
        },
      ),
    );
  }

  List<SupermarketPurchaseModel> _getSortedPurchases(
      List<SupermarketPurchaseModel> purchases) {
    final sorted = List<SupermarketPurchaseModel>.from(purchases);

    if (_isAlphabeticalSort) {
      sorted.sort((a, b) =>
          a.productName.toLowerCase().compareTo(b.productName.toLowerCase()));
    } else {
      sorted.sort((a, b) => b.purchaseDate.compareTo(a.purchaseDate));
    }

    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final sortedPurchases = _filteredAndSortedPurchases;

    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          if (!_isSelectionMode) _buildHeader(),
          _buildPurchasesList(sortedPurchases),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  PreferredSizeWidget? _buildAppBar() {
    if (_isLandscape && !_isSelectionMode) return null;

    return AppBar(
      automaticallyImplyLeading: false,
      title: _isSelectionMode
          ? Text('${_selectedIds.length} selezionati')
          : Text(
        _isAlphabeticalSort ? 'Ordinamento: A-Z' : 'Ordinamento: Data',
        style: const TextStyle(fontSize: 16),
      ),
      leading: _isSelectionMode
          ? IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => toggleSelectionMode(null),
      )
          : null,
      actions: [
        if (_isSelectionMode) ...[
          IconButton(
            icon: Icon(
              _selectedIds.length == _filteredAndSortedPurchases.length
                  ? Icons.deselect
                  : Icons.select_all,
            ),
            onPressed: _toggleSelectAll,
            tooltip: _selectedIds.length == _filteredAndSortedPurchases.length
                ? 'Deseleziona tutti'
                : 'Seleziona tutti',
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _selectedIds.isNotEmpty
                ? () => deleteSelected(context)
                : null,
            tooltip: 'Elimina selezionati',
          ),
        ] else
          IconButton(
            icon: Icon(
              _isAlphabeticalSort ? Icons.sort_by_alpha : Icons.access_time,
              color: _isAlphabeticalSort ? Colors.green : null,
            ),
            onPressed: _toggleSortOrder,
            tooltip: _isAlphabeticalSort
                ? 'Ordina per data'
                : 'Ordina alfabeticamente',
          ),
      ],
    );
  }

  // Costruisce l'header con controlli e search bar
  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(_isLandscape ? 6 : 16),
      child: Column(
        children: [
          SupermarketHeaderControls(
            isLandscape: _isLandscape,
            isAlphabeticalSort: _isAlphabeticalSort,
            onToggleSort: _toggleSortOrder,
            onImport: showImportFromList,
            onAddPurchase: showAddPurchase,
            onExport: exportData,
            onImportTxt: importData,
            onClearAll:
            widget.presenter.purchases.isNotEmpty ? clearAll : null,
            hasPurchases: widget.presenter.purchases.isNotEmpty,
          ),

          SizedBox(height: _isLandscape ? 6 : 12),

          // Search bar
          SupermarketSearchBar(
            isLandscape: _isLandscape,
            controller: _searchController,
            searchQuery: _searchQuery,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            onClear: () {
              _searchController.clear();
              setState(() {
                _searchQuery = '';
              });
            },
            onExport: _isLandscape ? null : exportData,
            onImportTxt: _isLandscape ? null : importData,
            onClearAll: _isLandscape ||
                !widget.presenter.purchases.isNotEmpty
                ? null
                : clearAll,
            purchaseCount: widget.presenter.purchases.length,
            isAlphabeticalSort: _isAlphabeticalSort,
            onToggleSort: _toggleSortOrder,
          ),

          // Info card - SOLO in portrait
          if (!_isLandscape &&
              widget.presenter.purchases.isNotEmpty &&
              _searchQuery.isEmpty)
            _buildInfoCard(),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              size: 20,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Totale: ${widget.presenter.purchases.length} '
                    'acquisti registrati',
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Costruisce la lista degli acquisti
  Widget _buildPurchasesList(List<SupermarketPurchaseModel> sortedPurchases) {
    return Expanded(
      child: sortedPurchases.isEmpty
          ? SupermarketEmptyState(
        isLandscape: _isLandscape,
        isSearching: _searchQuery.isNotEmpty,
        onAddFirst: _searchQuery.isEmpty ? showAddPurchase : null,
      )
          : ListView.builder(
        padding: EdgeInsets.fromLTRB(
          _isLandscape ? 6 : 16,
          _isSelectionMode ? 16 : 0,
          _isLandscape ? 6 : 16,
          150,
        ),
        itemCount: sortedPurchases.length,
        itemBuilder: (context, index) {
          final purchase = sortedPurchases[index];
          final isSelected = _selectedIds.contains(purchase.id);

          return SupermarketPurchaseCard(
            purchase: purchase,
            onDelete: () => deletePurchase(purchase),
            onEdit: () => showEditPurchase(purchase),
            presenter: widget.presenter,
            isSelectionMode: _isSelectionMode,
            isSelected: isSelected,
            onLongPress: () => toggleSelectionMode(purchase.id),
            onTap: _isSelectionMode
                ? () => toggleSelection(purchase.id)
                : null,
          );
        },
      ),
    );
  }

  // Costruisce il FAB per aggiungere supermercato custom
  Widget? _buildFAB() {
    if (_isSelectionMode) return null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16, right: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Mini FAB per eliminare supermercati
          if (widget.presenter.customSupermarkets.isNotEmpty)
            FloatingActionButton.small(
              onPressed: _showDeleteCustomSupermarkets,
              heroTag: 'delete_supermarkets',
              backgroundColor: Colors.red.shade400,
              tooltip: 'Elimina supermercati',
              child: const Icon(Icons.delete_outline, size: 20),
            ),

          if (widget.presenter.customSupermarkets.isNotEmpty)
            const SizedBox(height: 12),

          // FAB principale per aggiungere
          FloatingActionButton.extended(
            onPressed: showAddCustomSupermarket,
            heroTag: 'add_supermarket',
            icon: const Icon(Icons.add_business),
            label: const Text('Supermercato'),
            tooltip: 'Aggiungi supermercato personalizzato',
          ),
        ],
      ),
    );
  }
}