import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../controllers/sentence_presenter.dart';

class SentenceReverserView extends StatefulWidget {
  const SentenceReverserView({super.key});

  @override
  State<SentenceReverserView> createState() => _SentenceReverserViewState();
}

class _SentenceReverserViewState extends State<SentenceReverserView> {
  final _controller = TextEditingController();
  final _presenter = SentencePresenter();
  String _result = '';

  void _reverse() {
    setState(() {
      _result = _presenter.reverseSentence(_controller.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('sr_title'.tr()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'sr_enter_sentence'.tr(),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'sr_input_hint'.tr(),
                        border: const OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _reverse,
                      icon: const Icon(Icons.swap_horiz),
                      label: Text('sr_reverse_btn'.tr()),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_result.isNotEmpty)
              AnimatedOpacity(
                opacity: _result.isNotEmpty ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'sr_reversed_sentence'.tr(),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _result,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}