import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_notes/controllers/pin_security_presenter.dart';
import '../controllers/password_generator_presenter.dart';
import '../states/password_model.dart';
import '../widget/password/password_display_card.dart';
import '../widget/password/password_config_section.dart';
import '../widget/password/password_history_item.dart';

class PasswordGeneratorView extends StatefulWidget {
  const PasswordGeneratorView({super.key});

  @override
  State<PasswordGeneratorView> createState() => _PasswordGeneratorViewState();
}

class _PasswordGeneratorViewState extends State<PasswordGeneratorView>
    with SingleTickerProviderStateMixin {
  final _presenter = PasswordGeneratorPresenter();
  final _securityManager = PinSecurityPresenter();
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
        const SnackBar(
          content: Text('✓ Password copiata negli appunti'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Mostra dialog per inserire PIN e vedere la password
  Future<void> _showPasswordUnlock(String password) async {
    final pinController = TextEditingController();
    bool isPinVisible = false;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.lock_open, color: Colors.blue),
              SizedBox(width: 8),
              Text('Sblocca Password'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Inserisci il tuo PIN per visualizzare la password'),
                const SizedBox(height: 16),
                TextField(
                  controller: pinController,
                  decoration: InputDecoration(
                    labelText: 'PIN',
                    hintText: '••••••••',
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPinVisible ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setDialogState(() {
                          isPinVisible = !isPinVisible;
                        });
                      },
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 8,
                  obscureText: !isPinVisible,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Annulla'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (pinController.text.length != 8) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Il PIN deve essere di 8 cifre'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final isValid = await _securityManager.verifyPin(pinController.text);
                if (isValid) {
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext, true);
                  }
                } else {
                  final attempts = await _securityManager.getFailedAttempts();
                  if (attempts >= 3) {
                    // PRIMA chiudi il dialog
                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext, false);
                    }

                    // Aspetta che il dialog sia completamente chiuso
                    await Future.delayed(const Duration(milliseconds: 300));

                    // POI naviga SOLO se ancora mounted
                    if (mounted) {
                      _securityManager.lock();
                      Navigator.of(context).pushReplacementNamed('/pin_unlock');
                    }
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('PIN errato. Tentativi rimasti: ${3 - attempts}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                    pinController.clear();
                  }
                }
              },
              child: const Text('Sblocca'),
            ),
          ],
        ),
      ),
    );

    // Se il PIN era corretto, mostra il secondo dialog
    if (result == true && mounted) {
      // delay per assicurarsi che il primo dialog sia completamente chiuso
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        _showPasswordDialog(password);
      }
    }
  }

  void _showPasswordDialog(String password) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.visibility, color: Colors.green),
            SizedBox(width: 8),
            Text('Password Sbloccata'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green),
              ),
              child: SelectableText(
                password,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                _copyToClipboard(password);
                Navigator.pop(context);
              },
              icon: const Icon(Icons.copy),
              label: const Text('Copia'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Chiudi'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generatore Password'),
        actions: [
          IconButton(
            icon: const Icon(Icons.lock),
            onPressed: () async {
              _securityManager.lock();
              // Delay per permettere al widget di fare dispose
              await Future.delayed(const Duration(milliseconds: 100));
              if (mounted) {
                Navigator.of(context).pushReplacementNamed('/pin_unlock');
              }
            },
            tooltip: 'Blocca',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Genera', icon: Icon(Icons.password, size: 20)),
            Tab(text: 'Cronologia', icon: Icon(Icons.history, size: 20)),
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
              isLocked: false,
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
              labelText: 'Nome password (opzionale)',
              hintText: 'es. Gmail, Netflix, Banca...',
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
            label: const Text(
              'Genera Password',
              style: TextStyle(fontSize: 18),
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
            const Text(
              'Nessuna password in cronologia',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'Genera la tua prima password sicura',
              style: TextStyle(fontSize: 14, color: Colors.grey),
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
                  '${_presenter.history.length} password salvate',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextButton.icon(
                  onPressed: _clearAllHistory,
                  icon: const Icon(Icons.delete_sweep),
                  label: const Text('Cancella tutto'),
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
                  isLocked: true,
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
        title: const Text('Conferma'),
        content: const Text('Eliminare tutta la cronologia?'),
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
      await _presenter.clearHistory();
      setState(() {});
    }
  }

  Future<void> _deleteSinglePassword(String password) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conferma'),
        content: const Text('Eliminare questa password dalla cronologia?'),
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