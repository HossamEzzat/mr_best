import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class PdfPreviewScreen extends StatelessWidget {
  final String title;
  final String pdfFileName;
  final Future<Uint8List> Function(PdfPageFormat format) buildPdf;

  const PdfPreviewScreen({
    super.key,
    required this.title,
    required this.pdfFileName,
    required this.buildPdf,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.blue),
            tooltip: 'مشاركة PDF',
            onPressed: () async {
              final bytes = await buildPdf(PdfPageFormat.a4);
              await Printing.sharePdf(
                bytes: bytes,
                filename: pdfFileName,
              );
            },
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: PdfPreview(
          build: buildPdf,
          maxPageWidth: 700,
          pdfFileName: pdfFileName,
          canChangePageFormat: false,
          canChangeOrientation: false,
          canDebug: false,
          loadingWidget: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('جاري تحضير واستعراض التقرير (PDF)...', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          onError: (context, error) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'حدث خطأ أثناء إعداد التقرير: $error',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('العودة'),
                    ),
                  ],
                ),
              ),
            );
          },
          actions: [
            PdfPreviewAction(
              icon: const Icon(Icons.share),
              onPressed: (context, build, pageFormat) async {
                final bytes = await build(pageFormat);
                await Printing.sharePdf(
                  bytes: bytes,
                  filename: pdfFileName,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
