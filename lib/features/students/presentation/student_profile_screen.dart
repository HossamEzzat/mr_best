import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/student_repository.dart';
import '../../grades/data/grades_repository.dart';
import '../../attendance/data/attendance_repository.dart';
import '../../../core/utils/pdf_generator.dart';
import '../../../core/theme/app_colors.dart';
import '../../groups/presentation/group_details_screen.dart'; // to invalidate students list if deleted

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
  final _notesController = TextEditingController();
  bool _isSavingNotes = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _notesController.dispose();
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
          _notesController.text = overview['notes'] ?? '';
        }
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في تحميل ملف الطالب: $e'), backgroundColor: AppColors.absent),
      );
    }
  }

  Future<void> _saveNotes() async {
    if (_studentOverview == null) return;
    setState(() => _isSavingNotes = true);

    try {
      final repo = ref.read(studentRepositoryProvider);
      final studentData = await repo.getStudentById(widget.studentId);
      if (studentData != null) {
        final updatedStudent = studentData.copyWith(
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        );
        await repo.updateStudent(updatedStudent);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حفظ الملاحظات بنجاح'), backgroundColor: AppColors.present),
        );
        
        // Refresh overview locally
        _studentOverview!['notes'] = updatedStudent.notes;
        ref.invalidate(groupStudentsProvider(_studentOverview!['group_id'] as int));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل حفظ الملاحظات: $e'), backgroundColor: AppColors.absent),
      );
    } finally {
      setState(() => _isSavingNotes = false);
    }
  }

  Future<void> _generateReport() async {
    if (_studentOverview == null) return;
    
    // Add additional info needed by PdfGenerator
    final data = Map<String, dynamic>.from(_studentOverview!);
    data['grades_list'] = _gradesList;
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('جاري إعداد تقرير PDF...'), duration: Duration(seconds: 1)),
    );

    try {
      await PdfGenerator.generateAndShareStudentReport(data);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل توليد التقرير: $e'), backgroundColor: AppColors.absent),
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
    final commitmentRate = attStats['rate'] as double;
    final presentCount = attStats['present'] as int;
    final absentCount = attStats['absent'] as int;

    final gradeStats = _studentOverview!['grade_stats'] as Map<String, dynamic>;
    final earnedPoints = gradeStats['earned_points'] as double;
    final possiblePoints = gradeStats['possible_points'] as double;
    final gradePercentage = gradeStats['percentage'] as double;

    final ranks = _studentOverview!['ranks'] as Map<String, int>;
    final groupRank = ranks['group_rank'] ?? 1;
    final gradeRank = ranks['grade_rank'] ?? 1;

    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push('/students/edit/${widget.studentId}').then((_) => _loadData()),
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.blue),
            onPressed: _generateReport,
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            // Student Profile Header & Statistics Cards
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // Profile Card
                  Card(
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
                  ),
                  const SizedBox(height: 12),

                  // Stats Panel
                  Row(
                    children: [
                      // Grades Stats Card
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
                      // Attendance Stats Card
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
                  ),
                  const SizedBox(height: 10),

                  // Ranks Panel
                  Card(
                    color: AppColors.primary.withOpacity(0.05),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildRankWidget('الترتيب في المجموعة', groupRank),
                          Container(width: 1, height: 40, color: Colors.grey[300]),
                          _buildRankWidget('الترتيب على الصف', gradeRank),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Notes section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('ملاحظات وتوجيهات المعلم:', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _notesController,
                            maxLines: 2,
                            decoration: const InputDecoration(
                              hintText: 'اكتب ملاحظاتك عن مستوى الطالب هنا...',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(120, 36),
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                              ),
                              onPressed: _isSavingNotes ? null : _saveNotes,
                              child: _isSavingNotes
                                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : const Text('حفظ الملاحظة', style: TextStyle(fontSize: 12)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
                    height: 300,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildGradesList(),
                        _buildAttendanceList(),
                      ],
                    ),
                  )
                ],
              ),
            ),
            
            // PDF report button at bottom
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: _generateReport,
                icon: const Icon(Icons.share),
                label: const Text('إرسال تقرير الأداء لولي الأمر عبر واتساب'),
              ),
            ),
          ],
        ),
      ),
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

  Widget _buildRankWidget(String title, int rank) {
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

  Widget _buildGradesList() {
    if (_gradesList.isEmpty) {
      return const Center(child: Text('لا توجد درجات مسجلة لهذا الطالب.'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _gradesList.length,
      itemBuilder: (context, index) {
        final g = _gradesList[index];
        final title = g['task_title'] as String;
        final category = g['task_category'] as String;
        final score = g['score'] as double;
        final total = g['task_total_score'] as double;
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
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
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
