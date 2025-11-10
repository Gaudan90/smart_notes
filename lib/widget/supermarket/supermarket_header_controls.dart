import 'package:flutter/material.dart';

class SupermarketHeaderControls extends StatelessWidget {
  final bool isLandscape;
  final bool isAlphabeticalSort;
  final VoidCallback onToggleSort;
  final VoidCallback onImport;
  final VoidCallback onAddPurchase;
  final VoidCallback onExport;
  final VoidCallback onImportTxt;
  final VoidCallback? onClearAll;
  final bool hasPurchases;

  const SupermarketHeaderControls({
    super.key,
    required this.isLandscape,
    required this.isAlphabeticalSort,
    required this.onToggleSort,
    required this.onImport,
    required this.onAddPurchase,
    required this.onExport,
    required this.onImportTxt,
    this.onClearAll,
    required this.hasPurchases,
  });

  @override
  Widget build(BuildContext context) {
    if (isLandscape) {
      return _buildLandscapeControls(context);
    }
    return _buildPortraitControls(context);
  }

  Widget _buildLandscapeControls(BuildContext context) {
    return Row(
      children: [
        // Ordinamento compatto
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(6),
          ),
          child: InkWell(
            onTap: onToggleSort,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isAlphabeticalSort ? Icons.sort_by_alpha : Icons.access_time,
                  size: 16,
                  color: isAlphabeticalSort ? Colors.green : null,
                ),
                const SizedBox(width: 4),
                Text(
                  isAlphabeticalSort ? 'A-Z' : 'Data',
                  style: const TextStyle(fontSize: 11),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 6),

        // Bottone Importa compatto
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onImport,
            icon: const Icon(Icons.file_download, size: 14),
            label: const Text('Imp.', style: TextStyle(fontSize: 11)),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              minimumSize: const Size(0, 32),
            ),
          ),
        ),
        const SizedBox(width: 6),

        // Bottone Aggiungi compatto
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: onAddPurchase,
            icon: const Icon(Icons.add_shopping_cart, size: 14),
            label: const Text('Aggiungi', style: TextStyle(fontSize: 11)),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              minimumSize: const Size(0, 32),
            ),
          ),
        ),
        const SizedBox(width: 6),

        // Icone azioni
        IconButton(
          icon: const Icon(Icons.upload_file, size: 18),
          padding: const EdgeInsets.all(4),
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          onPressed: onExport,
          tooltip: 'Esporta',
        ),
        IconButton(
          icon: const Icon(Icons.download, size: 18),
          padding: const EdgeInsets.all(4),
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          onPressed: onImportTxt,
          tooltip: 'Importa',
        ),
        if (hasPurchases && onClearAll != null)
          IconButton(
            icon: const Icon(Icons.delete_sweep, size: 18),
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            onPressed: onClearAll,
            tooltip: 'Cancella',
          ),
      ],
    );
  }

  Widget _buildPortraitControls(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onImport,
            icon: const Icon(Icons.file_download, size: 18),
            label: const Text('Importa'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: onAddPurchase,
            icon: const Icon(Icons.add_shopping_cart),
            label: const Text('Registro Acquisto Manuale'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}