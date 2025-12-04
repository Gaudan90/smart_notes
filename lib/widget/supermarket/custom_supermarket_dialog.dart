import 'package:flutter/material.dart';
import '../../controllers/supermarket_tracker_presenter.dart';

class CustomSupermarketDialog extends StatefulWidget {
  final SupermarketTrackerPresenter presenter;
  final VoidCallback onSaved;

  const CustomSupermarketDialog({
    super.key,
    required this.presenter,
    required this.onSaved,
  });

  @override
  State<CustomSupermarketDialog> createState() => _CustomSupermarketDialogState();
}

class _CustomSupermarketDialogState extends State<CustomSupermarketDialog> {
  final _nameController = TextEditingController();
  Color _selectedColor = Colors.blue;

  // Palette colori predefiniti
  static const List<Color> _colorPalette = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      _showError('Inserisci il nome del supermercato');
      return;
    }

    try {
      await widget.presenter.addCustomSupermarket(
        name,
        _selectedColor.value,
      );

      widget.onSaved();

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ "$name" aggiunto'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      _showError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.add_business,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          const Text('Nuovo Supermercato'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nome supermercato
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome Supermercato',
                hintText: 'Es: Esselunga',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.store),
              ),
              textCapitalization: TextCapitalization.words,
              autofocus: true,
            ),

            const SizedBox(height: 24),

            // Label colore
            const Text(
              'Colore Identificativo',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 12),

            // Colore selezionato
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: _selectedColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  _nameController.text.isEmpty
                      ? 'Anteprima'
                      : _nameController.text,
                  style: TextStyle(
                    color: _selectedColor.computeLuminance() > 0.5
                        ? Colors.black
                        : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Palette colori
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _colorPalette.map((color) {
                final isSelected = color == _selectedColor;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = color;
                    });
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.black : Colors.grey.shade300,
                        width: isSelected ? 3 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.5),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ]
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 20,
                    )
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annulla'),
        ),
        ElevatedButton.icon(
          onPressed: _save,
          icon: const Icon(Icons.add),
          label: const Text('Aggiungi'),
        ),
      ],
    );
  }
}