import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../controllers/shopping_list_presenter.dart';

class ShoppingQuickAddSheet extends StatelessWidget {
  final ShoppingListPresenter presenter;
  final VoidCallback onItemAdded;

  const ShoppingQuickAddSheet({
    super.key,
    required this.presenter,
    required this.onItemAdded,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'frequent_products'.tr(),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: presenter.getFrequentProducts().map((product) {
              return ActionChip(
                label: Text(product),
                avatar: const Icon(Icons.add, size: 18),
                onPressed: () async {
                  final message = await presenter.addItem(
                    name: product,
                    category: 'default_category'.tr(),
                  );
                  onItemAdded();

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
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}