import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../controllers/countdown_presenter.dart';
import '../widget/countdown/countdown_add_dialog.dart';
import '../widget/countdown/countdown_card.dart';
import '../widget/countdown/countdown_edit_dialog.dart';

class CountdownView extends StatefulWidget {
  const CountdownView({super.key});

  @override
  State<CountdownView> createState() => _CountdownViewState();
}

class _CountdownViewState extends State<CountdownView> {
  final CountdownPresenter _presenter = CountdownPresenter();
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  bool _showExpired = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCountdowns();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCountdowns() async {
    setState(() => _isLoading = true);
    await _presenter.loadCountdowns();
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => CountdownAddDialog(
        presenter: _presenter,
        onCountdownAdded: () => setState(() {}),
      ),
    );
  }

  void _showEditDialog(String countdownId) {
    final countdown = _presenter.getCountdownById(countdownId);
    if (countdown == null) return;

    showDialog(
      context: context,
      builder: (context) => CountdownEditDialog(
        presenter: _presenter,
        countdown: countdown,
        onCountdownUpdated: () => setState(() {}),
      ),
    );
  }

  Future<void> _deleteCountdown(String id, String title) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('confirm_deletion'.tr()),
        content: Text('delete_countdown_confirm'.tr(namedArgs: {'title': title})),
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
      await _presenter.deleteCountdown(id);
      setState(() {});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('countdown_deleted'.tr()),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _deleteAllExpired() async {
    final expiredCount = _presenter.getExpiredCountdowns().length;
    if (expiredCount == 0) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('confirm_deletion'.tr()),
        content: Text('delete_all_completed_confirm'.tr(namedArgs: {
          'count': '$expiredCount'
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
            child: Text('delete_all_btn'.tr()),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _presenter.deleteExpiredCountdowns();
      setState(() {});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('countdowns_deleted'.tr(namedArgs: {
              'count': '$expiredCount'
            })),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  List<dynamic> _getFilteredCountdowns() {
    final countdowns = _searchQuery.isEmpty
        ? _presenter.countdowns
        : _presenter.searchCountdowns(_searchQuery);

    if (_showExpired) {
      return countdowns.where((c) => c.isExpired).toList();
    } else {
      return countdowns.where((c) => !c.isExpired).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final filteredCountdowns = _getFilteredCountdowns();
    final activeCount = _presenter.getActiveCountdowns().length;
    final expiredCount = _presenter.getExpiredCountdowns().length;

    return Scaffold(
      appBar: AppBar(
        title: Text('countdown_goals'.tr()),
        actions: [
          if (expiredCount > 0)
            IconButton(
              icon: Icon(
                _showExpired ? Icons.access_time : Icons.check_circle_outline,
              ),
              onPressed: () {
                setState(() {
                  _showExpired = !_showExpired;
                });
              },
              tooltip: _showExpired
                  ? 'show_active'.tr(namedArgs: {'count': '$activeCount'})
                  : 'show_completed'.tr(namedArgs: {'count': '$expiredCount'}),
            ),

          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'delete_expired') {
                await _deleteAllExpired();
              }
            },
            itemBuilder: (context) => [
              if (expiredCount > 0)
                PopupMenuItem(
                  value: 'delete_expired',
                  child: Row(
                    children: [
                      const Icon(Icons.delete_sweep, color: Colors.red),
                      const SizedBox(width: 8),
                      Text('delete_completed'.tr(namedArgs: {
                        'count': '$expiredCount'
                      })),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          if (_presenter.countdowns.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'search_countdown'.tr(),
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                },
              ),
            ),

          if (!_showExpired && activeCount > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.timer,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '$activeCount ${activeCount == 1 ? 'active_goal'.tr() : 'active_goals'.tr()}',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 8),

          Expanded(
            child: filteredCountdowns.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredCountdowns.length,
              itemBuilder: (context, index) {
                final countdown = filteredCountdowns[index];
                return CountdownCard(
                  countdown: countdown,
                  onTap: () => _showEditDialog(countdown.id),
                  onDelete: () => _deleteCountdown(
                    countdown.id,
                    countdown.title,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        icon: const Icon(Icons.add),
        label: Text('new_goal'.tr()),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _showExpired ? Icons.check_circle_outline : Icons.timer_outlined,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            _showExpired
                ? 'no_completed_goals'.tr()
                : 'no_active_countdown'.tr(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _showExpired
                ? 'completed_goals_appear_here'.tr()
                : 'create_first_countdown'.tr(),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          if (!_showExpired) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showAddDialog,
              icon: const Icon(Icons.add),
              label: Text('create_countdown'.tr()),
            ),
          ],
        ],
      ),
    );
  }
}