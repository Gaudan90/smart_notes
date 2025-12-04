import 'package:flutter/material.dart';
import '../../controllers/shopping_list_presenter.dart';
import '../../controllers/supermarket_tracker_presenter.dart';
import '../../states/shopping_item_model.dart';

class ImportFromListDialog extends StatefulWidget {
  final ShoppingListPresenter shoppingPresenter;
  final SupermarketTrackerPresenter supermarketPresenter;
  final VoidCallback onImportCompleted;

  const ImportFromListDialog({
    super.key,
    required this.shoppingPresenter,
    required this.supermarketPresenter,
    required this.onImportCompleted,
  });

  @override
  State<ImportFromListDialog> createState() => _ImportFromListDialogState();
}

class _ImportFromListDialogState extends State<ImportFromListDialog> {
  final Set<String> _selectedIds = {};
  bool _selectAll = false;

  List<ShoppingItemModel> get _availableItems {
    final items = widget.shoppingPresenter.items
        .where((item) => !item.isPurchased)
        .toList();

    // Ordinamento alfabetico
    items.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    return items;
  }

  void _toggleSelectAll() {
    setState(() {
      _selectAll = !_selectAll;
      if (_selectAll) {
        _selectedIds.addAll(_availableItems.map((item) => item.id));
      } else {
        _selectedIds.clear();
      }
    });
  }

  void _toggleItem(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
        _selectAll = false;
      } else {
        _selectedIds.add(id);
        if (_selectedIds.length == _availableItems.length) {
          _selectAll = true;
        }
      }
    });
  }

  Future<void> _proceedToConfiguration() async {
    if (_selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleziona almeno un prodotto'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final selectedItems = _availableItems
        .where((item) => _selectedIds.contains(item.id))
        .toList();
    Navigator.pop(context);

    // Apri il dialog di configurazione
    if (mounted) {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => ImportConfigurationDialog(
          items: selectedItems,
          shoppingPresenter: widget.shoppingPresenter,
          supermarketPresenter: widget.supermarketPresenter,
        ),
      );

      if (result == true) {
        widget.onImportCompleted();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final availableItems = _availableItems;

    return AlertDialog(
      title: const Text('Importa dalla Lista'),
      content: SizedBox(
        width: double.maxFinite,
        height: 500,
        child: availableItems.isEmpty
            ? const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Nessun prodotto disponibile',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'Tutti i prodotti sono giÃ  stati comprati',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        )
            : Column(
          children: [
            // Header con contatore e seleziona tutti
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${_selectedIds.length}'
                          '/${availableItems.length} selezionati',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _toggleSelectAll,
                    icon: Icon(
                      _selectAll ? Icons.deselect : Icons.select_all,
                      size: 18,
                    ),
                    label: Text(_selectAll ? 'Deseleziona' : 'Seleziona tutti'),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context)
                          .colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Lista prodotti
            Expanded(
              child: ListView.builder(
                itemCount: availableItems.length,
                itemBuilder: (context, index) {
                  final item = availableItems[index];
                  final isSelected = _selectedIds.contains(item.id);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: CheckboxListTile(
                      value: isSelected,
                      onChanged: (_) => _toggleItem(item.id),
                      title: Text(
                        item.name,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            item.category,
                            style: const TextStyle(fontSize: 12),
                          ),
                          if
                          (item.price != null || item.pricePerKg != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              item.isSoldByWeight
                                  ? '${item.weightKg!.toStringAsFixed(2)} '
                                  'kg x ${item.pricePerKg!
                                  .toStringAsFixed(2)}/kg'
                                  : '${item.quantity}x ${item.totalCost
                                  .toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                              ),
                            ),
                          ],
                        ],
                      ),
                      secondary: CircleAvatar(
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.1),
                        child: Text(
                          item.isSoldByWeight
                              ? item.weightKg!.toStringAsFixed(1)
                              : '${item.quantity}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
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
        if (availableItems.isNotEmpty)
          ElevatedButton(
            onPressed: _proceedToConfiguration,
            child: const Text('Avanti'),
          ),
      ],
    );
  }
}

class ImportConfigurationDialog extends StatefulWidget {
  final List<ShoppingItemModel> items;
  final ShoppingListPresenter shoppingPresenter;
  final SupermarketTrackerPresenter supermarketPresenter;

  const ImportConfigurationDialog({
    super.key,
    required this.items,
    required this.shoppingPresenter,
    required this.supermarketPresenter,
  });

  @override
  State<ImportConfigurationDialog> createState() =>
      _ImportConfigurationDialogState();
}

class _ImportConfigurationDialogState extends State<ImportConfigurationDialog> {
  final Map<String, String> _supermarketChoices = {};
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Inizializza tutti con il primo supermercato
    for (var item in widget.items) {
      _supermarketChoices[item.id] =
          widget.supermarketPresenter.allSupermarkets.firstOrNull
              ?? SupermarketTrackerPresenter.nonAssegnato;
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _confirmImport() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conferma importazione'),
        content: Text(
          'Importare ${widget.items.length} prodotti?\n\n'
              'I prodotti verranno registrati nei rispettivi supermercati '
              'e marcati come "comprati" nella lista.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Conferma'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _performImport();
    }
  }

  Future<void> _performImport() async {
    int imported = 0;

    for (var item in widget.items) {
      final supermarket = _supermarketChoices[item.id]!;


      final double? basePrice = item.isSoldByWeight
          ? item.pricePerKg
          : item.price;

      await widget.supermarketPresenter.addPurchase(
        productName: item.name,
        supermarket: supermarket,
        purchaseDate: _selectedDate,
        price: basePrice,
        quantity: 1,
      );

      // Marca come comprato nella lista
      await widget.shoppingPresenter.togglePurchased(item.id);

      imported++;
    }

    if (mounted) {
      Navigator.pop(context, true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$imported prodotti importati con successo'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Configura importazione'),
      content: SizedBox(
        width: double.maxFinite,
        height: 500,
        child: Column(
          children: [
            // Data acquisto
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Data acquisto'),
                subtitle: Text(_formatDate(_selectedDate)),
                trailing: TextButton(
                  onPressed: _selectDate,
                  child: const Text('Cambia'),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Seleziona il supermercato per ogni prodotto:',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Lista prodotti con dropdown supermercato
            Expanded(
              child: ListView.builder(
                itemCount: widget.items.length,
                itemBuilder: (context, index) {
                  final item = widget.items[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.category,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _supermarketChoices[item.id],
                            decoration: const InputDecoration(
                              labelText: 'Supermercato',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              isDense: true,
                            ),
                            items: widget.supermarketPresenter.allSupermarkets
                                .map((market) {
                              return DropdownMenuItem(
                                value: market,
                                child: Text(market),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _supermarketChoices[item.id] = value!;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Indietro'),
        ),
        ElevatedButton(
          onPressed: _confirmImport,
          child: const Text('Importa'),
        ),
      ],
    );
  }
}