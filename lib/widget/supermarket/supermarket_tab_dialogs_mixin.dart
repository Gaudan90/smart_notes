import 'package:flutter/material.dart';
import '../../controllers/shopping_list_presenter.dart';
import '../../controllers/supermarket_tracker_presenter.dart';
import '../../states/supermarket_purchase_model.dart';
import 'supermarket_add_dialog.dart';
import 'supermarket_edit_dialog.dart';
import 'custom_supermarket_dialog.dart';
import 'import_from_list_dialog.dart';

mixin SupermarketTabDialogsMixin<T extends StatefulWidget> on State<T> {
  SupermarketTrackerPresenter get presenter;
  ShoppingListPresenter get shoppingPresenter;
  List<String> get availableProducts;
  Future<void> Function() get onUpdate;

  void showAddPurchase() {
    showDialog(
      context: context,
      builder: (context) => SupermarketAddDialog(
        key: UniqueKey(),
        presenter: presenter,
        onPurchaseAdded: onUpdate,
        availableProducts: availableProducts,
      ),
    );
  }

  void showEditPurchase(SupermarketPurchaseModel purchase) {
    showDialog(
      context: context,
      builder: (context) => SupermarketEditDialog(
        presenter: presenter,
        purchase: purchase,
        onPurchaseUpdated: onUpdate,
        availableProducts: availableProducts,
      ),
    );
  }

  void showAddCustomSupermarket() {
    showDialog(
      context: context,
      builder: (context) => CustomSupermarketDialog(
        presenter: presenter,
        onSaved: onUpdate,
      ),
    );
  }

  void showImportFromList() {
    showDialog(
      context: context,
      builder: (context) => ImportFromListDialog(
        shoppingPresenter: shoppingPresenter,
        supermarketPresenter: presenter,
        onImportCompleted: onUpdate,
      ),
    );
  }
}