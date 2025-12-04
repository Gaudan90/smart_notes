import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../controllers/supermarket_tracker_presenter.dart';

class SupermarketAddDialog extends StatefulWidget {
  final SupermarketTrackerPresenter presenter;
  final VoidCallback onPurchaseAdded;
  final List<String> availableProducts;

  const SupermarketAddDialog({
    super.key,
    required this.presenter,
    required this.onPurchaseAdded,
    required this.availableProducts,
  });

  @override
  State<SupermarketAddDialog> createState() => _SupermarketAddDialogState();
}

class _SupermarketAddDialogState extends State<SupermarketAddDialog> {
  final _productController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _priceController = TextEditingController();

  late String _selectedSupermarket;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    final allSupermarkets = widget.presenter.allSupermarkets;
    _selectedSupermarket = allSupermarkets.isNotEmpty
        ? allSupermarkets.first
        : SupermarketTrackerPresenter.nonAssegnato;
  }

  @override
  void dispose() {
    _productController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
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

  Widget _buildSupermarketDropdownItem(String market) {
    return Text(market);
  }

  @override
  Widget build(BuildContext context) {
    final allSupermarkets = widget.presenter.allSupermarkets;

    return AlertDialog(
      title: const Text('Aggiungi Acquisto'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Supermercato
            DropdownButtonFormField<String>(
              value: _selectedSupermarket,
              decoration: const InputDecoration(
                labelText: 'Supermercato',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.store),
              ),
              items: allSupermarkets.map((market) {
                return DropdownMenuItem(
                  value: market,
                  child: _buildSupermarketDropdownItem(market),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSupermarket = value!;
                });
              },
            ),

            const SizedBox(height: 16),

            // Prodotto (con autocomplete)
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<String>.empty();
                }
                return widget.availableProducts.where((product) {
                  return product.toLowerCase().contains(
                    textEditingValue.text.toLowerCase(),
                  );
                });
              },
              onSelected: (String selection) {
                _productController.text = selection;
              },
              fieldViewBuilder:
                  (context, controller, focusNode, onFieldSubmitted) {
                _productController.text = controller.text;
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: const InputDecoration(
                    labelText: 'Prodotto',
                    hintText: 'Es: Latte',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.shopping_basket),
                  ),
                  textCapitalization: TextCapitalization.words,
                );
              },
            ),

            const SizedBox(height: 16),

            // Data
            ListTile(
              title: const Text('Data acquisto'),
              subtitle: Text(
                '${_selectedDate.day}'
                    '/${_selectedDate.month}/${_selectedDate.year}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: _selectDate,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey.shade300),
              ),
            ),

            const SizedBox(height: 16),

            // Quantità e Prezzo
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
            if (_productController.text.isNotEmpty) {
              final quantity = int.tryParse(_quantityController.text) ?? 1;
              final price = double.tryParse(_priceController.text);

              await widget.presenter.addPurchase(
                productName: _productController.text,
                supermarket: _selectedSupermarket,
                purchaseDate: _selectedDate,
                price: price,
                quantity: quantity,
              );

              widget.onPurchaseAdded();

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✓ Acquisto registrato'),
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