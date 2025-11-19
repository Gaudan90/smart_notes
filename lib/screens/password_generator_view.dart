import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final _nameController = TextEditingController();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generatore Password'),
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

          // Campo nomenclatura opzionale
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

    return Column(
      children: [
        Container(
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

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _presenter.history.length,
            itemBuilder: (context, index) {
              final password = _presenter.history[index];

              return PasswordHistoryItem(
                password: password,
                onCopy: () => _copyToClipboard(password.password),
                onDelete: () => _deleteSinglePassword(password.password),
              );
            },
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