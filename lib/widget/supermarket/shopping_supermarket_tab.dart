import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../controllers/shopping_list_presenter.dart';
import '../../controllers/supermarket_tracker_presenter.dart';
import '../../states/supermarket_purchase_model.dart';
import 'supermarket_add_dialog.dart';
import 'supermarket_edit_dialog.dart';
import 'supermarket_purchase_card.dart';
import 'import_from_list_dialog.dart';
import 'supermarket_header_controls.dart';
import 'supermarket_search_bar.dart';
import 'supermarket_empty_state.dart';

class ShoppingSupermarketTab extends StatefulWidget {
  final SupermarketTrackerPresenter presenter;
  final ShoppingListPresenter shoppingPresenter;
  final List<String> availableProducts;
  final VoidCallback onUpdate;

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

class _ShoppingSupermarketTabState extends State<ShoppingSupermarketTab> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isAlphabeticalSort = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _isLandscape {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  void _showAddPurchase() {
    showDialog(
      context: context,
      builder: (context) => SupermarketAddDialog(
        presenter: widget.presenter,
        onPurchaseAdded: widget.onUpdate,
        availableProducts: widget.availableProducts,
      ),
    );
  }

  void _showImportFromList() {
    showDialog(
      context: context,
      builder: (context) => ImportFromListDialog(
        shoppingPresenter: widget.shoppingPresenter,
        supermarketPresenter: widget.presenter,
        onImportCompleted: widget.onUpdate,
      ),
    );
  }

  void _showEditPurchase(SupermarketPurchaseModel purchase) {
    showDialog(
      context: context,
      builder: (context) => SupermarketEditDialog(
        presenter: widget.presenter,
        purchase: purchase,
        onPurchaseUpdated: widget.onUpdate,
        availableProducts: widget.availableProducts,
      ),
    );
  }

  void _toggleSortOrder() {
    setState(() {
      _isAlphabeticalSort = !_isAlphabeticalSort;
    });
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

  Future<void> _exportData() async {
    try {
      final textContent = widget.presenter.exportToText();

      if (mounted) {
        final result = await SharePlus.instance.share(
          ShareParams(
            text: textContent,
            subject: 'Export Supermercati - SmartNotes',
          ),
        );

        if (result.status == ShareResultStatus.success) {
          _showSnackBar('✓ Dati condivisi con successo', Colors.green);
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Errore durante l\'export: $e', Colors.red);
      }
    }
  }

  Future<void> _importData() async {
    final textController = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Importa da TXT'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Incolla il contenuto del file TXT esportato:',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: textController,
                maxLines: 10,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'U2|Latte|01/01/2024|2|€3.50',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, textController.text),
            child: const Text('Importa'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      final importResult = await widget.presenter.importFromText(result);
      widget.onUpdate();

      if (mounted) {
        _showSnackBar(
          importResult.message,
          importResult.imported > 0 ? Colors.green : Colors.orange,
        );
      }
    }
  }

  Future<void> _clearAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conferma'),
        content: const Text('Eliminare tutti gli acquisti registrati?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await widget.presenter.clearAll();
      widget.onUpdate();
    }
  }

  Future<void> _deletePurchase(SupermarketPurchaseModel purchase) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conferma eliminazione'),
        content: Text('Eliminare "${purchase.productName}" da ${purchase.supermarket}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await widget.presenter.deletePurchase(purchase.id);
      widget.onUpdate();

      if (mounted) {
        _showSnackBar('✓ Acquisto eliminato', null);
      }
    }
  }

  void _showSnackBar(String message, Color? backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredPurchases = _searchQuery.isEmpty
        ? widget.presenter.purchases
        : widget.presenter.searchPurchases(_searchQuery);

    final sortedPurchases = _getSortedPurchases(filteredPurchases);

    return Scaffold(
      // AppBar solo in portrait
      appBar: _isLandscape
          ? null
          : AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          _isAlphabeticalSort ? 'Ordinamento: A-Z' : 'Ordinamento: Data',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
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
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(_isLandscape ? 6 : 16),
            child: Column(
              children: [
                // Header controls
                SupermarketHeaderControls(
                  isLandscape: _isLandscape,
                  isAlphabeticalSort: _isAlphabeticalSort,
                  onToggleSort: _toggleSortOrder,
                  onImport: _showImportFromList,
                  onAddPurchase: _showAddPurchase,
                  onExport: _exportData,
                  onImportTxt: _importData,
                  onClearAll: widget.presenter.purchases.isNotEmpty
                      ? _clearAll
                      : null,
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
                  onExport: _isLandscape ? null : _exportData,
                  onImportTxt: _isLandscape ? null : _importData,
                  onClearAll: _isLandscape || !widget.presenter.purchases.isNotEmpty
                      ? null
                      : _clearAll,
                  purchaseCount: widget.presenter.purchases.length,
                  isAlphabeticalSort: _isAlphabeticalSort,
                  onToggleSort: _toggleSortOrder,
                ),

                // Info card - SOLO in portrait
                if (!_isLandscape &&
                    widget.presenter.purchases.isNotEmpty &&
                    _searchQuery.isEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
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
                            'Totale: ${widget.presenter.purchases.length} acquisti registrati',
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Lista acquisti
          Expanded(
            child: sortedPurchases.isEmpty
                ? SupermarketEmptyState(
              isLandscape: _isLandscape,
              isSearching: _searchQuery.isNotEmpty,
              onAddFirst: _searchQuery.isEmpty ? _showAddPurchase : null,
            )
                : ListView.builder(
              padding: EdgeInsets.symmetric(
                horizontal: _isLandscape ? 6 : 16,
              ),
              itemCount: sortedPurchases.length,
              itemBuilder: (context, index) {
                final purchase = sortedPurchases[index];
                return SupermarketPurchaseCard(
                  purchase: purchase,
                  onDelete: () => _deletePurchase(purchase),
                  onEdit: () => _showEditPurchase(purchase),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}