import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../data/group_repository.dart';
import '../../students/data/student_repository.dart';
import '../../attendance/data/attendance_repository.dart';
import '../../grades/data/grades_repository.dart';
import '../../attendance/domain/session_model.dart';
import '../../grades/domain/task_model.dart';
import '../../../core/theme/app_colors.dart';

// Additional provider for students of this group
final groupStudentsProvider = FutureProvider.family<List<Map<String, dynamic>>, int>((ref, groupId) async {
  final repo = ref.watch(studentRepositoryProvider);
  return await repo.searchAndFilterStudents(groupId: groupId);
});

class GroupDetailsScreen extends ConsumerStatefulWidget {
  final int groupId;

  const GroupDetailsScreen({super.key, required this.groupId});

  @override
  ConsumerState<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends ConsumerState<GroupDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groupAsync = ref.watch(groupsListProvider);

    // Find our specific group to display title
    final groupName = groupAsync.maybeWhen(
      data: (list) {
        final g = list.firstWhere((element) => element['id'] == widget.groupId, orElse: () => <String, dynamic>{});
        return g['name'] as String? ?? 'تفاصيل المجموعة';
      },
      orElse: () => 'تفاصيل المجموعة',
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(groupName),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'الطلاب', icon: Icon(Icons.people)),
            Tab(text: 'الحضور والغياب', icon: Icon(Icons.calendar_month)),
            Tab(text: 'الدرجات والتقييمات', icon: Icon(Icons.grade)),
          ],
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildStudentsTab(),
            _buildAttendanceTab(),
            _buildGradesTab(),
          ],
        ),
      ),
    );
  }

  // --- 1. STUDENTS TAB ---
  Widget _buildStudentsTab() {
    final studentsAsync = ref.watch(groupStudentsProvider(widget.groupId));

    return studentsAsync.when(
      data: (students) {
        if (students.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_outline, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                const Text(
                  'لا يوجد طلاب في هذه المجموعة حالياً',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => context.push('/students/add?groupId=${widget.groupId}'),
                  icon: const Icon(Icons.person_add),
                  label: const Text('إضافة طالب جديد'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(200, 45),
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          floatingActionButton: FloatingActionButton(
            heroTag: 'add_student_btn',
            onPressed: () => context.push('/students/add?groupId=${widget.groupId}'),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            child: const Icon(Icons.person_add),
          ),
          body: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              final id = student['id'] as int;
              final name = student['name'] as String;
              final phone = student['phone'] as String? ?? '';
              final school = student['school'] as String? ?? '';

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('$school ${phone.isNotEmpty ? "• $phone" : ""}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                        onPressed: () => context.push('/students/edit/$id'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: AppColors.absent, size: 20),
                        onPressed: () => _confirmDeleteStudent(id, name),
                      ),
                    ],
                  ),
                  onTap: () => context.push('/students/profile/$id'),
                ),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('حدث خطأ: $err')),
    );
  }

  void _confirmDeleteStudent(int id, String name) {
    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('حذف الطالب'),
            content: Text('هل أنت متأكد من حذف الطالب "$name"؟\n\nتنبيه: سيتم حذف درجات الطالب وسجل حضوره وغيابه بالكامل!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.absent, foregroundColor: Colors.white),
                onPressed: () async {
                  await ref.read(studentRepositoryProvider).deleteStudent(id);
                  ref.invalidate(groupStudentsProvider(widget.groupId));
                  ref.invalidate(groupsListProvider); // Updates dashboard/group stats
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('حذف'),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- 2. ATTENDANCE TAB ---
  Widget _buildAttendanceTab() {
    final sessionsAsync = ref.watch(groupSessionsProvider(widget.groupId));

    return sessionsAsync.when(
      data: (sessions) {
        return Scaffold(
          floatingActionButton: FloatingActionButton.extended(
            heroTag: 'add_session_btn',
            onPressed: () => _showAddSessionDialog(),
            label: const Text('جلسة حضور جديدة'),
            icon: const Icon(Icons.add_task),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          body: sessions.isEmpty
              ? const Center(
                  child: Text(
                    'لا توجد جلسات حضور مسجلة حالياً',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: sessions.length,
                  itemBuilder: (context, index) {
                    final session = sessions[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: AppColors.tealOffset,
                          child: Icon(Icons.calendar_month, color: AppColors.present),
                        ),
                        title: Text(session.title ?? 'جلسة حضور', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(session.sessionDate),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.delete, color: AppColors.absent, size: 20),
                              onPressed: () => _confirmDeleteSession(session.id!, session.title ?? 'هذه الجلسة'),
                            ),
                            const Icon(Icons.arrow_back_ios, size: 14), // RTL arrow
                          ],
                        ),
                        onTap: () => context.push('/attendance/take/${widget.groupId}/${session.id}'),
                      ),
                    );
                  },
                ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('حدث خطأ: $err')),
    );
  }

  void _showAddSessionDialog() {
    final titleController = TextEditingController(text: 'محاضرة ${DateFormat('yyyy-MM-dd').format(DateTime.now())}');
    final dateController = TextEditingController(text: DateFormat('yyyy-MM-dd').format(DateTime.now()));

    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('جلسة حضور جديدة'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'عنوان الجلسة'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: dateController,
                  decoration: const InputDecoration(labelText: 'التاريخ (YYYY-MM-DD)'),
                  readOnly: true,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      dateController.text = DateFormat('yyyy-MM-dd').format(picked);
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (titleController.text.trim().isEmpty) return;

                  final repo = ref.read(attendanceRepositoryProvider);
                  final sessionId = await repo.addSession(
                    SessionModel(
                      groupId: widget.groupId,
                      sessionDate: dateController.text,
                      title: titleController.text.trim(),
                      createdAt: DateTime.now().toIso8601String(),
                    ),
                  );

                  ref.invalidate(groupSessionsProvider(widget.groupId));
                  if (context.mounted) {
                    Navigator.pop(context);
                    context.push('/attendance/take/${widget.groupId}/$sessionId');
                  }
                },
                child: const Text('حفظ وتسجيل الحضور'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDeleteSession(int sessionId, String title) {
    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('حذف جلسة الحضور'),
            content: Text('هل أنت متأكد من حذف "$title"؟\n\nتنبيه: سيؤدي هذا لحذف سجل حضور وغياب هذه الجلسة لكافة الطلاب!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.absent, foregroundColor: Colors.white),
                onPressed: () async {
                  await ref.read(attendanceRepositoryProvider).deleteSession(sessionId);
                  ref.invalidate(groupSessionsProvider(widget.groupId));
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('حذف'),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- 3. GRADES TAB ---
  Widget _buildGradesTab() {
    final tasksAsync = ref.watch(groupTasksProvider(widget.groupId));

    return tasksAsync.when(
      data: (tasks) {
        return Scaffold(
          floatingActionButton: FloatingActionButton.extended(
            heroTag: 'add_task_btn',
            onPressed: () => _showAddTaskDialog(),
            label: const Text('تقييم / اختبار جديد'),
            icon: const Icon(Icons.assignment),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          body: tasks.isEmpty
              ? const Center(
                  child: Text(
                    'لا توجد امتحانات أو واجبات مسجلة حالياً',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.getCategoryColor(task.category).withOpacity(0.2),
                          child: Icon(Icons.assessment, color: AppColors.getCategoryColor(task.category)),
                        ),
                        title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${task.category} • الدرجة النهائية: ${task.totalScore}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.delete, color: AppColors.absent, size: 20),
                              onPressed: () => _confirmDeleteTask(task.id!, task.title),
                            ),
                            const Icon(Icons.arrow_back_ios, size: 14),
                          ],
                        ),
                        onTap: () => context.push('/grades/take/${widget.groupId}/${task.id}'),
                      ),
                    );
                  },
                ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('حدث خطأ: $err')),
    );
  }

  void _showAddTaskDialog() {
    final titleController = TextEditingController();
    final scoreController = TextEditingController(text: '10');
    final dateController = TextEditingController(text: DateFormat('yyyy-MM-dd').format(DateTime.now()));
    
    final categories = [
      'الامتحان الشهري',
      'التقييم الأسبوعي',
      'اختبار الدرس',
      'الواجب',
      'امتحان نصف الترم',
      'درجة المدرسة',
    ];
    String selectedCategory = categories.first;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: AlertDialog(
                title: const Text('تقييم جديد'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        value: selectedCategory,
                        decoration: const InputDecoration(labelText: 'نوع التقييم'),
                        items: categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => selectedCategory = val);
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'عنوان التقييم',
                          hintText: 'مثال: واجب الدرس الأول / امتحان الجبر',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: scoreController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(labelText: 'الدرجة النهائية'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: dateController,
                        decoration: const InputDecoration(labelText: 'التاريخ'),
                        readOnly: true,
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            dateController.text = DateFormat('yyyy-MM-dd').format(picked);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('إلغاء'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (titleController.text.trim().isEmpty) return;
                      final totalScore = double.tryParse(scoreController.text) ?? 10.0;

                      final repo = ref.read(gradesRepositoryProvider);
                      final taskId = await repo.addTask(
                        TaskModel(
                          groupId: widget.groupId,
                          title: titleController.text.trim(),
                          category: selectedCategory,
                          totalScore: totalScore,
                          taskDate: dateController.text,
                          createdAt: DateTime.now().toIso8601String(),
                        ),
                      );

                      ref.invalidate(groupTasksProvider(widget.groupId));
                      if (context.mounted) {
                        Navigator.pop(context);
                        context.push('/grades/take/${widget.groupId}/$taskId');
                      }
                    },
                    child: const Text('حفظ ورصد الدرجات'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDeleteTask(int taskId, String title) {
    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('حذف التقييم'),
            content: Text('هل أنت متأكد من حذف التقييم "$title"؟\n\nتنبيه: سيؤدي هذا لحذف درجات هذا التقييم لكافة الطلاب!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.absent, foregroundColor: Colors.white),
                onPressed: () async {
                  await ref.read(gradesRepositoryProvider).deleteTask(taskId);
                  ref.invalidate(groupTasksProvider(widget.groupId));
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('حذف'),
              ),
            ],
          ),
        );
      },
    );
  }
}
