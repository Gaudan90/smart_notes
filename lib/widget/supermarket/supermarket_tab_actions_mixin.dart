import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../controllers/supermarket_tracker_presenter.dart';
import '../../states/supermarket_purchase_model.dart';

mixin SupermarketTabActionsMixin<T extends StatefulWidget> on State<T> {
  // Callback per UI updates
  void showSnackBarMessage(String message, Color? backgroundColor);

  // Getter per accesso al presenter
  SupermarketTrackerPresenter get presenter;
  Future<void> Function() get onUpdate;

  // Esporta tutti gli acquisti come file di testo condivisibile
  Future<void> exportData() async {
    try {
      final textContent = presenter.exportToText();

      if (mounted) {
        final result = await SharePlus.instance.share(
          ShareParams(
            text: textContent,
            subject: 'Export Supermercati - SmartNotes',
          ),
        );

        if (result.status == ShareResultStatus.success) {
          showSnackBarMessage('✓ Dati condivisi con successo', Colors.green);
        }
      }
    } catch (e) {
      if (mounted) {
        showSnackBarMessage('Errore durante l\'export: $e', Colors.red);
      }
    }
  }

  // Importa acquisti da testo in formato TXT
  Future<void> importData() async {
    final textController = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Importa da TXT'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Incolla il contenuto del file TXT esportato:',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: textController,
                maxLines: 10,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'U2|Latte|01/01/2024|2|€3.50',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, textController.text),
            child: const Text('Importa'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      final importResult = await presenter.importFromText(result);
      await onUpdate();

      if (mounted) {
        showSnackBarMessage(
          importResult.message,
          importResult.imported > 0 ? Colors.green : Colors.orange,
        );
      }
    }
  }

  // Elimina tutti gli acquisti registrati
  Future<void> clearAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conferma'),
        content: const Text('Eliminare tutti gli acquisti registrati?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await presenter.clearAll();
      await onUpdate();
    }
  }

  // Elimina un singolo acquisto
  Future<void> deletePurchase(SupermarketPurchaseModel purchase) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conferma eliminazione'),
        content: Text(
          'Eliminare "${purchase.productName}" da ${purchase.supermarket}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await presenter.deletePurchase(purchase.id);
      await onUpdate();

      if (mounted) {
        showSnackBarMessage('✓ Acquisto eliminato', null);
      }
    }
  }
}