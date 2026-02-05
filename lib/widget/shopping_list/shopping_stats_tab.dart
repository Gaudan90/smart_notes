import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:smart_notes/widget/shopping_list/shopping_stat_card.dart';
import '../../states/shopping_list_stats_model.dart';

class ShoppingStatsTab extends StatelessWidget {
  final ShoppingListStats stats;

  const ShoppingStatsTab({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: 100,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'shopping_progress'.tr(),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: stats.completionPercentage / 100,
                    minHeight: 10,
                    backgroundColor: Colors.grey.shade200,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'completed_percent'.tr(namedArgs: {
                      'percent': stats.completionPercentage.toStringAsFixed(0)
                    }),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(stats.completionText),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: ShoppingStatCard(
                  label: 'total_products'.tr(),
                  value: '${stats.totalItems}',
                  icon: Icons.shopping_basket,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ShoppingStatCard(
                  label: 'to_buy'.tr(),
                  value: '${stats.remainingItems}',
                  icon: Icons.pending_actions,
                  color: Colors.orange,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: ShoppingStatCard(
                  label: 'total_cost'.tr(),
                  value: stats.totalCostText,
                  icon: Icons.euro,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ShoppingStatCard(
                  label: 'already_spent'.tr(),
                  value: '€${stats.purchasedCost.toStringAsFixed(2)}',
                  icon: Icons.shopping_cart_checkout,
                  color: Colors.purple,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          if (stats.itemsByCategory.isNotEmpty) ...[
            Text(
              'by_category'.tr(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...stats.itemsByCategory.entries.map((entry) {
              final cost = stats.costByCategory[entry.key] ?? 0.0;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.category),
                  title: Text(entry.key),
                  subtitle: cost > 0 ? Text('€${cost.toStringAsFixed(2)}') : null,
                  trailing: Chip(
                    label: Text('${entry.value}'),
                    backgroundColor: Theme.of(context).colorScheme.primary
                        .withValues(alpha: 0.1),
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}