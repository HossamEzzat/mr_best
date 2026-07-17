import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class PdfGenerator {
  static pw.Font? _cairoRegular;
  static pw.Font? _cairoBold;

  /// Load fonts once
  static Future<void> _loadFonts() async {
    if (_cairoRegular == null) {
      final regularData = await rootBundle.load('assets/fonts/Cairo-Regular.ttf');
      _cairoRegular = pw.Font.ttf(regularData);
    }
    if (_cairoBold == null) {
      final boldData = await rootBundle.load('assets/fonts/Cairo-Bold.ttf');
      _cairoBold = pw.Font.ttf(boldData);
    }
  }

  static pw.ThemeData _getTheme() {
    return pw.ThemeData.withFont(
      base: _cairoRegular,
      bold: _cairoBold,
    );
  }

  /// Generates Student Report PDF Bytes
  static Future<Uint8List> generateStudentReportBytes(Map<String, dynamic> studentData) async {
    await _loadFonts();

    final name = studentData['name'] as String? ?? 'طالب';
    final groupName = studentData['group_name'] as String? ?? 'المجموعة';
    final gradeLevel = studentData['grade_level'] as String? ?? 'الصف';
    final phone = studentData['phone']?.toString() ?? 'غير مسجل';
    final parentName = studentData['parent_name']?.toString() ?? 'غير مسجل';
    final parentPhone = studentData['parent_phone']?.toString() ?? 'غير مسجل';
    final school = studentData['school']?.toString() ?? 'غير مسجل';
    final notes = studentData['notes']?.toString() ?? 'لا توجد ملاحظات';

    // Attendance stats
    final att = (studentData['attendance_stats'] as Map<String, dynamic>?) ?? {};
    final present = att['present'] ?? 0;
    final absent = att['absent'] ?? 0;
    final late = att['late'] ?? 0;
    final totalSessions = att['total'] ?? 0;
    final commitmentRate = ((att['rate'] as num?) ?? 0).toStringAsFixed(1);

    // Grade stats
    final grades = (studentData['grade_stats'] as Map<String, dynamic>?) ?? {};
    final earned = ((grades['earned_points'] as num?) ?? 0).toStringAsFixed(1);
    final possible = ((grades['possible_points'] as num?) ?? 0).toStringAsFixed(1);
    final pct = ((grades['percentage'] as num?) ?? 0).toStringAsFixed(1);

    // Ranks
    final ranks = (studentData['ranks'] as Map<String, dynamic>?) ?? {};
    final groupRank = ranks['group_rank'] ?? 1;
    final gradeRank = ranks['grade_rank'] ?? 1;

    final List<Map<String, dynamic>> gradesList = studentData['grades_list'] ?? [];

    final pdf = pw.Document(theme: _getTheme());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => pw.Column(
          children: [
            pw.Text(
              'تقرير الأداء الدراسي والالتزام',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: const PdfColor.fromInt(0xff4f46e5)),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'تطبيق مستر بيست (Mr. Best) لإدارة ومتابعة الطلاب',
              style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 12),
            pw.Divider(color: const PdfColor.fromInt(0xff4f46e5), thickness: 2),
            pw.SizedBox(height: 16),
          ],
        ),
        footer: (context) => pw.Column(
          children: [
            pw.Divider(color: PdfColors.grey300),
            pw.SizedBox(height: 8),
            pw.Text(
              'تم استخراج هذا التقرير تلقائياً عبر تطبيق مستر بيست (Mr. Best)',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
              textAlign: pw.TextAlign.center,
            ),
          ],
        ),
        build: (context) {
          return [
            // Info Grids
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: _buildInfoCard('البيانات الشخصية', [
                    _InfoRow('اسم الطالب:', name),
                    _InfoRow('المجموعة:', groupName),
                    _InfoRow('الصف الدراسي:', gradeLevel),
                    _InfoRow('المدرسة:', school),
                  ]),
                ),
                pw.SizedBox(width: 16),
                pw.Expanded(
                  child: _buildInfoCard('بيانات الاتصال', [
                    _InfoRow('رقم الطالب:', phone, isLtr: true),
                    _InfoRow('ولي الأمر:', parentName),
                    _InfoRow('رقم ولي الأمر:', parentPhone, isLtr: true),
                  ]),
                ),
              ],
            ),
            pw.SizedBox(height: 16),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: _buildInfoCard('إحصائيات الغياب والحضور', [
                    _InfoRow('إجمالي الجلسات:', '$totalSessions'),
                    _InfoRow('الحضور:', '$present', valueColor: const PdfColor.fromInt(0xff0d9488)),
                    _InfoRow('التأخير:', '$late', valueColor: const PdfColor.fromInt(0xffd97706)),
                    _InfoRow('الغياب:', '$absent', valueColor: const PdfColor.fromInt(0xffe11d48)),
                    _InfoRow('نسبة الالتزام:', '$commitmentRate%', isHighlight: true),
                  ]),
                ),
                pw.SizedBox(width: 16),
                pw.Expanded(
                  child: _buildInfoCard('الدرجات والتحصيل العلمي', [
                    _InfoRow('المجموع الكلي:', '$earned / $possible'),
                    _InfoRow('النسبة المئوية:', '$pct%', isHighlight: true),
                    _InfoRow('ترتيب المجموعة:', 'المركز $groupRank', valueColor: const PdfColor.fromInt(0xff4f46e5)),
                    _InfoRow('الترتيب العام:', 'المركز $gradeRank', valueColor: const PdfColor.fromInt(0xff4f46e5)),
                  ]),
                ),
              ],
            ),
            pw.SizedBox(height: 24),

            // Grades Table
            pw.Text(
              'تفاصيل درجات الطالب',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: const PdfColor.fromInt(0xff4f46e5)),
            ),
            pw.SizedBox(height: 8),
            if (gradesList.isEmpty)
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey300)),
                child: pw.Center(child: pw.Text('لا توجد درجات مسجلة')),
              )
            else
              pw.TableHelper.fromTextArray(
                context: context,
                border: pw.TableBorder.all(color: PdfColors.grey300),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.grey800),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
                cellAlignment: pw.Alignment.center,
                headers: ['التاريخ', 'النسبة', 'الدرجة / النهاية', 'التقييم / الاختبار'],
                data: gradesList.map((g) {
                  final category = g['task_category']?.toString() ?? '';
                  final title = g['task_title']?.toString() ?? '';
                  final score = g['score'] ?? 0;
                  final total = g['task_total_score'] ?? 1;
                  final date = g['task_date']?.toString() ?? '';
                  final percentage = total > 0 ? ((score / total) * 100).toStringAsFixed(1) : '0';
                  
                  return [
                    date,
                    '$percentage%',
                    '$score / $total', // Handled LTR issue natively or might need bidi
                    '$title ($category)',
                  ];
                }).toList(),
              ),

            pw.SizedBox(height: 24),
            pw.Text(
              'ملاحظات وتوجيهات المعلم',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: const PdfColor.fromInt(0xff4f46e5)),
            ),
            pw.SizedBox(height: 8),
            pw.Container(
              width: double.infinity,
              height: 60,
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Text(notes),
            ),
          ];
        },
      ),
    );

    return await pdf.save();
  }

  /// Generates Group Summary Report PDF Bytes
  static Future<Uint8List> generateGroupReportBytes(Map<String, dynamic> groupData) async {
    await _loadFonts();

    final groupName = groupData['name'] as String? ?? 'المجموعة';
    final gradeLevel = groupData['grade_level'] as String? ?? 'الصف';
    final List<Map<String, dynamic>> students = groupData['students_list'] ?? [];
    final int totalStudents = students.length;

    final pdf = pw.Document(theme: _getTheme());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => pw.Column(
          children: [
            pw.Text(
              'تقرير كشف ومستوى الطلاب بالكامل',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: const PdfColor.fromInt(0xff4f46e5)),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'تطبيق مستر بيست (Mr. Best) • مجموعة $groupName ($gradeLevel)',
              style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 12),
            pw.Divider(color: const PdfColor.fromInt(0xff4f46e5), thickness: 2),
            pw.SizedBox(height: 16),
          ],
        ),
        footer: (context) => pw.Column(
          children: [
            pw.Divider(color: PdfColors.grey300),
            pw.SizedBox(height: 8),
            pw.Text(
              'تم استخراج كشف المجموعة تلقائياً عبر تطبيق مستر بيست (Mr. Best)',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
              textAlign: pw.TextAlign.center,
            ),
          ],
        ),
        build: (context) {
          return [
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  pw.Text('اسم المجموعة: $groupName', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('الصف الدراسي: $gradeLevel', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('عدد الطلاب: $totalStudents طالب', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ],
              ),
            ),
            pw.SizedBox(height: 16),

            if (students.isEmpty)
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey300)),
                child: pw.Center(child: pw.Text('لا يوجد طلاب بالمجموعة')),
              )
            else
              pw.TableHelper.fromTextArray(
                context: context,
                border: pw.TableBorder.all(color: PdfColors.grey300),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.grey800),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
                cellAlignment: pw.Alignment.center,
                headers: ['النسبة العامة', 'نسبة الحضور', 'رقم الهاتف', 'اسم الطالب', '#'],
                data: List.generate(students.length, (index) {
                  final s = students[index];
                  final sName = s['name']?.toString() ?? '';
                  final sPhone = s['phone']?.toString() ?? 'غير مسجل';
                  final attRate = ((s['attendance_rate'] as num?) ?? 0).toStringAsFixed(1);
                  final gradePct = ((s['grade_percentage'] as num?) ?? 0).toStringAsFixed(1);
                  return [
                    '$gradePct%',
                    '$attRate%',
                    sPhone, // Bidi might be needed here too
                    sName,
                    '${index + 1}',
                  ];
                }),
              ),
          ];
        },
      ),
    );

    return await pdf.save();
  }

  static pw.Widget _buildInfoCard(String title, List<_InfoRow> rows) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800)),
          pw.SizedBox(height: 4),
          pw.Divider(color: PdfColors.grey300),
          pw.SizedBox(height: 6),
          ...rows.map((r) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 6),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(r.label, style: const pw.TextStyle(color: PdfColors.grey700)),
                    pw.Text(
                      r.value,
                      textDirection: r.isLtr ? pw.TextDirection.ltr : pw.TextDirection.rtl,
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        color: r.isHighlight ? const PdfColor.fromInt(0xff4f46e5) : (r.valueColor ?? PdfColors.black),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  /// Direct Share Student Report
  static Future<void> generateAndShareStudentReport(Map<String, dynamic> studentData) async {
    final pdfBytes = await generateStudentReportBytes(studentData);
    final name = studentData['name'] as String? ?? 'طالب';
    final directory = await getTemporaryDirectory();
    final pdfPath = '${directory.path}/تقرير_الطالب_${name.replaceAll(' ', '_')}.pdf';
    final file = File(pdfPath);
    await file.writeAsBytes(pdfBytes);

    await Share.shareXFiles(
      [XFile(pdfPath)],
      subject: 'تقرير الأداء الدراسي للطالب: $name',
    );
  }

  /// Direct Share Group Report
  static Future<void> generateAndShareGroupReport(Map<String, dynamic> groupData) async {
    final pdfBytes = await generateGroupReportBytes(groupData);
    final groupName = groupData['name'] as String? ?? 'مجموعة';
    final directory = await getTemporaryDirectory();
    final pdfPath = '${directory.path}/تقرير_المجموعة_${groupName.replaceAll(' ', '_')}.pdf';
    final file = File(pdfPath);
    await file.writeAsBytes(pdfBytes);

    await Share.shareXFiles(
      [XFile(pdfPath)],
      subject: 'كشف درجات وحضور مجموعة: $groupName',
    );
  }
}

class _InfoRow {
  final String label;
  final String value;
  final bool isLtr;
  final bool isHighlight;
  final PdfColor? valueColor;

  _InfoRow(this.label, this.value, {this.isLtr = false, this.isHighlight = false, this.valueColor});
}
