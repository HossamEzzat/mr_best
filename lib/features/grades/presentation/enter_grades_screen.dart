import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/grades_repository.dart';
import '../domain/task_model.dart';
import '../../../core/theme/app_colors.dart';

class EnterGradesScreen extends ConsumerStatefulWidget {
  final int groupId;
  final int taskId;

  const EnterGradesScreen({super.key, required this.groupId, required this.taskId});

  @override
  ConsumerState<EnterGradesScreen> createState() => _EnterGradesScreenState();
}

class _EnterGradesScreenState extends ConsumerState<EnterGradesScreen> {
  TaskModel? _task;
  List<Map<String, dynamic>> _studentsGrades = [];
  final Map<int, TextEditingController> _controllers = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final repo = ref.read(gradesRepositoryProvider);
      
      // Load task details
      final tasks = await repo.getTasksByGroup(widget.groupId);
      _task = tasks.firstWhere((t) => t.id == widget.taskId);

      // Load grades list
      final list = await repo.getStudentsGradesForTask(widget.groupId, widget.taskId);

      setState(() {
        _studentsGrades = list;
        for (final item in list) {
          final studentId = item['student_id'] as int;
          final score = item['score'] as num?;
          _controllers[studentId] = TextEditingController(
            text: score != null ? score.toString() : '',
          );
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في تحميل الدرجات: $e'), backgroundColor: AppColors.absent),
      );
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_task != null ? 'رصد درجات: ${_task!.title}' : 'رصد الدرجات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveGrades,
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _studentsGrades.isEmpty
                ? const Center(child: Text('لا يوجد طلاب في هذه المجموعة لرصد درجاتهم.'))
                : Column(
                    children: [
                      // Task Info Header
                      Container(
                        width: double.infinity,
                        color: AppColors.getCategoryColor(_task!.category).withOpacity(0.1),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'نوع التقييم: ${_task!.category}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'الدرجة النهائية: ${_task!.totalScore}',
                              style: TextStyle(
                                color: AppColors.getCategoryColor(_task!.category),
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Bulk fill quick action
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('رصد درجة موحدة للكل:', style: TextStyle(fontWeight: FontWeight.bold)),
                            Row(
                              children: [
                                SizedBox(
                                  width: 80,
                                  height: 40,
                                  child: TextField(
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      hintText: 'الدرجة',
                                    ),
                                    onSubmitted: (val) {
                                      final score = double.tryParse(val);
                                      if (score != null) _bulkSetScores(score);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                TextButton(
                                  onPressed: () => _bulkSetScores(_task!.totalScore),
                                  child: const Text('الدرجة النهائية كاملة'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),

                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _studentsGrades.length,
                          itemBuilder: (context, index) {
                            final record = _studentsGrades[index];
                            final studentId = record['student_id'] as int;
                            final name = record['student_name'] as String;
                            final controller = _controllers[studentId];

                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        name,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    SizedBox(
                                      width: 100,
                                      child: TextFormField(
                                        controller: controller,
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        textAlign: TextAlign.center,
                                        decoration: InputDecoration(
                                          hintText: '/ ${_task!.totalScore}',
                                          errorMaxLines: 1,
                                        ),
                                        validator: (val) {
                                          if (val == null || val.trim().isEmpty) return null;
                                          final numVal = double.tryParse(val);
                                          if (numVal == null) return 'خطأ';
                                          if (numVal < 0 || numVal > _task!.totalScore) return 'تجاوز';
                                          return null;
                                        },
                                        autovalidateMode: AutovalidateMode.onUserInteraction,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ElevatedButton(
                          onPressed: _saveGrades,
                          child: const Text('حفظ درجات الطلاب'),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  void _bulkSetScores(double score) {
    if (score < 0 || score > _task!.totalScore) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('الدرجة المدخلة يجب أن تكون بين 0 و ${_task!.totalScore}'),
          backgroundColor: AppColors.absent,
        ),
      );
      return;
    }
    setState(() {
      for (final controller in _controllers.values) {
        controller.text = score.toString();
      }
    });
  }

  Future<void> _saveGrades() async {
    // Validate all controllers first
    bool hasError = false;
    final list = <Map<String, dynamic>>[];

    for (final record in _studentsGrades) {
      final studentId = record['student_id'] as int;
      final text = _controllers[studentId]?.text.trim() ?? '';
      
      if (text.isNotEmpty) {
        final score = double.tryParse(text);
        if (score == null || score < 0 || score > _task!.totalScore) {
          hasError = true;
          break;
        }
        list.add({
          'student_id': studentId,
          'score': score,
        });
      } else {
        // Record 0 or don't record? Usually we can default absent/not graded to 0 or leave empty.
        // Let's assume we record it as 0, or just exclude it. The user requirements state "تسجيل درجات لكل طالب".
        // Let's default empty entries to 0 or exclude them from grades. Let's record them as 0 to count in points, or skip.
        // Skipping is safer. Let's write them as 0 to be explicit. Or let the teacher know.
        // Let's default to 0 if left empty. Or skip. Let's skip empty to allow partial grading.
        // "Skipping is safer" => Let's just not insert it, or if there's a grade, let's keep it.
        // Wait, if a grade already exists, leaving it blank shouldn't overwrite it, or should it delete it?
        // Let's write empty as 0.0 or just skip. Let's treat empty as skip.
      }
    }

    if (hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى تصحيح الدرجات الخاطئة قبل الحفظ (لا تتجاوز الدرجة النهائية)'),
          backgroundColor: AppColors.absent,
        ),
      );
      return;
    }

    final repo = ref.read(gradesRepositoryProvider);
    try {
      await repo.saveGrades(widget.taskId, list);
      ref.invalidate(groupTasksProvider(widget.groupId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حفظ الدرجات بنجاح'), backgroundColor: AppColors.present),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل الحفظ: $e'), backgroundColor: AppColors.absent),
        );
      }
    }
  }
}
