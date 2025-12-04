import 'package:flutter/material.dart';
import '../../states/supermarket_purchase_model.dart';
import '../../controllers/supermarket_tracker_presenter.dart';

class SupermarketPurchaseCard extends StatelessWidget {
  final SupermarketPurchaseModel purchase;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final SupermarketTrackerPresenter? presenter;

  // Selezione multipla
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback? onLongPress;
  final VoidCallback? onTap;

  const SupermarketPurchaseCard({
    super.key,
    required this.purchase,
    required this.onDelete,
    required this.onEdit,
    this.presenter,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onLongPress,
    this.onTap,
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
      elevation: isSelected ? 4 : 1,
      color: isSelected
          ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3)
          : null,
      child: InkWell(
        onTap: isSelectionMode && onTap != null ? onTap : onEdit,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              // Checkbox in modalità selezione
              if (isSelectionMode) ...[
                Checkbox(
                  value: isSelected,
                  onChanged: onTap != null ? (_) => onTap!() : null,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const SizedBox(width: 8),
              ],

              // Icona supermercato con colore custom se disponibile
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
                    Text(
                      purchase.productName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // ✅ RIGA UNIFICATA: Data + Prezzo + Quantità
                    Row(
                      children: [
                        // Data
                        Icon(Icons.calendar_today, size: 12,
                            color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(purchase.purchaseDate),
                          style: TextStyle(fontSize: 12,
                              color: Colors.grey[600]),
                        ),

                        // Prezzo (sulla stessa riga!)
                        if (purchase.price != null) ...[
                          const SizedBox(width: 12),
                          Icon(Icons.euro, size: 12, color: Colors.green[700]),
                          const SizedBox(width: 2),
                          Text(
                            purchase.price!.toStringAsFixed(2),
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700]),
                          ),
                        ],

                        // Quantità
                        if (purchase.quantity > 1) ...[
                          const SizedBox(width: 12),
                          Icon(Icons.shopping_cart, size: 12,
                              color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            'x${purchase.quantity}',
                            style: TextStyle(fontSize: 12,
                                color: Colors.grey[600]),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Pulsante cancella (nascosto in modalità selezione)
              if (!isSelectionMode)
                IconButton(
                  icon: const Icon(Icons.delete,
                      color: Colors.red, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  onPressed: onDelete,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getSupermarketColor(String supermarket) {
    // Prima controlla se è un supermercato custom
    if (presenter != null) {
      final customSupermarket = presenter!.getCustomSupermarket(supermarket);
      if (customSupermarket != null) {
        return customSupermarket.color;
      }
    }

    // Altrimenti usa i colori di default
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