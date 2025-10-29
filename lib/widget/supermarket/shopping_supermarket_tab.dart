import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../controllers/shopping_list_presenter.dart';
import '../../controllers/supermarket_tracker_presenter.dart';
import '../../states/supermarket_purchase_model.dart';
import 'supermarket_add_dialog.dart';
import 'supermarket_edit_dialog.dart';
import 'supermarket_purchase_card.dart';
import 'import_from_list_dialog.dart';

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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Dati condivisi con successo'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore durante l\'export: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(importResult.message),
            backgroundColor: importResult.imported > 0 ? Colors.green : Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Acquisto eliminato'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredPurchases = _searchQuery.isEmpty
        ? widget.presenter.purchases
        : widget.presenter.searchPurchases(_searchQuery);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _showImportFromList,
                      icon: const Icon(Icons.file_download, size: 18),
                      label: const Text('Importa'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Bottone aggiungi (esistente, ora più stretto)
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _showAddPurchase,
                      icon: const Icon(Icons.add_shopping_cart),
                      label: const Text('Registra Acquisto'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Cerca...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.upload_file),
                    onPressed: _exportData,
                    tooltip: 'Esporta TXT',
                  ),
                  IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: _importData,
                    tooltip: 'Importa TXT',
                  ),
                  if (widget.presenter.purchases.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.delete_sweep),
                      onPressed: _clearAll,
                      tooltip: 'Cancella tutto',
                    ),
                ],
              ),

              if (widget.presenter.purchases.isNotEmpty && _searchQuery.isEmpty) ...[
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

        Expanded(
          child: filteredPurchases.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filteredPurchases.length,
            itemBuilder: (context, index) {
              final purchase = filteredPurchases[index];
              return SupermarketPurchaseCard(
                purchase: purchase,
                onDelete: () => _deletePurchase(purchase),
                onEdit: () => _showEditPurchase(purchase),
              );
            },
          ),
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
            _searchQuery.isEmpty ? Icons.store_outlined : Icons.search_off,
            size: 64,
            color: Theme.of(context).disabledColor,
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty
                ? 'Nessun acquisto registrato'
                : 'Nessun risultato',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
                ? 'Registra i tuoi acquisti per supermercato'
                : 'Prova con un altro termine',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          if (_searchQuery.isEmpty) ...[
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _showAddPurchase,
              icon: const Icon(Icons.add),
              label: const Text('Aggiungi primo acquisto'),
            ),
          ],
        ],
      ),
    );
  }
}