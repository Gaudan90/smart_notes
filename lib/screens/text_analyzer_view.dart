import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import '../controllers/text_analyzer_presenter.dart';
import '../states/text_analyzer_model.dart';
import '../widget/text_analyzer/analysis_result_card.dart';
import '../widget/text_analyzer/history_stats_header.dart';
import '../widget/text_analyzer/text_analysis_history_item.dart';

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
        SnackBar(
          content: Text('enter_text_to_analyze'.tr()),
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
          SnackBar(
            content: Text('text_pasted'.tr()),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 1),
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
    _tabController.animateTo(0);
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
        title: Text('text_analyzer_title'.tr()),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'tab_analyze'.tr(), icon: const Icon(Icons.analytics, size: 20)),
            Tab(text: 'tab_history_pwd'.tr(), icon: const Icon(Icons.history, size: 20)),
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
          if (_currentAnalysis != null) ...[
            AnalysisResultCard(analysis: _currentAnalysis!),
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
                      Text(
                        'text_to_analyze'.tr(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.paste, size: 20),
                            onPressed: _pasteFromClipboard,
                            tooltip: 'paste_btn'.tr(),
                          ),
                          IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: _clearText,
                            tooltip: 'clear_btn'.tr(),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'text_hint'.tr(),
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

          ElevatedButton.icon(
            onPressed: _analyzeText,
            icon: const Icon(Icons.analytics, size: 28),
            label: Text(
              'analyze_text_btn'.tr(),
              style: const TextStyle(fontSize: 18),
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
                    'text_analyzer_info'.tr(),
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
              'no_analysis_history'.tr(),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'analyze_to_start'.tr(),
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Header con statistiche
        HistoryStatsHeader(
          stats: _presenter.getHistoryStats(),
          onClearAll: () async {
            await _presenter.clearHistory();
            setState(() {});
          },
        ),

        // Lista analisi
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _presenter.history.length,
            itemBuilder: (context, index) {
              final analysis = _presenter.history[index];
              return TextAnalysisHistoryItem(
                analysis: analysis,
                onTap: () => _loadFromHistory(analysis),
                onDelete: () async {
                  await _presenter.deleteFromHistory(index);
                  setState(() {});
                },
              );
            },
          ),
        ),
      ],
    );
  }
}