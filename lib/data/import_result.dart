class ImportResult {
  final int imported;
  final int skipped;
  final int total;

  ImportResult({
    required this.imported,
    required this.skipped,
    required this.total,
  });

  String get message {
    if (imported == 0) {
      return 'Nessun acquisto importato. Verifica il formato del file.';
    }

    String msg = 'Importati $imported acquisti';
    if (skipped > 0) {
      msg += ' ($skipped righe saltate)';
    }
    return msg;
  }
}