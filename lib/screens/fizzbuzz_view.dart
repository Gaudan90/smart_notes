import 'package:flutter/material.dart';

import '../controllers/fizzbuzz_presenter.dart';

class FizzBuzzView extends StatefulWidget {
  const FizzBuzzView({super.key});

  @override
  State<FizzBuzzView> createState() => _FizzBuzzViewState();
}

class _FizzBuzzViewState extends State<FizzBuzzView> {
  final _limitController = TextEditingController();
  final _fizzController = TextEditingController(text: 'Studio');
  final _buzzController = TextEditingController(text: 'Allenamento');
  final _bothController = TextEditingController(text: 'Riposo');
  final _presenter = FizzBuzzPresenter();
  String _result = '';

  void _generate() {
    setState(() {
      _result = _presenter.generateRoutine(
        _limitController.text,
        _fizzController.text,
        _buzzController.text,
        _bothController.text,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Routine Planner'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Configura la tua routine',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _limitController,
                          decoration: const InputDecoration(
                            labelText: 'Numero di giorni',
                            hintText: 'Es: 30',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _fizzController,
                          decoration: const InputDecoration(
                            labelText: 'Ogni 3 giorni',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _buzzController,
                          decoration: const InputDecoration(
                            labelText: 'Ogni 5 giorni',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _bothController,
                          decoration: const InputDecoration(
                            labelText: 'Ogni 15 giorni',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _generate,
                          icon: const Icon(Icons.event_repeat),
                          label: const Text('Genera Routine'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (_result.isNotEmpty) ...[
              const SizedBox(height: 16),
              Expanded(
                child: AnimatedOpacity(
                  opacity: _result.isNotEmpty ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'La tua routine',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Text(_result),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _limitController.dispose();
    _fizzController.dispose();
    _buzzController.dispose();
    _bothController.dispose();
    super.dispose();
  }
}