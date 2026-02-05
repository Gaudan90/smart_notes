import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
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
    await _supermarketPresenter.loadCustomSupermarkets();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context)
        .orientation == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(
        title: Text('shopping_list'.tr()),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(isLandscape ? 60 : 76),
          child: TabBar(
            controller: _tabController,
            labelPadding: EdgeInsets.symmetric(
              horizontal: isLandscape ? 10 : 18,
              vertical: isLandscape ? 6 : 12,
            ),
            indicatorSize: TabBarIndicatorSize.label,
            tabs: isLandscape
                ? [
              Tab(text: 'tab_list'.tr()),
              Tab(text: 'tab_statistics'.tr()),
              Tab(text: 'tab_supermarkets'.tr()),
            ]
                : [
              Tab(text: 'tab_list'.tr(), icon: const Icon(Icons.shopping_cart, size: 20)),
              Tab(text: 'tab_statistics'.tr(), icon: const Icon(Icons.analytics, size: 20)),
              Tab(text: 'tab_supermarkets'.tr(), icon: const Icon(Icons.store, size: 20)),
            ],
          ),
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
            onUpdate: () async {
              await _supermarketPresenter.loadCustomSupermarkets();
              setState(() {});
            },
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