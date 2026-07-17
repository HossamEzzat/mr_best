import 'dart:io';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class PdfGenerator {
  static Future<void> generateAndShareStudentReport(Map<String, dynamic> studentData) async {
    final name = studentData['name'] as String;
    final groupName = studentData['group_name'] as String;
    final gradeLevel = studentData['grade_level'] as String;
    final phone = studentData['phone'] ?? 'غير مسجل';
    final parentName = studentData['parent_name'] ?? 'غير مسجل';
    final parentPhone = studentData['parent_phone'] ?? 'غير مسجل';
    final school = studentData['school'] ?? 'غير مسجل';
    final notes = studentData['notes'] ?? 'لا توجد ملاحظات';

    // Attendance stats
    final att = studentData['attendance_stats'] as Map<String, dynamic>;
    final present = att['present'];
    final absent = att['absent'];
    final late = att['late'];
    final totalSessions = att['total'];
    final commitmentRate = (att['rate'] as num).toStringAsFixed(1);

    // Grade stats
    final grades = studentData['grade_stats'] as Map<String, dynamic>;
    final earned = (grades['earned_points'] as num).toStringAsFixed(1);
    final possible = (grades['possible_points'] as num).toStringAsFixed(1);
    final pct = (grades['percentage'] as num).toStringAsFixed(1);

    // Ranks
    final ranks = studentData['ranks'] as Map<String, dynamic>;
    final groupRank = ranks['group_rank'];
    final gradeRank = ranks['grade_rank'];

    // Load individual grades from DB for HTML table
    final dbHelper = studentData['db_helper_instance']; // We pass this or we query it inside
    final List<Map<String, dynamic>> gradesList = studentData['grades_list'] ?? [];
    
    String gradesRows = '';
    if (gradesList.isEmpty) {
      gradesRows = '<tr><td colspan="4" style="text-align:center;">لا توجد درجات مسجلة</td></tr>';
    } else {
      for (final g in gradesList) {
        final category = g['task_category'];
        final title = g['task_title'];
        final score = g['score'];
        final total = g['task_total_score'];
        final date = g['task_date'];
        gradesRows += '''
          <tr>
            <td>$title ($category)</td>
            <td style="text-align:center; direction:ltr;">$score / $total</td>
            <td style="text-align:center;">${((score / total) * 100).toStringAsFixed(1)}%</td>
            <td style="text-align:center;">$date</td>
          </tr>
        ''';
      }
    }

    final htmlContent = '''
<!DOCTYPE html>
<html dir="rtl" lang="ar">
<head>
  <meta charset="utf-8">
  <title>تقرير الطالب - مستر بيست</title>
  <style>
    @import url('https://fonts.googleapis.com/css2?family=Cairo:wght@400;700&display=swap');
    body {
      font-family: 'Cairo', 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
      margin: 0;
      padding: 30px;
      color: #1e293b;
      background-color: #ffffff;
      line-height: 1.6;
    }
    .header {
      text-align: center;
      border-bottom: 3px solid #6366f1;
      padding-bottom: 15px;
      margin-bottom: 25px;
    }
    .header h1 {
      color: #4f46e5;
      margin: 0;
      font-size: 28px;
    }
    .header p {
      color: #64748b;
      margin: 5px 0 0 0;
      font-size: 14px;
    }
    .section-title {
      font-size: 18px;
      font-weight: bold;
      color: #4f46e5;
      border-right: 4px solid #6366f1;
      padding-right: 10px;
      margin: 20px 0 10px 0;
    }
    .grid {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 15px;
      margin-bottom: 20px;
    }
    .card {
      background-color: #f8fafc;
      border: 1px solid #e2e8f0;
      border-radius: 8px;
      padding: 15px;
    }
    .card-title {
      font-weight: bold;
      color: #334155;
      margin-bottom: 8px;
      border-bottom: 1px dashed #cbd5e1;
      padding-bottom: 4px;
    }
    .info-row {
      display: flex;
      justify-content: space-between;
      margin-bottom: 6px;
      font-size: 14px;
    }
    .info-label {
      color: #64748b;
      font-weight: 500;
    }
    .info-value {
      font-weight: bold;
      color: #0f172a;
    }
    table {
      width: 100%;
      border-collapse: collapse;
      margin-top: 10px;
      font-size: 13px;
    }
    th, td {
      border: 1px solid #e2e8f0;
      padding: 8px 10px;
      text-align: right;
    }
    th {
      background-color: #f1f5f9;
      color: #334155;
      font-weight: bold;
    }
    tr:nth-child(even) {
      background-color: #f8fafc;
    }
    .badge {
      display: inline-block;
      padding: 3px 8px;
      border-radius: 12px;
      font-size: 12px;
      font-weight: bold;
      color: white;
    }
    .badge-present { background-color: #0d9488; }
    .badge-absent { background-color: #e11d48; }
    .badge-late { background-color: #d97706; }
    .footer {
      margin-top: 40px;
      text-align: center;
      font-size: 12px;
      color: #94a3b8;
      border-top: 1px solid #e2e8f0;
      padding-top: 15px;
    }
    .highlight {
      font-size: 18px;
      color: #4f46e5;
      font-weight: bold;
    }
  </style>
</head>
<body>
  <div class="header">
    <h1>تقرير الأداء الدراسي والالتزام</h1>
    <p>مادة الرياضيات - تطبيق مستر بيست</p>
  </div>

  <div class="grid">
    <div class="card">
      <div class="card-title">البيانات الشخصية</div>
      <div class="info-row"><span class="info-label">اسم الطالب:</span><span class="info-value">$name</span></div>
      <div class="info-row"><span class="info-label">المجموعة الدراسية:</span><span class="info-value">$groupName</span></div>
      <div class="info-row"><span class="info-label">الصف الدراسي:</span><span class="info-value">$gradeLevel</span></div>
      <div class="info-row"><span class="info-label">المدرسة:</span><span class="info-value">$school</span></div>
    </div>
    
    <div class="card">
      <div class="card-title">بيانات الاتصال</div>
      <div class="info-row"><span class="info-label">رقم هاتف الطالب:</span><span class="info-value">$phone</span></div>
      <div class="info-row"><span class="info-label">اسم ولي الأمر:</span><span class="info-value">$parentName</span></div>
      <div class="info-row"><span class="info-label">رقم ولي الأمر:</span><span class="info-value">$parentPhone</span></div>
    </div>
  </div>

  <div class="grid">
    <div class="card">
      <div class="card-title">إحصائيات الغياب والحضور</div>
      <div class="info-row"><span class="info-label">إجمالي الجلسات:</span><span class="info-value">$totalSessions</span></div>
      <div class="info-row"><span class="info-label">عدد مرات الحضور:</span><span class="info-value" style="color: #0d9488;">$present</span></div>
      <div class="info-row"><span class="info-label">عدد مرات التأخير:</span><span class="info-value" style="color: #d97706;">$late</span></div>
      <div class="info-row"><span class="info-label">عدد مرات الغياب:</span><span class="info-value" style="color: #e11d48;">$absent</span></div>
      <div class="info-row" style="margin-top:8px; border-top:1px dashed #cbd5e1; padding-top:4px; margin-bottom: 4px;"><span class="info-label">نسبة الالتزام:</span><span class="info-value highlight">$commitmentRate%</span></div>
      <div style="background-color: #cbd5e1; border-radius: 4px; height: 6px; width: 100%; overflow: hidden;">
        <div style="background-color: #0d9488; height: 100%; width: $commitmentRate%;"></div>
      </div>
    </div>

    <div class="card">
      <div class="card-title">الدرجات والتحصيل العلمي</div>
      <div class="info-row"><span class="info-label">المجموع الكلي:</span><span class="info-value">$earned / $possible</span></div>
      <div class="info-row"><span class="info-label">النسبة المئوية العامة:</span><span class="info-value highlight">$pct%</span></div>
      <div style="background-color: #cbd5e1; border-radius: 4px; height: 6px; width: 100%; overflow: hidden; margin-bottom: 8px;">
        <div style="background-color: #4f46e5; height: 100%; width: $pct%;"></div>
      </div>
      <div class="info-row" style="border-top:1px dashed #cbd5e1; padding-top:4px;"><span class="info-label">الترتيب داخل المجموعة:</span><span class="info-value" style="color: #4f46e5; font-weight: bold;">$groupRank</span></div>
      <div class="info-row"><span class="info-label">الترتيب على الصف الدراسي:</span><span class="info-value" style="color: #4f46e5; font-weight: bold;">$gradeRank</span></div>
    </div>
  </div>

  <div class="section-title">تفاصيل درجات الطالب</div>
  <table>
    <thead>
      <tr>
        <th>التقييم / الاختبار</th>
        <th style="text-align:center;">الدرجة / النهاية</th>
        <th style="text-align:center;">النسبة</th>
        <th style="text-align:center;">التاريخ</th>
      </tr>
    </thead>
    <tbody>
      $gradesRows
    </tbody>
  </table>

  <div class="section-title">ملاحظات وتوجيهات المعلم</div>
  <div class="card" style="min-height: 80px;">
    $notes
  </div>

  <div class="footer">
    <p>تم استخراج هذا التقرير تلقائياً عبر تطبيق مستر بيست (Mr. Best) لإدارة الطلاب.</p>
  </div>
</body>
</html>
''';

    // Layout and print report
    final pdfBytes = await Printing.convertHtml(
      html: htmlContent,
      format: PdfPageFormat.a4,
    );

    // Save PDF in temporary directory to share
    final directory = await getTemporaryDirectory();
    final pdfPath = '${directory.path}/تقرير_الطالب_${name.replaceAll(' ', '_')}.pdf';
    final file = File(pdfPath);
    await file.writeAsBytes(pdfBytes);

    // Share PDF
    await Share.shareXFiles(
      [XFile(pdfPath)],
      text: 'تقرير الأداء الدراسي للطالب: $name في مادة الرياضيات',
    );
  }
}
