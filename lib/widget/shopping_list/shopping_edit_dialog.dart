import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../controllers/shopping_list_presenter.dart';
import '../../states/shopping_item_model.dart';

class ShoppingEditDialog extends StatefulWidget {
  final ShoppingListPresenter presenter;
  final ShoppingItemModel item;
  final VoidCallback onItemUpdated;

  const ShoppingEditDialog({
    super.key,
    required this.presenter,
    required this.item,
    required this.onItemUpdated,
  });

  @override
  State<ShoppingEditDialog> createState() => _ShoppingEditDialogState();
}

class _ShoppingEditDialogState extends State<ShoppingEditDialog> {
  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late TextEditingController _priceController;
  late TextEditingController _weightController;
  late TextEditingController _pricePerKgController;
  late String _selectedCategory;
  late bool _isSoldByWeight;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.name);
    _quantityController = TextEditingController(text: '${widget.item.quantity}');
    _priceController = TextEditingController(
      text: widget.item.price != null
          ? widget.item.price!.toStringAsFixed(2) : '',
    );
    _weightController = TextEditingController(
      text: widget.item.weightKg != null
          ? widget.item.weightKg!.toStringAsFixed(3) : '',
    );
    _pricePerKgController = TextEditingController(
      text: widget.item.pricePerKg != null
          ? widget.item.pricePerKg!.toStringAsFixed(2) : '',
    );
    _selectedCategory = widget.item.category;
    _isSoldByWeight = widget.item.isSoldByWeight;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _weightController.dispose();
    _pricePerKgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Modifica Prodotto'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome prodotto',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.shopping_basket),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),

            SwitchListTile(
              title: const Text('Venduto al peso'),
              subtitle: const Text('Es: frutta, verdura, carne'),
              value: _isSoldByWeight,
              onChanged: (value) {
                setState(() {
                  _isSoldByWeight = value;
                  if (value) {
                    _quantityController.text = '1';
                    _priceController.clear();
                  } else {
                    _weightController.clear();
                    _pricePerKgController.clear();
                  }
                });
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey.shade300),
              ),
            ),

            const SizedBox(height: 16),

            if (!_isSoldByWeight) ...[
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
                      keyboardType: const TextInputType
                          .numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter
                            .allow(RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                    ),
                  ),
                ],
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _weightController,
                      decoration: const InputDecoration(
                        labelText: 'Peso (kg)',
                        hintText: 'Es: 0.5',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.scale),
                      ),
                      keyboardType: const TextInputType
                          .numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter
                            .allow(RegExp(r'^\d+\.?\d{0,3}')),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _pricePerKgController,
                      decoration: const InputDecoration(
                        labelText: '€/kg',
                        hintText: 'Opzionale',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.euro),
                      ),
                      keyboardType: const TextInputType
                          .numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter
                            .allow(RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                    ),
                  ),
                ],
              ),
            ],

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
              final priceText = _priceController.text.trim();
              final price = priceText.isNotEmpty ? double
                  .tryParse(priceText) : null;

              final weightText = _weightController.text.trim();
              final weightKg = weightText.isNotEmpty ? double
                  .tryParse(weightText) : null;

              final pricePerKgText = _pricePerKgController.text.trim();
              final pricePerKg = pricePerKgText.isNotEmpty ? double
                  .tryParse(pricePerKgText) : null;

              await widget.presenter.updateItem(
                id: widget.item.id,
                name: _nameController.text,
                category: _selectedCategory,
                quantity: quantity,
                price: price,
                weightKg: weightKg,
                pricePerKg: pricePerKg,
              );

              widget.onItemUpdated();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✓ Prodotto aggiornato'),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            }
          },
          child: const Text('Salva'),
        ),
      ],
    );
  }
}