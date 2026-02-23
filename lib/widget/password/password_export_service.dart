import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../states/password_model.dart';

class ExportResult {
  final bool success;
  final String? filePath;
  final String? error;

  const ExportResult._({required this.success, this.filePath, this.error});

  factory ExportResult.ok(String path) =>
      ExportResult._(success: true, filePath: path);

  factory ExportResult.fail(String error) =>
      ExportResult._(success: false, error: error);
}

/// Servizio per esportare la cronologia password come PDF o TXT.
class PasswordExportService {
  // ── Metodi pubblici ──

  /// Condivide come TXT tramite il foglio di condivisione nativo.
  Future<void> shareAsTxt(List<PasswordModel> passwords) async {
    final file = await _writeTxtToTemp(passwords);
    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)]),
    );
  }

  /// Condivide come PDF tramite il foglio di condivisione nativo.
  Future<void> shareAsPdf(List<PasswordModel> passwords) async {
    final file = await _writePdfToTemp(passwords);
    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)]),
    );
  }

  /// Salva come TXT nella directory scelta dall'utente.
  /// Ritorna [ExportResult] con il path del file salvato.
  Future<ExportResult> saveAsTxt(List<PasswordModel> passwords) async {
    final dir = await FilePicker.platform.getDirectoryPath();
    if (dir == null) return ExportResult.fail('cancelled');

    try {
      final now = DateTime.now();
      final content = _buildTxtContent(passwords, now);
      final fileName = 'passwords_${_fileTimestamp(now)}.txt';
      final file = File('$dir/$fileName');
      await file.writeAsString(content);
      return ExportResult.ok(file.path);
    } catch (e) {
      return ExportResult.fail('$e');
    }
  }

  /// Salva come PDF nella directory scelta dall'utente.
  /// Ritorna [ExportResult] con il path del file salvato.
  Future<ExportResult> saveAsPdf(List<PasswordModel> passwords) async {
    final dir = await FilePicker.platform.getDirectoryPath();
    if (dir == null) return ExportResult.fail('cancelled');

    try {
      final now = DateTime.now();
      final pdfDoc = _buildPdfDocument(passwords, now);
      final fileName = 'passwords_${_fileTimestamp(now)}.pdf';
      final file = File('$dir/$fileName');
      await file.writeAsBytes(await pdfDoc.save());
      return ExportResult.ok(file.path);
    } catch (e) {
      return ExportResult.fail('$e');
    }
  }

  // Generazione contenuto TXT

  Future<File> _writeTxtToTemp(List<PasswordModel> passwords) async {
    final now = DateTime.now();
    final content = _buildTxtContent(passwords, now);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/passwords_${_fileTimestamp(now)}.txt');
    await file.writeAsString(content);
    return file;
  }

  String _buildTxtContent(List<PasswordModel> passwords, DateTime now) {
    final buffer = StringBuffer();

    buffer.writeln('=======================================');
    buffer.writeln('  ${'password_export_title'.tr()}');
    buffer.writeln(
        '  ${'password_export_date'.tr()}: ${_formatDate(now)}');
    buffer.writeln(
        '  ${'password_export_count'.tr()}: ${passwords.length}');
    buffer.writeln('=======================================');
    buffer.writeln();

    for (int i = 0; i < passwords.length; i++) {
      final p = passwords[i];
      final hasName = p.name != null && p.name!.isNotEmpty;

      buffer.writeln('── #${i + 1} ${'-' * 32}');
      if (hasName) {
        buffer.writeln('  ${'password_name_label'.tr()}: ${p.name}');
      }
      buffer.writeln('  ${'password_label'.tr()}: ${p.password}');
      buffer.writeln('  ${'password_length_label'.tr()}: ${p.length}');
      buffer.writeln(
          '  ${'password_strength_label'.tr()}: ${_strengthText(p.strength)}');
      buffer.writeln(
          '  ${'password_export_date'.tr()}: ${_formatDate(p.generatedAt)}');
      buffer.writeln();
    }

    buffer.writeln('=======================================');
    buffer.writeln('  ${'password_export_warning'.tr()}');
    buffer.writeln('=======================================');

    return buffer.toString();
  }

  // Generazione contenuto PDF

  Future<File> _writePdfToTemp(List<PasswordModel> passwords) async {
    final now = DateTime.now();
    final pdfDoc = _buildPdfDocument(passwords, now);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/passwords_${_fileTimestamp(now)}.pdf');
    await file.writeAsBytes(await pdfDoc.save());
    return file;
  }

  pw.Document _buildPdfDocument(
      List<PasswordModel> passwords, DateTime now) {
    final pdf = pw.Document();

    const int perPage = 20;
    final int totalPages = (passwords.length / perPage).ceil();

    for (int page = 0; page < totalPages; page++) {
      final start = page * perPage;
      final end = (start + perPage).clamp(0, passwords.length);
      final pagePasswords = passwords.sublist(start, end);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (page == 0) ...[
                  _buildPdfHeader(now, passwords.length),
                  pw.SizedBox(height: 16),
                  pw.Divider(thickness: 2),
                  pw.SizedBox(height: 12),
                ],
                pw.Table(
                  border: pw.TableBorder.all(
                    color: PdfColors.grey400,
                    width: 0.5,
                  ),
                  columnWidths: {
                    0: const pw.FixedColumnWidth(30),
                    1: const pw.FlexColumnWidth(2),
                    2: const pw.FlexColumnWidth(3),
                    3: const pw.FixedColumnWidth(35),
                    4: const pw.FlexColumnWidth(1.5),
                  },
                  children: [
                    if (page == 0)
                      pw.TableRow(
                        decoration: const pw.BoxDecoration(
                          color: PdfColors.grey200,
                        ),
                        children: [
                          _tableHeader('#'),
                          _tableHeader('password_name_label'.tr()),
                          _tableHeader('password_label'.tr()),
                          _tableHeader('Len'),
                          _tableHeader('password_export_date'.tr()),
                        ],
                      ),
                    ...pagePasswords.asMap().entries.map((entry) {
                      final idx = start + entry.key + 1;
                      final p = entry.value;
                      final hasName =
                          p.name != null && p.name!.isNotEmpty;
                      return pw.TableRow(
                        decoration: pw.BoxDecoration(
                          color: idx.isOdd
                              ? PdfColors.white
                              : PdfColors.grey50,
                        ),
                        children: [
                          _tableCell('$idx',
                              align: pw.TextAlign.center),
                          _tableCell(hasName ? p.name! : '—'),
                          _tableCell(p.password,
                              font: pw.Font.courier(), fontSize: 9),
                          _tableCell('${p.length}',
                              align: pw.TextAlign.center),
                          _tableCell(_formatDateShort(p.generatedAt),
                              fontSize: 8),
                        ],
                      );
                    }),
                  ],
                ),
                pw.Spacer(),
                pw.Center(
                  child: pw.Text(
                    '${page + 1} / $totalPages',
                    style: const pw.TextStyle(
                      fontSize: 9,
                      color: PdfColors.grey500,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );
    }

    return pdf;
  }

  // Helper PDF

  pw.Widget _buildPdfHeader(DateTime now, int count) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'password_export_title'.tr(),
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              '${'password_export_count'.tr()}: $count',
              style: const pw.TextStyle(
                fontSize: 11,
                color: PdfColors.grey600,
              ),
            ),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              _formatDate(now),
              style: const pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey500,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(
                  horizontal: 8, vertical: 3),
              decoration: pw.BoxDecoration(
                color: PdfColors.red50,
                borderRadius: pw.BorderRadius.circular(4),
                border: pw.Border.all(color: PdfColors.red200),
              ),
              child: pw.Text(
                'password_export_warning'.tr(),
                style: pw.TextStyle(
                  fontSize: 8,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.red800,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _tableHeader(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  pw.Widget _tableCell(
      String text, {
        pw.Font? font,
        double fontSize = 9,
        pw.TextAlign align = pw.TextAlign.left,
      }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: fontSize, font: font),
        textAlign: align,
      ),
    );
  }

  // Formattazione

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }

  String _formatDateShort(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}';
  }

  String _fileTimestamp(DateTime dt) {
    return '${dt.year}'
        '${dt.month.toString().padLeft(2, '0')}'
        '${dt.day.toString().padLeft(2, '0')}_'
        '${dt.hour.toString().padLeft(2, '0')}'
        '${dt.minute.toString().padLeft(2, '0')}';
  }

  String _strengthText(int strength) {
    if (strength >= 80) return 'strength_very_strong'.tr();
    if (strength >= 60) return 'strength_strong'.tr();
    if (strength >= 40) return 'strength_medium'.tr();
    if (strength >= 20) return 'strength_weak'.tr();
    return 'strength_very_weak'.tr();
  }
}