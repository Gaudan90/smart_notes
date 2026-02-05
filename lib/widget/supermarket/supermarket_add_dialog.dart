import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
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
  final _formKey = GlobalKey<FormState>();
  final _productController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _priceController = TextEditingController();

  TextEditingController? _autocompleteController;

  late String _selectedSupermarket;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();

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
      title: Text('add_purchase'.tr()),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedSupermarket,
                decoration: InputDecoration(
                  labelText: 'supermarket'.tr(),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.store),
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
                  _autocompleteController = controller;

                  return TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      labelText: 'product'.tr(),
                      hintText: 'product_name_hint'.tr(),
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.shopping_basket),
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'enter_product_name'.tr();
                      }
                      return null;
                    },
                  );
                },
              ),

              const SizedBox(height: 16),

              ListTile(
                title: Text('purchase_date'.tr()),
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
                    child: TextFormField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'quantity'.tr(),
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.add_circle_outline),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'required'.tr();
                        }
                        final qty = int.tryParse(value);
                        if (qty == null || qty < 1) {
                          return 'min_one'.tr();
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: 'price_euro'.tr(),
                        hintText: 'optional'.tr(),
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.euro),
                      ),
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
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('cancel'.tr()),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              final quantity = int.tryParse(_quantityController.text) ?? 1;
              final price = double.tryParse(_priceController.text);

              final productName = _autocompleteController?.text ?? '';

              await widget.presenter.addPurchase(
                productName: productName,
                supermarket: _selectedSupermarket,
                purchaseDate: _selectedDate,
                price: price,
                quantity: quantity,
              );

              widget.onPurchaseAdded();

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('purchase_registered'.tr()),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            } else {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('fill_required_fields'.tr()),
                    backgroundColor: Colors.orange,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            }
          },
          child: Text('add'.tr()),
        ),
      ],
    );
  }
}