import 'package:flutter/material.dart';

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
            isSearching ? 'Nessun risultato' : 'Nessun acquisto registrato',
            style: TextStyle(fontSize: isLandscape ? 14 : 16),
          ),
          const SizedBox(height: 8),
          Text(
            isSearching
                ? 'Prova con un altro termine'
                : 'Registra i tuoi acquisti per supermercato',
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
                'Aggiungi primo acquisto',
                style: TextStyle(fontSize: isLandscape ? 13 : 14),
              ),
            ),
          ],
        ],
      ),
    );
  }
}