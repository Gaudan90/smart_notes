import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:smart_notes/controllers/pin_security_presenter.dart';
import '../controllers/password_generator_presenter.dart';
import '../states/password_model.dart';
import '../widget/password/password_display_card.dart';
import '../widget/password/password_config_section.dart';
import '../widget/password/password_export_service.dart';
import '../widget/password/password_history_item.dart';
import '../widget/password/pin_unlock_dialog.dart';
import '../widget/password/password_reveal_dialog.dart';
import '../widget/password/password_export_dialog.dart';

class PasswordGeneratorView extends StatefulWidget {
  const PasswordGeneratorView({super.key});

  @override
  State<PasswordGeneratorView> createState() => _PasswordGeneratorViewState();
}

class _PasswordGeneratorViewState extends State<PasswordGeneratorView>
    with SingleTickerProviderStateMixin {
  final _presenter = PasswordGeneratorPresenter();
  final _securityManager = PinSecurityPresenter();
  final _exportService = PasswordExportService();
  late TextEditingController _nameController;

  PasswordModel? _currentPassword;
  bool _isLoading = true;

  double _length = 12;
  bool _includeUppercase = true;
  bool _includeLowercase = true;
  bool _includeNumbers = true;
  bool _includeSymbols = true;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _tabController = TabController(length: 2, vsync: this);
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    await _presenter.loadHistory();
    setState(() {
      _isLoading = false;
    });
  }

  void _generatePassword() {
    final password = _presenter.generatePassword(
      length: _length.toInt(),
      includeUppercase: _includeUppercase,
      includeLowercase: _includeLowercase,
      includeNumbers: _includeNumbers,
      includeSymbols: _includeSymbols,
      name: _nameController.text.trim().isEmpty ? null : _nameController.text.trim(),
    );

    setState(() {
      _currentPassword = password;
    });

    _presenter.addToHistory(password);
    _nameController.clear();
  }

  Future<void> _copyToClipboard(String password) async {
    await Clipboard.setData(ClipboardData(text: password));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('password_copied'.tr()),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// Mostra dialog per inserire PIN e vedere la password
  Future<void> _showPasswordUnlock(String password) async {
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PinUnlockDialog(
        onVerifyPin: (pin) => _securityManager.verifyPin(pin),
        onGetFailedAttempts: () => _securityManager.getFailedAttempts(),
      ),
    );

    // Gestisci il risultato DOPO che il dialog Ã¨ completamente chiuso
    if (result == 'too_many_attempts') {
      // Aspetta che il dialog sia completamente chiuso
      await Future.delayed(const Duration(milliseconds: 300));

      if (mounted) {
        _securityManager.lock();
        // Naviga alla schermata di recovery
        Navigator.of(context).pushReplacementNamed('/pin_unlock');
      }
    } else if (result == 'success' && mounted) {
      // PIN corretto, mostra il secondo dialog
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        _showPasswordDialog(password);
      }
    }
  }

  void _showPasswordDialog(String password) {
    showDialog(
      context: context,
      builder: (context) => PasswordRevealDialog(
        password: password,
        onCopy: () => _copyToClipboard(password),
      ),
    );
  }

  /// Mostra scelta formato e azione → PIN → esporta
  Future<void> _exportPasswords() async {
    // 1. Scelta formato + azione
    final choice = await showDialog<ExportChoice>(
      context: context,
      builder: (ctx) => ExportChoiceDialog(),
    );

    if (choice == null || !mounted) return;

    // 2. Verifica PIN
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PinUnlockDialog(
        onVerifyPin: (pin) => _securityManager.verifyPin(pin),
        onGetFailedAttempts: () => _securityManager.getFailedAttempts(),
      ),
    );

    if (result == 'too_many_attempts') {
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        _securityManager.lock();
        Navigator.of(context).pushReplacementNamed('/pin_unlock');
      }
      return;
    }

    if (result != 'success' || !mounted) return;

    // 3. Esegui
    try {
      if (choice.action == 'share') {
        if (choice.format == 'pdf') {
          await _exportService.shareAsPdf(_presenter.history);
        } else {
          await _exportService.shareAsTxt(_presenter.history);
        }
      } else {
        // Save to device
        final exportResult = choice.format == 'pdf'
            ? await _exportService.saveAsPdf(_presenter.history)
            : await _exportService.saveAsTxt(_presenter.history);

        if (!mounted) return;

        if (exportResult.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'password_export_saved'.tr(
                    namedArgs: {'path': exportResult.filePath!}),
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 4),
            ),
          );
        } else if (exportResult.error != 'cancelled') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'save_error'.tr(namedArgs: {'error': exportResult.error!})),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('save_error'.tr(namedArgs: {'error': '$e'})),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('password_generator_title'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.lock),
            onPressed: () async {
              _securityManager.lock();
              // Delay minimo per permettere al widget di fare dispose correttamente
              await Future.delayed(const Duration(milliseconds: 100));
              if (mounted) {
                Navigator.of(context).pushReplacementNamed('/pin_unlock');
              }
            },
            tooltip: 'lock_btn'.tr(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'tab_generate'.tr(), icon: const Icon(Icons.password, size: 20)),
            Tab(text: 'tab_history_pwd'.tr(), icon: const Icon(Icons.history, size: 20)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: [
          _buildGeneratorTab(),
          _buildHistoryTab(),
        ],
      ),
    );
  }

  Widget _buildGeneratorTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_currentPassword != null) ...[
            PasswordDisplayCard(
              password: _currentPassword!,
              onCopy: () => _copyToClipboard(_currentPassword!.password),
              isLocked: false, // Appena generata Ã¨ visibile
            ),
            const SizedBox(height: 24),
          ],

          PasswordConfigSection(
            length: _length,
            includeUppercase: _includeUppercase,
            includeLowercase: _includeLowercase,
            includeNumbers: _includeNumbers,
            includeSymbols: _includeSymbols,
            onLengthChanged: (value) => setState(() => _length = value),
            onUppercaseChanged: (value) => setState(() => _includeUppercase = value),
            onLowercaseChanged: (value) => setState(() => _includeLowercase = value),
            onNumbersChanged: (value) => setState(() => _includeNumbers = value),
            onSymbolsChanged: (value) => setState(() => _includeSymbols = value),
          ),

          const SizedBox(height: 24),

          // Campo nome opzionale
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'password_name_label'.tr(),
              hintText: 'password_name_hint'.tr(),
              prefixIcon: const Icon(Icons.label_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
            ),
            maxLength: 30,
            textCapitalization: TextCapitalization.sentences,
          ),

          const SizedBox(height: 16),

          ElevatedButton.icon(
            onPressed: _generatePassword,
            icon: const Icon(Icons.refresh, size: 28),
            label: Text(
              'generate_password_btn'.tr(),
              style: const TextStyle(fontSize: 18),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    if (_presenter.history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Theme.of(context).disabledColor,
            ),
            const SizedBox(height: 16),
            Text(
              'no_passwords_history'.tr(),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'generate_first_password'.tr(),
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'passwords_saved'.tr(namedArgs: {'count': '${_presenter.history.length}'}),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: _exportPasswords,
                      icon: const Icon(Icons.save_alt, size: 20),
                      tooltip: 'password_export_title'.tr(),
                    ),
                    TextButton.icon(
                      onPressed: _clearAllHistory,
                      icon: const Icon(Icons.delete_sweep),
                      label: Text('clear_all_history_pwd'.tr()),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final password = _presenter.history[index];

                return PasswordHistoryItem(
                  password: password,
                  isLocked: true, // Password nella cronologia sono oscurate
                  onCopy: () => _copyToClipboard(password.password),
                  onDelete: () => _deleteSinglePassword(password.password),
                  onUnlock: () => _showPasswordUnlock(password.password),
                );
              },
              childCount: _presenter.history.length,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _clearAllHistory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('confirm'.tr()),
        content: Text('clear_history_confirm_pwd'.tr()),
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
      await _presenter.clearHistory();
      setState(() {});
    }
  }

  Future<void> _deleteSinglePassword(String password) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('confirm'.tr()),
        content: Text('delete_password_confirm'.tr()),
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
      await _presenter.deleteFromHistory(password);
      setState(() {});
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    super.dispose();
  }
}