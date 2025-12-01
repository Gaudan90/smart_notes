import 'package:flutter/material.dart';
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
          const Text(
            'Nessun piatto aggiunto',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            'Aggiungi piatti nelle varie categorie',
            style: TextStyle(fontSize: 14, color: Colors.grey),
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
            'Piatti disponibili (${dishes.length})',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (dishes.length > 1)
            TextButton.icon(
              onPressed: () => _showClearConfirmDialog(context),
              icon: const Icon(Icons.delete_sweep),
              label: const Text('Cancella tutto'),
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
                  tooltip: 'Modifica',
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _showDeleteConfirm(context, dish),
                  tooltip: 'Elimina',
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
          title: const Text('Modifica Piatto'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome piatto',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<DishCategory>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Categoria',
                    border: OutlineInputBorder(),
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
              child: const Text('Annulla'),
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
              child: const Text('Salva'),
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
        title: const Text('Elimina Piatto'),
        content: Text('Vuoi eliminare "${dish.name}"?'),
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
      onRemoveDish(dish);
    }
  }

  Future<void> _showClearConfirmDialog(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conferma'),
        content: const Text('Cancellare tutti i piatti?'),
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
      onClearAll();
    }
  }
}