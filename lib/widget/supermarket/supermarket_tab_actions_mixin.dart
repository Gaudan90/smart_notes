import 'dart:io';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../controllers/supermarket_tracker_presenter.dart';
import '../../states/supermarket_purchase_model.dart';

mixin SupermarketTabActionsMixin<T extends StatefulWidget> on State<T> {
  void showSnackBarMessage(String message, Color? backgroundColor);

  SupermarketTrackerPresenter get presenter;
  Future<void> Function() get onUpdate;

  Future<void> exportData() async {
    try {
      final textContent = presenter.exportToText();

      const textSizeLimit = 5000;

      if (mounted) {
        if (textContent.length < textSizeLimit) {
          final result = await SharePlus.instance.share(
            ShareParams(
              text: textContent,
              subject: 'Export Supermercati - SmartNotes',
            ),
          );

          if (mounted && result.status == ShareResultStatus.success) {
            showSnackBarMessage('data_exported'.tr(), Colors.green);
          }
        } else {
          final directory = await getTemporaryDirectory();
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final fileName = 'supermercati_export_$timestamp.txt';
          final file = File('${directory.path}/$fileName');

          await file.writeAsString(textContent);

          final result = await SharePlus.instance.share(
            ShareParams(
              files: [XFile(file.path)],
              subject: 'Export Supermercati - SmartNotes',
            ),
          );

          if (mounted && result.status == ShareResultStatus.success) {
            showSnackBarMessage(
                'data_imported'.tr(namedArgs: {
                  'count': '${presenter.purchases.length}'
                }),
                Colors.green
            );
          }

          try {
            await file.delete();
          } catch (_) {}
        }
      }
    } catch (e) {
      if (mounted) {
        showSnackBarMessage('Error: $e', Colors.red);
      }
    }
  }

  Future<void> importData() async {
    final textController = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('import_data'.tr()),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Incolla il contenuto del file TXT esportato:',
                style: const TextStyle(fontSize: 14),
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
            child: Text('cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, textController.text),
            child: Text('import'.tr()),
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

  Future<void> clearAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('confirm'.tr()),
        content: Text('clear_all_purchases_confirm'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('delete'.tr()),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await presenter.clearAll();
      await onUpdate();
    }
  }

  Future<void> deletePurchase(SupermarketPurchaseModel purchase) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('confirm_deletion'.tr()),
        content: Text(
          'delete_product_confirm'.tr(namedArgs: {
            'item': '${purchase.productName} (${purchase.supermarket})'
          }),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('delete'.tr()),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await presenter.deletePurchase(purchase.id);
      await onUpdate();

      if (mounted) {
        showSnackBarMessage('purchase_deleted'.tr(), null);
      }
    }
  }
}