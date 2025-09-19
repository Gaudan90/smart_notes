import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controllers/expense_presenter.dart';
import '../states/expense_stats.dart';

class ExpenseView extends StatefulWidget {
  const ExpenseView({super.key});

  @override
  State<ExpenseView> createState() => _ExpenseViewState();
}

class _ExpenseViewState extends State<ExpenseView> with SingleTickerProviderStateMixin {
  final _presenter = ExpensePresenter();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();

  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = ExpensePresenter.categories.first;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    await _presenter.loadExpenses();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showAddExpenseDialog() {
    _nameController.clear();
    _amountController.clear();
    _selectedDate = DateTime.now();
    _selectedCategory = ExpensePresenter.categories.first;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nuova Spesa'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Descrizione',
                  hintText: 'Es: Spesa al supermercato',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.shopping_bag),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Importo',
                  hintText: '0.00',
                  border: OutlineInputBorder(),
                  prefixText: '€ ',
                  prefixIcon: Icon(Icons.euro),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Categoria',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: ExpensePresenter.categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Data'),
                subtitle: Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey.shade300),
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
            onPressed: () async {
              final amount = double.tryParse(_amountController.text);
              if (_nameController.text.isNotEmpty && amount != null && amount > 0) {
                await _presenter.addExpense(
                  name: _nameController.text,
                  amount: amount,
                  date: _selectedDate,
                  category: _selectedCategory,
                );
                setState(() {});
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Aggiungi'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ExpenseStats stats = _presenter.calculateStats();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analizzatore Spese'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Spese', icon: Icon(Icons.list)),
            Tab(text: 'Statistiche', icon: Icon(Icons.analytics)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: [
          // Tab Spese
          _presenter.expenses.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme
                      .onBackground.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'Nessuna spesa registrata',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme
                        .onBackground.withValues(alpha: 0.5),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _presenter.expenses.length,
            itemBuilder: (context, index) {
              final expense = _presenter.expenses[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    child: Icon(
                      _getCategoryIcon(expense.category),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  title: Text(expense.name),
                  subtitle: Text(
                    '${expense.category} • ${expense.date.day}/${expense.date.month}/${expense.date.year}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '€ ${expense.amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        onPressed: () async {
                          await _presenter.deleteExpense(expense.id);
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Tab Statistiche
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cards statistiche principali
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 1.5,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    children: [
                      _buildStatCard(
                        'Totale',
                        '€ ${stats.total.toStringAsFixed(2)}',
                        Icons.account_balance_wallet,
                        Colors.blue,
                      ),
                      _buildStatCard(
                        'Media',
                        '€ ${stats.average.toStringAsFixed(2)}',
                        Icons.trending_flat,
                        Colors.orange,
                      ),
                      if (stats.highest != null)
                        _buildStatCard(
                          'Più alta',
                          '€ ${stats.highest!.amount.toStringAsFixed(2)}',
                          Icons.arrow_upward,
                          Colors.red,
                        ),
                      if (stats.lowest != null)
                        _buildStatCard(
                          'Più bassa',
                          '€ ${stats.lowest!.amount.toStringAsFixed(2)}',
                          Icons.arrow_downward,
                          Colors.green,
                        ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Spese per categoria
                  if (stats.categoryTotals.isNotEmpty) ...[
                    Text(
                      'Spese per Categoria',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...stats.categoryTotals.entries.map((entry) {
                      final percentage = (entry.value / stats.total * 100);
                      return Card(
                        child: ListTile(
                          leading: Icon(_getCategoryIcon(entry.key)),
                          title: Text(entry.key),
                          subtitle: LinearProgressIndicator(
                            value: percentage / 100,
                            backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '€ ${entry.value.toStringAsFixed(2)}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '${percentage.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddExpenseDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Spesa':
        return Icons.shopping_cart;
      case 'Trasporti':
        return Icons.directions_car;
      case 'Svago':
        return Icons.movie;
      case 'Bollette':
        return Icons.receipt;
      case 'Salute':
        return Icons.local_hospital;
      case 'Abbigliamento':
        return Icons.checkroom;
      case 'Ristorante':
        return Icons.restaurant;
      default:
        return Icons.category;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _tabController.dispose();
    super.dispose();
  }
}