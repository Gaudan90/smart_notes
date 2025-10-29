import 'package:flutter/material.dart';
import '../controllers/shopping_list_presenter.dart';
import '../controllers/supermarket_tracker_presenter.dart';
import '../widget/shopping_list/shopping_list_tab.dart';
import '../widget/shopping_list/shopping_stats_tab.dart';
import '../widget/supermarket/shopping_supermarket_tab.dart';

class ShoppingListView extends StatefulWidget {
  const ShoppingListView({super.key});

  @override
  State<ShoppingListView> createState() => _ShoppingListViewState();
}

class _ShoppingListViewState extends State<ShoppingListView>
    with SingleTickerProviderStateMixin {
  final _presenter = ShoppingListPresenter();
  final _supermarketPresenter = SupermarketTrackerPresenter();

  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });

    _loadData();
  }

  Future<void> _loadData() async {
    await _presenter.loadItems();
    await _supermarketPresenter.loadPurchases();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista della Spesa'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Lista', icon: Icon(Icons.shopping_cart)),
            Tab(text: 'Statistiche', icon: Icon(Icons.analytics)),
            Tab(text: 'Supermercati', icon: Icon(Icons.store)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: [
          ShoppingListTab(
            presenter: _presenter,
            onUpdate: () => setState(() {}),
          ),
          ShoppingStatsTab(
            stats: _presenter.calculateStats(),
          ),
          ShoppingSupermarketTab(
            presenter: _supermarketPresenter,
            shoppingPresenter: _presenter,
            availableProducts: _presenter.items
                .map((item) => item.name).toSet().toList(),
            onUpdate: () => setState(() {}),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}