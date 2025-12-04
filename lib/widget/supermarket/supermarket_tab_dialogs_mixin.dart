import 'package:flutter/material.dart';
import '../../controllers/shopping_list_presenter.dart';
import '../../controllers/supermarket_tracker_presenter.dart';
import '../../states/supermarket_purchase_model.dart';
import 'supermarket_add_dialog.dart';
import 'supermarket_edit_dialog.dart';
import 'custom_supermarket_dialog.dart';
import 'import_from_list_dialog.dart';

mixin SupermarketTabDialogsMixin<T extends StatefulWidget> on State<T> {
  // Getter per accesso ai presenter
  SupermarketTrackerPresenter get presenter;
  ShoppingListPresenter get shoppingPresenter;
  List<String> get availableProducts;
  Future<void> Function() get onUpdate;

  // Apre il dialog per aggiungere un nuovo acquisto
  void showAddPurchase() {
    showDialog(
      context: context,
      builder: (context) => SupermarketAddDialog(
        presenter: presenter,
        onPurchaseAdded: onUpdate,
        availableProducts: availableProducts,
      ),
    );
  }

  // Apre il dialog per modificare un acquisto esistente
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

  // Apre il dialog per aggiungere un supermercato personalizzato
  void showAddCustomSupermarket() {
    showDialog(
      context: context,
      builder: (context) => CustomSupermarketDialog(
        presenter: presenter,
        onSaved: onUpdate,
      ),
    );
  }

  // Apre il dialog per importare prodotti dalla shopping list
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