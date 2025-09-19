import 'package:flutter/material.dart';

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
        title: const Text('Riformulatore Frasi'),
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
                      'Inserisci una frase',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Es: Il gatto mangia il pesce',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _reverse,
                      icon: const Icon(Icons.swap_horiz),
                      label: const Text('Inverti Parole'),
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
                          'Frase invertita',
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