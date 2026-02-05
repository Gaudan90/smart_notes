import 'package:easy_localization/easy_localization.dart';

class ImportResult {
  final int imported;
  final int skipped;
  final int total;

  ImportResult({
    required this.imported,
    required this.skipped,
    required this.total,
  });

  /// Messaggio localizzato del risultato import
  String get message {
    if (imported == 0) {
      return 'import_no_purchases'.tr();
    }

    String msg = 'import_success'.tr(namedArgs: {'count': '$imported'});
    if (skipped > 0) {
      msg += ' ${'import_skipped'.tr(namedArgs: {'skipped': '$skipped'})}';
    }
    return msg;
  }
}