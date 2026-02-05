import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../data/meal_data/dish_category.dart';
import '../../states/dish_model.dart';

class DishListManager extends StatelessWidget {
  final List<DishModel> dishes;
  final Function(String, DishCategory) onAddDish;
  final Function(DishModel) onRemoveDish;
  final Function(int, String, DishCategory) onUpdateDish;
  final VoidCallback onClearAll;

  const DishListManager({
    super.key,
    required this.dishes,
    required this.onAddDish,
    required this.onRemoveDish,
    required this.onUpdateDish,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    if (dishes.isEmpty) {
      return _buildEmptyState(context);
    }

    return Column(
      children: [
        _buildHeader(context),
        Expanded(
          child: _buildDishList(context),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_menu,
            size: 64,
            color: Theme.of(context).disabledColor,
          ),
          const SizedBox(height: 16),
          Text(
            'no_dishes_added'.tr(),
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'add_dishes_in_categories'.tr(),
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'available_dishes'.tr(namedArgs: {'count': '${dishes.length}'}),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (dishes.length > 1)
            TextButton.icon(
              onPressed: () => _showClearConfirmDialog(context),
              icon: const Icon(Icons.delete_sweep),
              label: Text('clear_all'.tr()),
            ),
        ],
      ),
    );
  }

  Widget _buildDishList(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: dishes.length,
      itemBuilder: (context, index) {
        final dish = dishes[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.orange.withValues(alpha: 0.2),
              child: Text(
                dish.category.emoji,
                style: const TextStyle(fontSize: 20),
              ),
            ),
            title: Text(
              dish.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              dish.category.label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _showEditDialog(context, index, dish),
                  tooltip: 'edit'.tr(),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _showDeleteConfirm(context, dish),
                  tooltip: 'delete'.tr(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showEditDialog(
      BuildContext context,
      int index,
      DishModel currentDish,
      ) async {
    final nameController = TextEditingController(text: currentDish.name);
    DishCategory selectedCategory = currentDish.category;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('edit_dish_title'.tr()),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'dish_name_label'.tr(),
                    border: const OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<DishCategory>(
                  value: selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'category_label'.tr(),
                    border: const OutlineInputBorder(),
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
                      setState(() {
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
              child: Text('cancel'.tr()),
            ),
            ElevatedButton(
              onPressed: () {
                final newName = nameController.text.trim();
                if (newName.isNotEmpty) {
                  Navigator.pop(context, {
                    'name': newName,
                    'category': selectedCategory,
                  });
                }
              },
              child: Text('save'.tr()),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      onUpdateDish(index, result['name'], result['category']);
    }
  }

  Future<void> _showDeleteConfirm(BuildContext context, DishModel dish) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('delete_dish_title'.tr()),
        content: Text('delete_dish_confirm'.tr(namedArgs: {'name': dish.name})),
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
      onRemoveDish(dish);
    }
  }

  Future<void> _showClearConfirmDialog(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('confirm'.tr()),
        content: Text('clear_all_dishes'.tr()),
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
      onClearAll();
    }
  }
}