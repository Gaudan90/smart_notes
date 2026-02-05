import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../controllers/supermarket_tracker_presenter.dart';

mixin SupermarketTabSelectionMixin<T extends StatefulWidget> on State<T> {
  bool get isSelectionMode;
  Set<String> get selectedIds;

  void setSelectionState(bool selectionMode);
  void updateSelectedIds(Set<String> ids);
  void showSnackBarMessage(String message, Color? backgroundColor);

  SupermarketTrackerPresenter get presenter;
  Future<void> Function() get onUpdate;

  void toggleSelectionMode(String? purchaseId) {
    if (!isSelectionMode) {
      setSelectionState(true);
      if (purchaseId != null) {
        final newIds = Set<String>.from(selectedIds);
        newIds.add(purchaseId);
        updateSelectedIds(newIds);
      }
    } else {
      setSelectionState(false);
      updateSelectedIds(<String>{});
    }
  }

  void toggleSelection(String purchaseId) {
    final newIds = Set<String>.from(selectedIds);

    if (newIds.contains(purchaseId)) {
      newIds.remove(purchaseId);
      if (newIds.isEmpty) {
        setSelectionState(false);
      }
    } else {
      newIds.add(purchaseId);
    }

    updateSelectedIds(newIds);
  }

  Future<void> deleteSelected(BuildContext context) async {
    if (selectedIds.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('confirm_deletion'.tr()),
        content: Text('delete_selected_confirm'.tr(namedArgs: {
          'count': '${selectedIds.length}'
        })),
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
      final count = selectedIds.length;

      for (final id in selectedIds) {
        await presenter.deletePurchase(id);
      }

      await onUpdate();

      setSelectionState(false);
      updateSelectedIds(<String>{});

      if (context.mounted) {
        showSnackBarMessage(
          'purchases_deleted'.tr(namedArgs: {'count': '$count'}),
          Colors.green,
        );
      }
    }
  }
}