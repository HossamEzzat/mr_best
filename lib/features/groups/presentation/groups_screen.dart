import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/group_repository.dart';
import '../domain/group_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive_layout.dart';

class GroupsScreen extends ConsumerWidget {
  const GroupsScreen({super.key});

  static const List<String> gradeLevels = [
    'الصف الأول الإعدادي',
    'الصف الثاني الإعدادي',
    'الصف الثالث الإعدادي',
    'الصف الأول الثانوي',
    'الصف الثاني الثانوي',
    'الصف الثالث الثانوي',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(groupsListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('المجموعات الدراسية'),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: groupsAsync.when(
          data: (groups) {
            if (groups.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.group_outlined, size: 80, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'لا توجد مجموعات حالياً',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text('اضغط على الزر في الأسفل لإضافة أول مجموعة', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              );
            }

            final crossAxisCount = ResponsiveLayout.getGridCrossAxisCount(context, mobile: 1, tablet: 2, desktop: 3);

            if (crossAxisCount > 1) {
              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2.4,
                ),
                itemCount: groups.length,
                itemBuilder: (context, index) {
                  return _buildGroupCard(context, ref, groups[index]);
                },
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: groups.length,
              itemBuilder: (context, index) {
                return _buildGroupCard(context, ref, groups[index]);
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('حدث خطأ: $err')),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showGroupDialog(context, ref),
        label: const Text('إضافة مجموعة'),
        icon: const Icon(Icons.add),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildGroupCard(BuildContext context, WidgetRef ref, Map<String, dynamic> group) {
    final id = group['id'] as int;
    final name = group['name'] as String;
    final gradeLevel = group['grade_level'] as String;
    final count = group['student_count'] as int;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              gradeLevel,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.people, size: 16, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(
                  '$count طالب',
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _showGroupDialog(context, ref, id: id, currentName: name, currentGrade: gradeLevel),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: AppColors.absent),
              onPressed: () => _showDeleteConfirmation(context, ref, id, name),
            ),
          ],
        ),
        onTap: () => context.push('/groups/$id'),
      ),
    );
  }

  void _showGroupDialog(
    BuildContext context,
    WidgetRef ref, {
    int? id,
    String? currentName,
    String? currentGrade,
  }) {
    final nameController = TextEditingController(text: currentName);
    String selectedGrade = currentGrade ?? gradeLevels.first;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: AlertDialog(
                title: Text(id == null ? 'إضافة مجموعة جديدة' : 'تعديل بيانات المجموعة'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        autofocus: true,
                        decoration: const InputDecoration(
                          labelText: 'اسم المجموعة',
                          hintText: 'مثال: مجموعة أ / الأحد والخميس',
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: selectedGrade,
                        decoration: const InputDecoration(
                          labelText: 'الصف الدراسي',
                        ),
                        items: gradeLevels.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          if (newValue != null) {
                            setState(() {
                              selectedGrade = newValue;
                            });
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
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(100, 45),
                    ),
                    onPressed: () async {
                      if (nameController.text.trim().isEmpty) {
                        return;
                      }

                      final repo = ref.read(groupRepositoryProvider);
                      if (id == null) {
                        await repo.addGroup(
                          GroupModel(
                            name: nameController.text.trim(),
                            gradeLevel: selectedGrade,
                            createdAt: DateTime.now().toIso8601String(),
                          ),
                        );
                      } else {
                        await repo.updateGroup(
                          GroupModel(
                            id: id,
                            name: nameController.text.trim(),
                            gradeLevel: selectedGrade,
                            createdAt: DateTime.now().toIso8601String(),
                          ),
                        );
                      }

                      ref.invalidate(groupsListProvider);
                      if (context.mounted) Navigator.pop(context);
                    },
                    child: const Text('حفظ'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, int id, String name) {
    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('حذف المجموعة'),
            content: Text('هل أنت متأكد من حذف المجموعة "$name"؟\n\nتنبيه: سيؤدي هذا لحذف كافة طلاب المجموعة وحضورهم ودرجاتهم بالكامل! ولا يمكن التراجع عن هذا الإجراء.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.absent,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  await ref.read(groupRepositoryProvider).deleteGroup(id);
                  ref.invalidate(groupsListProvider);
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
