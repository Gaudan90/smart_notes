import 'package:flutter/material.dart';

import '../controllers/missing_numbers_presenter.dart';

class MissingNumbersView extends StatefulWidget {
  const MissingNumbersView({super.key});

  @override
  State<MissingNumbersView> createState() => _MissingNumbersViewState();
}

class _MissingNumbersViewState extends State<MissingNumbersView> {
  final _controller = TextEditingController();
  final _presenter = MissingNumbersPresenter();
  String _result = '';

  void _findMissing() {
    setState(() {
      _result = _presenter.findMissingNumbers(_controller.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Numeri Mancanti'),
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
                      'Inserisci sequenza',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Esempio: giorni di allenamento del mese',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme
                            .onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Es: 1, 2, 3, 5, 6, 8, 10',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _findMissing,
                      icon: const Icon(Icons.search),
                      label: const Text('Trova Mancanti'),
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
                          'Risultato',
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
