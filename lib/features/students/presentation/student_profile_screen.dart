import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pdf/pdf.dart';
import '../data/student_repository.dart';
import '../../grades/data/grades_repository.dart';
import '../../attendance/data/attendance_repository.dart';
import '../../../core/utils/pdf_generator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../groups/presentation/group_details_screen.dart';

class StudentProfileScreen extends ConsumerStatefulWidget {
  final int studentId;

  const StudentProfileScreen({super.key, required this.studentId});

  @override
  ConsumerState<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends ConsumerState<StudentProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? _studentOverview;
  List<Map<String, dynamic>> _gradesList = [];
  List<Map<String, dynamic>> _attendanceList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final studentRepo = ref.read(studentRepositoryProvider);
      final gradesRepo = ref.read(gradesRepositoryProvider);
      final attendanceRepo = ref.read(attendanceRepositoryProvider);

      final overview = await studentRepo.getStudentOverview(widget.studentId);
      final grades = await gradesRepo.getGradesByStudent(widget.studentId);
      final attendance = await attendanceRepo.getAttendanceByStudent(widget.studentId);

      setState(() {
        _studentOverview = overview;
        _gradesList = grades;
        _attendanceList = attendance;
        _isLoading = false;
        if (overview != null) {
          // Additional initialization if needed
        }
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في تحميل ملف الطالب: $e'), backgroundColor: AppColors.absent),
      );
    }
  }


  void _openPdfPreview() {
    if (_studentOverview == null) return;
    final data = Map<String, dynamic>.from(_studentOverview!);
    data['grades_list'] = _gradesList;
    final name = data['name'] as String? ?? 'طالب';

    context.push(
      '/pdf/preview',
      extra: {
        'title': 'معاينة تقرير الطالب: $name',
        'fileName': 'تقرير_الطالب_${name.replaceAll(' ', '_')}.pdf',
        'buildPdf': (PdfPageFormat format) async => await PdfGenerator.generateStudentReportBytes(data),
      },
    );
  }

  Future<void> _shareDirectReport() async {
    if (_studentOverview == null) return;
    final data = Map<String, dynamic>.from(_studentOverview!);
    data['grades_list'] = _gradesList;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('جاري تجهيز التقرير للمشاركة...'), duration: Duration(seconds: 1)),
    );

    try {
      await PdfGenerator.generateAndShareStudentReport(data);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل مشاركة التقرير: $e'), backgroundColor: AppColors.absent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_studentOverview == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('خطأ')),
        body: const Center(child: Text('الطالب غير موجود')),
      );
    }

    final name = _studentOverview!['name'] as String;
    final groupName = _studentOverview!['group_name'] as String;
    final gradeLevel = _studentOverview!['grade_level'] as String;
    final school = _studentOverview!['school'] ?? 'المدرسة غير مسجلة';
    final phone = _studentOverview!['phone'] ?? 'لا يوجد هاتف';
    final parentName = _studentOverview!['parent_name'] ?? 'غير مسجل';
    final parentPhone = _studentOverview!['parent_phone'] ?? 'غير مسجل';

    // Stats
    final attStats = _studentOverview!['attendance_stats'] as Map<String, dynamic>;
    final commitmentRate = (attStats['rate'] as num).toDouble();
    final presentCount = attStats['present'] as int;
    final absentCount = attStats['absent'] as int;

    final gradeStats = _studentOverview!['grade_stats'] as Map<String, dynamic>;
    final earnedPoints = (gradeStats['earned_points'] as num).toDouble();
    final possiblePoints = (gradeStats['possible_points'] as num).toDouble();
    final gradePercentage = (gradeStats['percentage'] as num).toDouble();

    final ranks = Map<String, dynamic>.from(_studentOverview!['ranks'] as Map);
    final groupRank = ranks['group_rank'] ?? 1;
    final gradeRank = ranks['grade_rank'] ?? 1;

    final isWide = !ResponsiveLayout.isMobile(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'معاينة PDF',
            onPressed: _openPdfPreview,
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.blue),
            tooltip: 'مشاركة التقرير',
            onPressed: _shareDirectReport,
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'تعديل البيانات',
            onPressed: () => context.push('/students/edit/${widget.studentId}').then((_) => _loadData()),
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Responsive Row for Profile & Stats on wide screen
            if (isWide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: _buildProfileCard(name, groupName, gradeLevel, school, phone, parentName, parentPhone),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        _buildStatsCards(gradePercentage, earnedPoints, possiblePoints, commitmentRate, presentCount, absentCount),
                        const SizedBox(height: 12),
                        _buildRankWidget(groupRank, gradeRank),
                      ],
                    ),
                  ),
                ],
              )
            else ...[
              _buildProfileCard(name, groupName, gradeLevel, school, phone, parentName, parentPhone),
              const SizedBox(height: 12),
              _buildStatsCards(gradePercentage, earnedPoints, possiblePoints, commitmentRate, presentCount, absentCount),
              const SizedBox(height: 10),
              _buildRankWidget(groupRank, gradeRank),
            ],

            const SizedBox(height: 12),

            // PDF Action Bar Card
            Card(
              color: AppColors.primary.withOpacity(0.08),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: AppColors.primary,
                      child: Icon(Icons.picture_as_pdf, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('تقرير الطالب PDF', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          Text('استعراض مباشر مع إمكانية الطباعة والحفظ والمشاركة', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _openPdfPreview,
                      icon: const Icon(Icons.visibility, size: 18),
                      label: const Text('معاينة PDF'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(110, 40),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),
            const SizedBox(height: 16),

            // Tabs for Detailed Logs
            TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppColors.primary,
              tabs: const [
                Tab(text: 'سجل الدرجات'),
                Tab(text: 'سجل الحضور'),
              ],
            ),
            const SizedBox(height: 8),

            SizedBox(
              height: 350,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildGradesList(),
                  _buildAttendanceList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(String name, String groupName, String gradeLevel, String school, String phone, String parentName, String parentPhone) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: const Icon(Icons.person, size: 32, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                      Text('$groupName • $gradeLevel', style: TextStyle(color: Colors.grey[600])),
                      Text(school, style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildDetailRow(Icons.phone, 'رقم الطالب:', phone),
            _buildDetailRow(Icons.family_restroom, 'ولي الأمر:', '$parentName ($parentPhone)'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards(double gradePercentage, double earnedPoints, double possiblePoints, double commitmentRate, int presentCount, int absentCount) {
    return Row(
      children: [
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  const Text('الأداء الدراسي', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Text(
                    '${gradePercentage.toStringAsFixed(1)}%',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: AppColors.primary),
                  ),
                  const SizedBox(height: 4),
                  Text('$earnedPoints / $possiblePoints درجة', style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  const Text('نسبة الالتزام', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Text(
                    '${commitmentRate.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: commitmentRate > 80 ? AppColors.present : AppColors.late,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('$presentCount حضور • $absentCount غياب', style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRankWidget(dynamic groupRank, dynamic gradeRank) {
    return Card(
      color: AppColors.primary.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildRankItem('الترتيب في المجموعة', groupRank),
            Container(width: 1, height: 40, color: Colors.grey[300]),
            _buildRankItem('الترتيب على الصف', gradeRank),
          ],
        ),
      ),
    );
  }

  Widget _buildRankItem(String title, dynamic rank) {
    return Column(
      children: [
        Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emoji_events, color: Colors.amber, size: 20),
            const SizedBox(width: 4),
            Text(
              'المركز $rank',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 6),
          Expanded(child: Text(value, style: TextStyle(color: Colors.grey[800]))),
        ],
      ),
    );
  }

  Widget _buildGradesList() {
    if (_gradesList.isEmpty) {
      return const Center(child: Text('لا توجد درجات مسجلة لهذا الطالب.'));
    }

    return ListView.builder(
      itemCount: _gradesList.length,
      itemBuilder: (context, index) {
        final g = _gradesList[index];
        final title = g['task_title'] as String;
        final category = g['task_category'] as String;
        final score = (g['score'] as num).toDouble();
        final total = (g['task_total_score'] as num).toDouble();
        final date = g['task_date'] as String;

        return Card(
          margin: const EdgeInsets.only(bottom: 6),
          child: ListTile(
            dense: true,
            leading: Icon(Icons.assessment, color: AppColors.getCategoryColor(category), size: 20),
            title: Text('$title ($category)'),
            subtitle: Text(date),
            trailing: Text(
              '$score / $total',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAttendanceList() {
    if (_attendanceList.isEmpty) {
      return const Center(child: Text('لا يوجد سجل حضور لهذا الطالب.'));
    }

    return ListView.builder(
      itemCount: _attendanceList.length,
      itemBuilder: (context, index) {
        final a = _attendanceList[index];
        final title = a['session_title'] ?? 'محاضرة';
        final date = a['session_date'] as String;
        final status = a['status'] as String;

        Color badgeColor;
        switch (status) {
          case 'حاضر':
            badgeColor = AppColors.present;
            break;
          case 'متأخر':
            badgeColor = AppColors.late;
            break;
          case 'غائب':
          default:
            badgeColor = AppColors.absent;
            break;
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 6),
          child: ListTile(
            dense: true,
            leading: Icon(Icons.calendar_month, color: badgeColor, size: 20),
            title: Text(title),
            subtitle: Text(date),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: badgeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: badgeColor.withOpacity(0.5)),
              ),
              child: Text(
                status,
                style: TextStyle(color: badgeColor, fontWeight: FontWeight.bold, fontSize: 11),
              ),
            ),
          ),
        );
      },
    );
  }
}
