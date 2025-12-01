import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../controllers/meal_plan_presenter.dart';
import '../data/meal_data/dish_category.dart';
import '../data/meal_data/meal_plan_config.dart';
import '../states/meal_plan_model.dart';
import '../widget/meal_plan/dish_list_manager.dart';
import '../widget/meal_plan/meal_plan_day_card.dart';

class MealPlanView extends StatefulWidget {
  const MealPlanView({super.key});

  @override
  State<MealPlanView> createState() => _MealPlanViewState();
}

class _MealPlanViewState extends State<MealPlanView>
    with SingleTickerProviderStateMixin {
  final _presenter = MealPlanPresenter();
  late TabController _tabController;
  bool _isLoading = true;
  bool _includeBreakfast = true;
  bool _includeLunch = true;
  bool _includeDinner = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _tabController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });

    _loadData();
  }

  Future<void> _loadData() async {
    await _presenter.loadDishes();
    await _presenter.loadPlan();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddDishDialog() {
    final nameController = TextEditingController();
    DishCategory selectedCategory = DishCategory.first;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Aggiungi Piatto'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome piatto',
                    hintText: 'es. Pasta al pesto',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.restaurant),
                  ),
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<DishCategory>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Categoria',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: DishCategory.values.map((cat) {
                    return DropdownMenuItem(
                      value: cat,
                      child: Row(
                        children: [
                          Text(cat.emoji, style: const TextStyle(fontSize: 20)),
                          const SizedBox(width: 8),
                          Text(cat.label),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() {
                        selectedCategory = value;
                      });
                    }
                  },
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
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  await _presenter.addDish(name, selectedCategory);
                  setState(() {});
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('✓ "$name" aggiunto come ${selectedCategory.label}'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              },
              child: const Text('Aggiungi'),
            ),
          ],
        ),
      ),
    );
  }

  void _showGeneratePlanDialog() {
    if (_presenter.dishes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aggiungi almeno alcuni piatti prima di generare il piano'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Genera Piano Settimanale'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Piatti disponibili: ${_presenter.dishes.length}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              const Text('Seleziona i pasti da includere:'),
              const SizedBox(height: 8),
              CheckboxListTile(
                title: const Text('🌅 Colazione'),
                value: _includeBreakfast,
                onChanged: (value) {
                  setDialogState(() {
                    _includeBreakfast = value ?? true;
                  });
                },
              ),
              CheckboxListTile(
                title: const Text('☀️ Pranzo'),
                value: _includeLunch,
                onChanged: (value) {
                  setDialogState(() {
                    _includeLunch = value ?? true;
                  });
                },
              ),
              CheckboxListTile(
                title: const Text('🌙 Cena'),
                value: _includeDinner,
                onChanged: (value) {
                  setDialogState(() {
                    _includeDinner = value ?? true;
                  });
                },
              ),
              if (!_includeBreakfast && !_includeLunch && !_includeDinner)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'Seleziona almeno un pasto',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annulla'),
            ),
            ElevatedButton(
              onPressed: (_includeBreakfast || _includeLunch || _includeDinner)
                  ? () async {
                try {
                  final config = MealPlanConfig(
                    dishes: _presenter.dishes,
                    includeBreakfast: _includeBreakfast,
                    includeLunch: _includeLunch,
                    includeDinner: _includeDinner,
                  );

                  await _presenter.generateMealPlan(config);
                  setState(() {
                    _tabController.index = 1; // Vai al tab piano
                  });

                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✓ Piano settimanale generato!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Errore: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
                  : null,
              child: const Text('Genera'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Piano pasti settimanale'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Piatti', icon: Icon(Icons.restaurant_menu, size: 20)),
            Tab(text: 'Piano', icon: Icon(Icons.calendar_month, size: 20)),
          ],
        ),
        actions: [
          if (_tabController.index == 1 && _presenter.hasPlan)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _sharePlan,
              tooltip: 'Condividi',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: [
          _buildDishesTab(),
          _buildPlanTab(),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16, right: 8),
        child: _buildFAB(),
      ),
    );
  }

  Widget? _buildFAB() {
    if (_tabController.index == 0) {
      return FloatingActionButton.extended(
        onPressed: _showAddDishDialog,
        icon: const Icon(Icons.add),
        label: const Text('Aggiungi Piatto'),
      );
    } else {
      // Tab Piano
      return FloatingActionButton.extended(
        onPressed: _showGeneratePlanDialog,
        icon: const Icon(Icons.auto_awesome),
        label: Text(_presenter.hasPlan ? 'Rigenera' : 'Genera Piano'),
      );
    }
  }

  Widget _buildDishesTab() {
    return DishListManager(
      dishes: _presenter.dishes,
      onAddDish: (name, category) async {
        await _presenter.addDish(name, category);
        setState(() {});
      },
      onRemoveDish: (dish) async {
        await _presenter.removeDish(dish);
        setState(() {});
      },
      onUpdateDish: (index, newName, newCategory) async {
        await _presenter.updateDish(index, newName, newCategory);
        setState(() {});
      },
      onClearAll: () async {
        await _presenter.clearDishes();
        setState(() {});
      },
    );
  }

  Widget _buildPlanTab() {
    if (!_presenter.hasPlan) {
      return _buildNoPlanState();
    }

    final plan = _presenter.currentPlan!;
    final mealsByDay = plan.mealsByDay;
    final sortedDates = mealsByDay.keys.toList()..sort();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPlanHeader(plan),
          const SizedBox(height: 24),
          ...sortedDates.map((date) {
            final meals = mealsByDay[date]!;
            return MealPlanDayCard(
              date: date,
              meals: meals,
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildNoPlanState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today,
            size: 64,
            color: Theme.of(context).disabledColor,
          ),
          const SizedBox(height: 16),
          const Text(
            'Nessun piano generato',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Aggiungi piatti e genera il piano',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showGeneratePlanDialog,
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Genera Piano'),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanHeader(MealPlanModel plan) {
    final stats = _presenter.getPlanStats();

    return Card(
      elevation: 4,
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '📊 Piano Settimanale',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: _showDeletePlanConfirm,
                  tooltip: 'Elimina piano',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _buildStatChip(
                  '${stats['totalMeals']} pasti',
                  Icons.restaurant,
                  Colors.blue,
                ),
                if (plan.includeBreakfast)
                  _buildStatChip('Colazione', Icons.wb_sunny, Colors.amber),
                if (plan.includeLunch)
                  _buildStatChip('Pranzo', Icons.lunch_dining, Colors.orange),
                if (plan.includeDinner)
                  _buildStatChip('Cena', Icons.nightlight_round, Colors.purple),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(String label, IconData icon, Color color) {
    return Chip(
      avatar: Icon(icon, size: 18, color: color),
      label: Text(label),
      backgroundColor: color.withValues(alpha: 0.1),
    );
  }

  Future<void> _showDeletePlanConfirm() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Elimina Piano'),
        content: const Text('Vuoi eliminare il piano settimanale corrente?'),
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
      await _presenter.clearPlan();
      setState(() {});
    }
  }

  Future<void> _sharePlan() async {
    final text = _presenter.exportPlan();
    await Share.share(text, subject: 'Piano pasti settimanale');
  }
}