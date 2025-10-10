import 'package:flutter/material.dart';
import '../../states/shopping_item_model.dart';

class ShoppingItemCard extends StatelessWidget {
  final ShoppingItemModel item;
  final VoidCallback onTogglePurchased;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onDelete;

  const ShoppingItemCard({
    super.key,
    required this.item,
    required this.onTogglePurchased,
    required this.onIncrement,
    required this.onDecrement,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            // Checkbox
            Checkbox(
              value: item.isPurchased,
              onChanged: (_) => onTogglePurchased(),
            ),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      decoration: item.isPurchased
                          ? TextDecoration.lineThrough : null,
                      color: item.isPurchased ? Colors.grey : null,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          item.category,
                          style: const TextStyle(fontSize: 12,
                              color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (item.price != null) ...[
                        const Text(' • ', style: TextStyle(fontSize: 12,
                            color: Colors.grey)),
                        Flexible(
                          child: Text(
                            '€${item.totalCost.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 12,
                                color: Colors.grey),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 4),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32),
                  onPressed: onDecrement,
                ),
                Container(
                  constraints: const BoxConstraints(minWidth: 28),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme
                        .primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      '${item.quantity}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32),
                  onPressed: onIncrement,
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32),
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}