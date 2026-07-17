import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive_layout.dart';
import '../data/student_repository.dart';
import '../../groups/data/group_repository.dart';

class StudentsSearchScreen extends ConsumerStatefulWidget {
  const StudentsSearchScreen({super.key});

  @override
  ConsumerState<StudentsSearchScreen> createState() => _StudentsSearchScreenState();
}

class _StudentsSearchScreenState extends ConsumerState<StudentsSearchScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _refreshList() {
    ref.invalidate(studentsSearchResultProvider);
    ref.invalidate(groupsListProvider);
  }

  @override
  Widget build(BuildContext context) {
    final searchResultAsync = ref.watch(studentsSearchResultProvider);
    final filter = ref.watch(studentSearchFilterProvider);
    final groupsListAsync = ref.watch(groupsListProvider);

    final gradeLevels = const [
      'الصف الأول الإعدادي',
      'الصف الثاني الإعدادي',
      'الصف الثالث الإعدادي',
      'الصف الأول الثانوي',
      'الصف الثاني الثانوي',
      'الصف الثالث الثانوي',
    ];

    final crossAxisCount = ResponsiveLayout.getGridCrossAxisCount(context, mobile: 1, tablet: 2, desktop: 3);

    return Scaffold(
      appBar: AppBar(
        title: const Text('البحث وإدارة الطلاب'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshList,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/students/add').then((_) => _refreshList()),
        label: const Text('طالب جديد'),
        icon: const Icon(Icons.person_add),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            // Search Input & Filters Box
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'ابحث عن طالب بالاسم أو رقم الهاتف...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                ref.read(studentSearchFilterProvider.notifier).state =
                                    filter.copyWith(query: '');
                              },
                            )
                          : null,
                    ),
                    onChanged: (val) {
                      ref.read(studentSearchFilterProvider.notifier).state =
                          filter.copyWith(query: val);
                    },
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: filter.gradeLevel,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            labelText: 'تصفية بالصف',
                          ),
                          items: [
                            const DropdownMenuItem<String>(value: '', child: Text('جميع الصفوف')),
                            ...gradeLevels.map((g) => DropdownMenuItem(value: g, child: Text(g))),
                          ],
                          onChanged: (val) {
                            ref.read(studentSearchFilterProvider.notifier).state =
                                filter.copyWith(
                              gradeLevel: val == '' ? null : val,
                              clearGrade: val == '',
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: groupsListAsync.maybeWhen(
                          data: (groups) {
                            return DropdownButtonFormField<int>(
                              value: filter.groupId,
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                labelText: 'تصفية بالمجموعة',
                              ),
                              items: [
                                const DropdownMenuItem<int>(value: -1, child: Text('جميع المجموعات')),
                                ...groups.map((g) => DropdownMenuItem(value: g['id'] as int, child: Text(g['name'] as String))),
                              ],
                              onChanged: (val) {
                                ref.read(studentSearchFilterProvider.notifier).state =
                                    filter.copyWith(
                                  groupId: val == -1 ? null : val,
                                  clearGroup: val == -1,
                                );
                              },
                            );
                          },
                          orElse: () => const SizedBox.shrink(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Search Results
            Expanded(
              child: searchResultAsync.when(
                data: (students) {
                  if (students.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 12),
                          const Text(
                            'لا توجد نتائج مطابقة لبحثك',
                            style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    );
                  }

                  if (crossAxisCount > 1) {
                    return GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 2.8,
                      ),
                      itemCount: students.length,
                      itemBuilder: (context, index) => _buildStudentCard(students[index]),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: students.length,
                    itemBuilder: (context, index) => _buildStudentCard(students[index]),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('حدث خطأ: $err')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student) {
    final id = student['id'] as int;
    final name = student['name'] as String;
    final phone = student['phone'] ?? 'لا يوجد هاتف';
    final groupName = student['group_name'] as String;
    final grade = student['grade_level'] as String;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: const Icon(Icons.person, color: AppColors.primary),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('$groupName • $grade • هاتف: $phone'),
        trailing: const Icon(Icons.arrow_back_ios, size: 14),
        onTap: () => context.push('/students/profile/$id').then((_) => _refreshList()),
      ),
    );
  }
}
