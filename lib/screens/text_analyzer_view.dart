import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controllers/text_analyzer_presenter.dart';
import '../states/text_analyzer_model.dart';

class TextAnalyzerView extends StatefulWidget {
  const TextAnalyzerView({super.key});

  @override
  State<TextAnalyzerView> createState() => _TextAnalyzerViewState();
}

class _TextAnalyzerViewState extends State<TextAnalyzerView>
    with SingleTickerProviderStateMixin {
  final _presenter = TextAnalyzerPresenter();
  final _textController = TextEditingController();

  TextAnalysisModel? _currentAnalysis;
  bool _isLoading = true;
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

  void _analyzeText() {
    final text = _textController.text;

    if (text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inserisci del testo da analizzare'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final analysis = _presenter.analyzeText(text);

    setState(() {
      _currentAnalysis = analysis;
    });

    _presenter.addToHistory(analysis);

    // Scroll in alto per vedere i risultati
    FocusScope.of(context).unfocus();
  }

  void _clearText() {
    _textController.clear();
    setState(() {
      _currentAnalysis = null;
    });
  }

  void _pasteFromClipboard() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData != null && clipboardData.text != null) {
      _textController.text = clipboardData.text!;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Testo incollato'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
      }
    }
  }

  void _loadFromHistory(TextAnalysisModel analysis) {
    _textController.text = analysis.text;
    setState(() {
      _currentAnalysis = analysis;
    });
    _tabController.animateTo(0); // Torna al tab analisi
  }

  @override
  void dispose() {
    _textController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analizzatore Testi'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Analizza', icon: Icon(Icons.analytics, size: 20)),
            Tab(text: 'Cronologia', icon: Icon(Icons.history, size: 20)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: [
          _buildAnalyzerTab(),
          _buildHistoryTab(),
        ],
      ),
    );
  }

  Widget _buildAnalyzerTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Risultati analisi (se disponibili)
          if (_currentAnalysis != null) ...[
            _buildAnalysisCard(_currentAnalysis!),
            const SizedBox(height: 24),
          ],

          // Campo testo
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Testo da analizzare',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.paste, size: 20),
                            onPressed: _pasteFromClipboard,
                            tooltip: 'Incolla',
                          ),
                          IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: _clearText,
                            tooltip: 'Cancella',
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Incolla o digita il testo qui...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                    ),
                    maxLines: 10,
                    textInputAction: TextInputAction.done,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Bottone analizza
          ElevatedButton.icon(
            onPressed: _analyzeText,
            icon: const Icon(Icons.analytics, size: 28),
            label: const Text(
              'Analizza Testo',
              style: TextStyle(fontSize: 18),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Info box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Incolla un testo per analizzarne parole, caratteri e statistiche',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisCard(TextAnalysisModel analysis) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Risultati Analisi',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Statistiche principali
            _buildStatRow(
              Icons.format_quote,
              'Parole',
              analysis.wordCount.toString(),
              Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildStatRow(
              Icons.text_fields,
              'Caratteri (senza spazi)',
              analysis.characterCount.toString(),
              Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildStatRow(
              Icons.space_bar,
              'Caratteri (con spazi)',
              analysis.characterCountWithSpaces.toString(),
              Colors.purple,
            ),
            const SizedBox(height: 12),
            _buildStatRow(
              Icons.trending_up,
              'Parola più lunga',
              analysis.longestWord,
              Colors.green,
            ),

            const Divider(height: 24),

            // Statistiche aggiuntive
            Text(
              'Statistiche Avanzate',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildStatChip(
                  'Frasi',
                  analysis.sentenceCount.toString(),
                  Colors.teal,
                ),
                _buildStatChip(
                  'Paragrafi',
                  analysis.paragraphCount.toString(),
                  Colors.indigo,
                ),
                _buildStatChip(
                  'Media lunghezza parole',
                  analysis.averageWordLength.toStringAsFixed(1),
                  Colors.deepOrange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Chip(
      avatar: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.2),
        child: Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      label: Text(label),
      backgroundColor: color.withValues(alpha: 0.1),
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
              'Nessuna analisi in cronologia',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'Analizza un testo per iniziare',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Header con statistiche
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.primaryContainer,
          child: _buildHistoryStats(),
        ),

        // Lista analisi
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _presenter.history.length,
            itemBuilder: (context, index) {
              final analysis = _presenter.history[index];
              return _buildHistoryItem(analysis, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryStats() {
    final stats = _presenter.getHistoryStats();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Statistiche Cronologia',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Conferma'),
                    content: const Text('Cancellare tutta la cronologia?'),
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
              },
              icon: const Icon(Icons.delete_sweep),
              label: const Text('Cancella tutto'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildStatChip(
              'Analisi',
              stats['totalAnalyses'].toString(),
              Colors.blue,
            ),
            _buildStatChip(
              'Parole totali',
              stats['totalWords'].toString(),
              Colors.orange,
            ),
            _buildStatChip(
              'Media parole',
              stats['averageWords'].toStringAsFixed(0),
              Colors.green,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHistoryItem(TextAnalysisModel analysis, int index) {
    final preview = analysis.text.length > 100
        ? '${analysis.text.substring(0, 100)}...'
        : analysis.text;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _loadFromHistory(analysis),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      preview,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20),
                    color: Colors.red,
                    onPressed: () async {
                      await _presenter.deleteFromHistory(index);
                      setState(() {});
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildInfoChip(
                    '${analysis.wordCount} parole',
                    Icons.format_quote,
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    '${analysis.characterCount} caratteri',
                    Icons.text_fields,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                _formatDateTime(analysis.analyzedAt),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey.shade700),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) return 'Adesso';
    if (difference.inHours < 1) return '${difference.inMinutes}m fa';
    if (difference.inDays < 1) return '${difference.inHours}h fa';
    if (difference.inDays < 7) return '${difference.inDays}g fa';

    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}