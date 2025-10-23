import 'package:flutter/material.dart';
import '../../states/supermarket_purchase_model.dart';

class SupermarketPurchaseCard extends StatelessWidget {
  final SupermarketPurchaseModel purchase;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const SupermarketPurchaseCard({
    super.key,
    required this.purchase,
    required this.onDelete,
    required this.onEdit,
  });

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              // Icona supermercato
              CircleAvatar(
                backgroundColor: _getSupermarketColor(purchase.supermarket)
                    .withValues(alpha: 0.2),
                child: Icon(
                  Icons.store,
                  color: _getSupermarketColor(purchase.supermarket),
                  size: 20,
                ),
              ),

              const SizedBox(width: 12),

              // Info prodotto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nome prodotto
                    Text(
                      purchase.productName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Supermercato
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getSupermarketColor(purchase.supermarket)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        purchase.supermarket,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: _getSupermarketColor(purchase.supermarket),
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Data e quantità
                    Row(
                      children: [
                        Icon(Icons.calendar_today,
                          size: 12,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(purchase.purchaseDate),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (purchase.quantity > 1) ...[
                          const SizedBox(width: 12),
                          Icon(Icons.shopping_cart,
                            size: 12,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'x${purchase.quantity}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),

                    if (purchase.price != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '€${(purchase.price! * purchase.quantity).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Bottone elimina
              Container(
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 22),
                  onPressed: onDelete,
                  tooltip: 'Elimina',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getSupermarketColor(String supermarket) {
    switch (supermarket) {
      case 'U2':
        return Colors.orange;
      case 'Gigante':
        return Colors.blue;
      case 'Bennet':
        return Colors.green;
      case 'Carrefour':
        return Colors.red;
      case 'Mercato':
        return Colors.purple;
      case 'Ipercoop':
        return Colors.teal;
      case 'Coop':
        return Colors.indigo;
      case 'Lidl':
        return Colors.amber;
      case 'Action':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }
}