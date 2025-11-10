import 'package:flutter/material.dart';

class SupermarketSearchBar extends StatelessWidget {
  final bool isLandscape;
  final TextEditingController controller;
  final String searchQuery;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final VoidCallback? onExport;
  final VoidCallback? onImportTxt;
  final VoidCallback? onClearAll;
  final int? purchaseCount;
  final bool isAlphabeticalSort;
  final VoidCallback onToggleSort;

  const SupermarketSearchBar({
    super.key,
    required this.isLandscape,
    required this.controller,
    required this.searchQuery,
    required this.onChanged,
    required this.onClear,
    this.onExport,
    this.onImportTxt,
    this.onClearAll,
    this.purchaseCount,
    required this.isAlphabeticalSort,
    required this.onToggleSort,
  });

  @override
  Widget build(BuildContext context) {
    if (isLandscape) {
      return _buildLandscapeSearchBar(context);
    }
    return _buildPortraitSearchBar(context);
  }

  Widget _buildLandscapeSearchBar(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Cerca...',
              hintStyle: const TextStyle(fontSize: 12),
              prefixIcon: const Icon(Icons.search, size: 16),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear, size: 16),
                padding: EdgeInsets.zero,
                onPressed: onClear,
              )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              isDense: true,
            ),
            style: const TextStyle(fontSize: 12),
            onChanged: onChanged,
          ),
        ),
        // Info inline in landscape
        if (purchaseCount != null && purchaseCount! > 0 && searchQuery.isEmpty) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 14,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 4),
                Text(
                  '$purchaseCount',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
        IconButton(
          icon: Icon(
            isAlphabeticalSort ? Icons.sort_by_alpha : Icons.access_time,
            color: isAlphabeticalSort ? Colors.green : null,
            size: 18,
          ),
          padding: const EdgeInsets.all(4),
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          onPressed: onToggleSort,
          tooltip: isAlphabeticalSort ? 'Data' : 'A-Z',
        ),
      ],
    );
  }

  Widget _buildPortraitSearchBar(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Cerca...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: onClear,
              )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: onChanged,
          ),
        ),
        if (onExport != null) ...[
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: onExport,
            tooltip: 'Esporta TXT',
          ),
        ],
        if (onImportTxt != null)
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: onImportTxt,
            tooltip: 'Importa TXT',
          ),
        if (onClearAll != null)
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: onClearAll,
            tooltip: 'Cancella tutto',
          ),
      ],
    );
  }
}