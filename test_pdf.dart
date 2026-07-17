import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mr_best/core/utils/pdf_generator.dart';

void main() {
  testWidgets('test pdf generator', (WidgetTester tester) async {
    try {
      print('Starting PDF generation...');
      final bytes = await PdfGenerator.generateStudentReportBytes({'name': 'Test'});
      print('PDF generated successfully: ${bytes.length} bytes');
    } catch (e, stack) {
      print('Error caught: $e');
      print(stack);
    }
  });
}
