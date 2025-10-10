import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../controllers/shopping_list_presenter.dart';

class ShoppingAddDialog extends StatefulWidget {
  final ShoppingListPresenter presenter;
  final VoidCallback onItemAdded;

  const ShoppingAddDialog({
    super.key,
    required this.presenter,
    required this.onItemAdded,
  });

  @override
  State<ShoppingAddDialog> createState() => _ShoppingAddDialogState();
}

class _ShoppingAddDialogState extends State<ShoppingAddDialog> {
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _priceController = TextEditingController();
  String _selectedCategory = ShoppingListPresenter.categories.first;

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Aggiungi Prodotto'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome prodotto',
                hintText: 'Es: Latte',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.shopping_basket),
              ),
              textCapitalization: TextCapitalization.words,
              onChanged: (value) {
                // Mostra se il prodotto esiste già
                setState(() {});
              },
            ),

            if (_nameController.text.isNotEmpty &&
                widget.presenter.itemExists(_nameController.text))
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Già in lista (${widget.presenter
                            .getItemQuantity(_nameController.text)}x)\n'
                            'La quantità verrà aggiornata',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Quantità',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.add_circle_outline),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: 'Prezzo €',
                      hintText: 'Opzionale',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.euro),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Categoria',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: ShoppingListPresenter.categories.map((cat) {
                return DropdownMenuItem(
                  value: cat,
                  child: Text(cat),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
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
          onPressed: () async {
            if (_nameController.text.isNotEmpty) {
              final quantity = int.tryParse(_quantityController.text) ?? 1;
              final price = double.tryParse(_priceController.text);

              final message = await widget.presenter.addItem(
                name: _nameController.text,
                category: _selectedCategory,
                quantity: quantity,
                price: price,
              );

              widget.onItemAdded();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(message),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            }
          },
          child: const Text('Aggiungi'),
        ),
      ],
    );
  }
}