import 'dart:math';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../controllers/dice_roller_presenter.dart';
import '../states/dice_roller_model.dart';
import '../widget/dice/dice_result_display.dart';
import '../widget/dice/dice_selectors.dart';
import '../widget/dice/dice_history_list.dart';

class DiceRollerView extends StatefulWidget {
  const DiceRollerView({super.key});

  @override
  State<DiceRollerView> createState() => _DiceRollerViewState();
}

class _DiceRollerViewState extends State<DiceRollerView>
    with TickerProviderStateMixin {
  final _presenter = DiceRollerPresenter();

  int _diceCount = 1;
  int _diceFaces = 6;
  DiceRollModel? _lastRoll;
  bool _isRolling = false;
  bool _isLoading = true;

  late TabController _tabController;

  late AnimationController _rollController;
  late Animation<double> _shakeAnimation;
  late Animation<double> _scaleAnimation;

  late AnimationController _resultController;
  late Animation<double> _resultFadeIn;
  late Animation<double> _resultScale;

  List<int> _animatingNumbers = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);
    _loadHistory();

    _rollController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _rollController, curve: Curves.elasticOut),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 0.85), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.85, end: 1.0), weight: 40),
    ]).animate(CurvedAnimation(parent: _rollController, curve: Curves.easeOut));

    _resultController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _resultFadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _resultController, curve: Curves.easeOut),
    );
    _resultScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _resultController, curve: Curves.elasticOut),
    );
  }

  Future<void> _loadHistory() async {
    await _presenter.loadHistory();
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _rollController.dispose();
    _resultController.dispose();
    super.dispose();
  }

  Future<void> _rollDice() async {
    if (_isRolling) return;

    setState(() {
      _isRolling = true;
      _lastRoll = null;
    });

    _resultController.reset();
    _rollController.reset();
    _rollController.forward();

    for (int i = 0; i < 8; i++) {
      await Future.delayed(const Duration(milliseconds: 80));
      if (!mounted) return;
      setState(() {
        _animatingNumbers = List.generate(
          _diceCount,
              (_) => _random.nextInt(_diceFaces) + 1,
        );
      });
    }

    final roll = await _presenter.roll(
      count: _diceCount,
      faces: _diceFaces,
    );

    setState(() {
      _lastRoll = roll;
      _animatingNumbers = roll.results;
      _isRolling = false;
    });

    _resultController.forward();
  }

  void _confirmClearPersistentHistory() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('dice_clear_history'.tr()),
        content: Text('clear_history_confirm_text'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('cancel'.tr()),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _presenter.clearPersistentHistory();
              setState(() {});
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('confirm'.tr()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('dice_roller'.tr()),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: const Icon(Icons.casino),
              text: 'dice_roll'.tr(),
            ),
            Tab(
              icon: const Icon(Icons.history),
              text: 'tab_history'.tr(),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRollTab(),
          _buildHistoryTab(),
        ],
      ),
    );
  }

  // ── TAB 1: Roll ──

  Widget _buildRollTab() {
    return Column(
      children: [
        Expanded(
          flex: 3,
          child: _buildMainArea(),
        ),
        DiceSelectors(
          diceCount: _diceCount,
          diceFaces: _diceFaces,
          onCountChanged: (v) => setState(() => _diceCount = v),
          onFacesChanged: (v) => setState(() => _diceFaces = v),
        ),
        _buildRollButton(),
        if (_presenter.sessionHistory.isNotEmpty)
          Expanded(
            flex: 2,
            child: DiceHistoryList(history: _presenter.sessionHistory),
          ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildMainArea() {
    return AnimatedBuilder(
      animation: _rollController,
      builder: (context, child) {
        final shakeOffset = _isRolling
            ? sin(_shakeAnimation.value * 6 * pi) *
            12 *
            (1 - _shakeAnimation.value)
            : 0.0;
        final scale = _isRolling ? _scaleAnimation.value : 1.0;

        return Center(
          child: Transform.translate(
            offset: Offset(shakeOffset, 0),
            child: Transform.scale(
              scale: scale,
              child: DiceResultDisplay(
                lastRoll: _lastRoll,
                animatingNumbers: _animatingNumbers,
                diceFaces: _diceFaces,
                diceCount: _diceCount,
                isRolling: _isRolling,
                resultFadeIn: _resultFadeIn,
                resultScale: _resultScale,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRollButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: FilledButton.icon(
          onPressed: _isRolling ? null : _rollDice,
          icon: AnimatedRotation(
            turns: _isRolling ? 2 : 0,
            duration: const Duration(milliseconds: 800),
            child: const Icon(Icons.casino, size: 28),
          ),
          label: Text(
            _isRolling
                ? 'dice_rolling'.tr()
                : '${'dice_roll'.tr()} ${_diceCount}d$_diceFaces',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }

  // ── TAB 2: History persistente ──

  Widget _buildHistoryTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final history = _presenter.persistentHistory;

    if (history.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.2),
            ),
            const SizedBox(height: 12),
            Text(
              'dice_no_history'.tr(),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Header con conteggio e pulsante cancella
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 8, 0),
          child: Row(
            children: [
              Text(
                'dice_total_rolls'.tr(args: ['${history.length}']),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'dice_clear_history'.tr(),
                onPressed: _confirmClearPersistentHistory,
              ),
            ],
          ),
        ),
        Expanded(
          child: DiceHistoryList(
            history: history,
            showHeader: false,
          ),
        ),
      ],
    );
  }
}