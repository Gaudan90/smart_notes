import 'package:flutter/material.dart';
import '../../controllers/supermarket_tracker_presenter.dart';
import '../../states/custom_supermarket_model.dart';

class DeleteCustomSupermarketsDialog extends StatefulWidget {
  final SupermarketTrackerPresenter presenter;
  final VoidCallback onDeleted;

  const DeleteCustomSupermarketsDialog({
    super.key,
    required this.presenter,
    required this.onDeleted,
  });

  @override
  State<DeleteCustomSupermarketsDialog> createState() =>
      _DeleteCustomSupermarketsDialogState();
}

class _DeleteCustomSupermarketsDialogState
    extends State<DeleteCustomSupermarketsDialog> {
  final Set<String> _selectedIds = {};
  bool _selectAll = false;

  List<CustomSupermarketModel> get _availableSupermarkets {
    final markets = widget.presenter.customSupermarkets.toList();
    // Ordinamento alfabetico
    markets.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return markets;
  }

  void _toggleSelectAll() {
    setState(() {
      _selectAll = !_selectAll;
      if (_selectAll) {
        _selectedIds.addAll(_availableSupermarkets.map((s) => s.id));
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
        if (_selectedIds.length == _availableSupermarkets.length) {
          _selectAll = true;
        }
      }
    });
  }

  Future<void> _deleteSelected() async {
    if (_selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleziona almeno un supermercato'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conferma eliminazione'),
        content: Text(
          'Eliminare ${_selectedIds.length} supermercati?\n\n'
              'ATTENZIONE: Gli acquisti associati a questi supermercati '
              'verranno spostati in "Non Assegnato".',
        ),
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
      int deleted = 0;
      for (final id in _selectedIds) {
        await widget.presenter.deleteCustomSupermarket(id);
        deleted++;
      }

      widget.onDeleted();

      if (mounted) {
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ $deleted supermercati eliminati'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final availableSupermarkets = _availableSupermarkets;

    return AlertDialog(
      title: const Text('Elimina Supermercati'),
      content: SizedBox(
        width: double.maxFinite,
        height: 500,
        child: availableSupermarkets.isEmpty
            ? const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.store_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Nessun supermercato personalizzato',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'Crea il tuo primo supermercato',
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
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${_selectedIds.length}'
                          '/${availableSupermarkets.length} selezionati',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color:
                        Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _toggleSelectAll,
                    icon: Icon(
                      _selectAll ? Icons.deselect : Icons.select_all,
                      size: 18,
                    ),
                    label: Text(_selectAll
                        ? 'Deseleziona' : 'Seleziona tutti'),
                    style: TextButton.styleFrom(
                      foregroundColor:
                      Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Lista supermercati
            Expanded(
              child: ListView.builder(
                itemCount: availableSupermarkets.length,
                itemBuilder: (context, index) {
                  final supermarket = availableSupermarkets[index];
                  final isSelected = _selectedIds.contains(supermarket.id);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    elevation: isSelected ? 3 : 1,
                    color: isSelected
                        ? Theme.of(context)
                        .colorScheme
                        .errorContainer
                        .withValues(alpha: 0.3)
                        : null,
                    child: CheckboxListTile(
                      value: isSelected,
                      onChanged: (bool? value) {
                        _toggleItem(supermarket.id);
                      },
                      title: Text(
                        supermarket.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      secondary: CircleAvatar(
                        backgroundColor:
                        supermarket.color.withValues(alpha: 0.2),
                        child: Icon(
                          Icons.store,
                          color: supermarket.color,
                          size: 20,
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
        if (availableSupermarkets.isNotEmpty)
          ElevatedButton(
            onPressed: _deleteSelected,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Elimina'),
          ),
      ],
    );
  }
}