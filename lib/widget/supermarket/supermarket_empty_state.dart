import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class SupermarketEmptyState extends StatelessWidget {
  final bool isLandscape;
  final bool isSearching;
  final VoidCallback? onAddFirst;

  const SupermarketEmptyState({
    super.key,
    required this.isLandscape,
    required this.isSearching,
    this.onAddFirst,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearching ? Icons.search_off : Icons.store_outlined,
            size: isLandscape ? 48 : 64,
            color: Theme.of(context).disabledColor,
          ),
          SizedBox(height: isLandscape ? 12 : 16),
          Text(
            isSearching ? 'no_results'.tr() : 'no_purchases'.tr(),
            style: TextStyle(fontSize: isLandscape ? 14 : 16),
          ),
          const SizedBox(height: 8),
          Text(
            isSearching
                ? 'try_another_search'.tr()
                : 'add_first_purchase'.tr(),
            style: TextStyle(
              fontSize: isLandscape ? 12 : 14,
              color: Colors.grey,
            ),
          ),
          if (!isSearching && onAddFirst != null) ...[
            SizedBox(height: isLandscape ? 16 : 24),
            OutlinedButton.icon(
              onPressed: onAddFirst,
              icon: Icon(Icons.add, size: isLandscape ? 18 : 20),
              label: Text(
                'add_purchase'.tr(),
                style: TextStyle(fontSize: isLandscape ? 13 : 14),
              ),
            ),
          ],
        ],
      ),
    );
  }
}