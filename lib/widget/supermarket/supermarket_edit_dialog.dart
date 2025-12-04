import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../controllers/supermarket_tracker_presenter.dart';
import '../../states/supermarket_purchase_model.dart';

class SupermarketEditDialog extends StatefulWidget {
  final SupermarketTrackerPresenter presenter;
  final SupermarketPurchaseModel purchase;
  final VoidCallback onPurchaseUpdated;
  final List<String> availableProducts;

  const SupermarketEditDialog({
    super.key,
    required this.presenter,
    required this.purchase,
    required this.onPurchaseUpdated,
    required this.availableProducts,
  });

  @override
  State<SupermarketEditDialog> createState() => _SupermarketEditDialogState();
}

class _SupermarketEditDialogState extends State<SupermarketEditDialog> {
  late TextEditingController _productController;
  late TextEditingController _quantityController;
  late TextEditingController _priceController;

  late String _selectedSupermarket;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _productController = TextEditingController
      (text: widget.purchase.productName);
    _quantityController = TextEditingController
      (text: '${widget.purchase.quantity}');
    _priceController = TextEditingController(
      text: widget.purchase.price != null
          ? widget.purchase.price!.toStringAsFixed(2)
          : '',
    );
    _selectedSupermarket = widget.purchase.supermarket;
    _selectedDate = widget.purchase.purchaseDate;
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
      title: const Text('Modifica Acquisto'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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

            Autocomplete<String>(
              initialValue: TextEditingValue(text: widget.purchase.productName),
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
                // Sincronizza il controller interno
                controller.text = _productController.text;
                controller.selection = TextSelection.fromPosition(
                  TextPosition(offset: controller.text.length),
                );

                // Listener per aggiornare quando l'utente digita
                controller.addListener(() {
                  _productController.text = controller.text;
                });

                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: const InputDecoration(
                    labelText: 'Prodotto',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.shopping_basket),
                  ),
                  textCapitalization: TextCapitalization.words,
                );
              },
            ),

            const SizedBox(height: 16),

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
              final price = _priceController.text.isNotEmpty
                  ? double.tryParse(_priceController.text)
                  : null;

              await widget.presenter.updatePurchase(
                id: widget.purchase.id,
                productName: _productController.text,
                supermarket: _selectedSupermarket,
                purchaseDate: _selectedDate,
                price: price,
                quantity: quantity,
              );

              widget.onPurchaseUpdated();

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✓ Acquisto aggiornato'),
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