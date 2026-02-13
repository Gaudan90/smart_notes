import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
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
  late TextEditingController _categoryController;
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
    _categoryController = TextEditingController(text: widget.item.category);
    _isSoldByWeight = widget.item.isSoldByWeight;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _weightController.dispose();
    _pricePerKgController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usedCategories = widget.presenter.getUsedCategories();

    return AlertDialog(
      title: Text('edit_product'.tr()),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'product_name'.tr(),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.shopping_basket),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),

            SwitchListTile(
              title: Text('sold_by_weight'.tr()),
              subtitle: Text('sold_by_weight_hint'.tr()),
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
                      decoration: InputDecoration(
                        labelText: 'quantity'.tr(),
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.add_circle_outline),
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
                      decoration: InputDecoration(
                        labelText: 'price_euro'.tr(),
                        hintText: 'optional'.tr(),
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.euro),
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
                      decoration: InputDecoration(
                        labelText: 'weight_kg'.tr(),
                        hintText: 'weight_hint'.tr(),
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.scale),
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
                      decoration: InputDecoration(
                        labelText: 'price_per_kg'.tr(),
                        hintText: 'optional'.tr(),
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.euro),
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

            // Campo categoria libero
            TextField(
              controller: _categoryController,
              decoration: InputDecoration(
                labelText: 'category'.tr(),
                hintText: 'category_hint'.tr(),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.category),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),

            // Chip suggerimenti categorie già usate
            if (usedCategories.isNotEmpty) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: usedCategories.map((cat) {
                    return ActionChip(
                      label: Text(cat, style: const TextStyle(fontSize: 12)),
                      visualDensity: VisualDensity.compact,
                      onPressed: () {
                        setState(() {
                          _categoryController.text = cat;
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('cancel'.tr()),
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

              final category = _categoryController.text.trim().isNotEmpty
                  ? _categoryController.text.trim()
                  : 'default_category'.tr();

              await widget.presenter.updateItem(
                id: widget.item.id,
                name: _nameController.text,
                category: category,
                quantity: quantity,
                price: price,
                weightKg: weightKg,
                pricePerKg: pricePerKg,
              );

              widget.onItemUpdated();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('product_updated'.tr()),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            }
          },
          child: Text('save'.tr()),
        ),
      ],
    );
  }
}