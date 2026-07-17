import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/attendance_repository.dart';
import '../../../core/theme/app_colors.dart';

class TakeAttendanceScreen extends ConsumerStatefulWidget {
  final int groupId;
  final int sessionId;

  const TakeAttendanceScreen({super.key, required this.groupId, required this.sessionId});

  @override
  ConsumerState<TakeAttendanceScreen> createState() => _TakeAttendanceScreenState();
}

class _TakeAttendanceScreenState extends ConsumerState<TakeAttendanceScreen> {
  List<Map<String, dynamic>> _studentsAttendance = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAttendance();
  }

  Future<void> _loadAttendance() async {
    try {
      final repo = ref.read(attendanceRepositoryProvider);
      final list = await repo.getStudentsAttendanceForSession(widget.groupId, widget.sessionId);
      
      setState(() {
        // Map elements to mutable list of maps
        _studentsAttendance = list.map((item) {
          final m = Map<String, dynamic>.from(item);
          // Set default status to 'حاضر' if it is null (first time taking attendance)
          m['status'] = m['status'] ?? 'حاضر';
          return m;
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في تحميل الحضور: $e'), backgroundColor: AppColors.absent),
      );
    }
  }

  void _setStatus(int index, String status) {
    setState(() {
      _studentsAttendance[index]['status'] = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تسجيل الحضور والغياب'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveAttendance,
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _studentsAttendance.isEmpty
                ? const Center(child: Text('لا يوجد طلاب في هذه المجموعة لتسجيل حضورهم.'))
                : Column(
                    children: [
                      // Quick action header to mark all present/absent
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('إجراء سريع لجميع الطلاب:', style: TextStyle(fontWeight: FontWeight.bold)),
                            Row(
                              children: [
                                TextButton.icon(
                                  onPressed: () => _setAllStatus('حاضر'),
                                  icon: const Icon(Icons.check_circle_outline, color: AppColors.present, size: 18),
                                  label: const Text('حاضر', style: TextStyle(color: AppColors.present)),
                                ),
                                TextButton.icon(
                                  onPressed: () => _setAllStatus('غائب'),
                                  icon: const Icon(Icons.highlight_off, color: AppColors.absent, size: 18),
                                  label: const Text('غائب', style: TextStyle(color: AppColors.absent)),
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
                          itemCount: _studentsAttendance.length,
                          itemBuilder: (context, index) {
                            final record = _studentsAttendance[index];
                            final name = record['student_name'] as String;
                            final currentStatus = record['status'] as String;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        name,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        _buildStatusButton('حاضر', currentStatus == 'حاضر', () => _setStatus(index, 'حاضر')),
                                        const SizedBox(width: 6),
                                        _buildStatusButton('متأخر', currentStatus == 'متأخر', () => _setStatus(index, 'متأخر')),
                                        const SizedBox(width: 6),
                                        _buildStatusButton('غائب', currentStatus == 'غائب', () => _setStatus(index, 'غائب')),
                                      ],
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
                          onPressed: _saveAttendance,
                          child: const Text('حفظ سجل الحضور والغياب'),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildStatusButton(String status, bool isSelected, VoidCallback onTap) {
    Color activeColor;
    Color activeTextColor = Colors.white;
    switch (status) {
      case 'حاضر':
        activeColor = AppColors.present;
        break;
      case 'متأخر':
        activeColor = AppColors.late;
        break;
      case 'غائب':
      default:
        activeColor = AppColors.absent;
        break;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? activeColor : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Text(
          status,
          style: TextStyle(
            color: isSelected ? activeTextColor : Colors.grey[700],
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  void _setAllStatus(String status) {
    setState(() {
      for (var record in _studentsAttendance) {
        record['status'] = status;
      }
    });
  }

  Future<void> _saveAttendance() async {
    final repo = ref.read(attendanceRepositoryProvider);
    try {
      final list = _studentsAttendance.map((item) => {
        'student_id': item['student_id'],
        'status': item['status'],
      }).toList();

      await repo.saveAttendance(widget.sessionId, list);
      
      // Invalidate attendance providers to refresh the details screen
      ref.invalidate(groupSessionsProvider(widget.groupId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حفظ كشف الحضور بنجاح'), backgroundColor: AppColors.present),
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
