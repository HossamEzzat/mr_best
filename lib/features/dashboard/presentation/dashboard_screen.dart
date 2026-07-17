import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../groups/data/group_repository.dart';
import '../../students/data/student_repository.dart';
import '../../../core/database/database_helper.dart';

// FutureProvider for dashboard stats
final dashboardStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return await DatabaseHelper.instance.queryDashboardStats();
});

// FutureProvider for top students overall
final topStudentsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return await DatabaseHelper.instance.queryTopStudents(limit: 5);
});

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  void _refreshDashboard() {
    ref.invalidate(dashboardStatsProvider);
    ref.invalidate(topStudentsProvider);
    ref.invalidate(groupsListProvider);
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final topStudentsAsync = ref.watch(topStudentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة التحكم الرئيسية'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshDashboard,
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: RefreshIndicator(
          onRefresh: () async => _refreshDashboard(),
          child: statsAsync.when(
            data: (stats) {
              final totalStudents = stats['total_students'] as int;
              final totalGroups = stats['total_groups'] as int;
              final attToday = stats['attendance_today'] as Map<String, int>;
              final presentToday = attToday['present'] ?? 0;
              final absentToday = attToday['absent'] ?? 0;
              final lateToday = attToday['late'] ?? 0;
              final bestStudent = stats['best_student'] as String;
              final groupAverages = stats['group_averages'] as List<Map<String, dynamic>>;

              return ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // Premium Gradient Welcome Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primaryDark, AppColors.primary],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          offset: Offset(0, 4),
                          blurRadius: 10,
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'أهلاً بك يا مستر،',
                          style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'متابعة أداء الطلاب بشغف ودقة 📐',
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Row 1: Students & Groups count
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'إجمالي الطلاب',
                          '$totalStudents',
                          Icons.people,
                          AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'إجمالي المجموعات',
                          '$totalGroups',
                          Icons.class_,
                          AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Row 2: Today's Attendance
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'حضور وغياب اليوم',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildAttendanceMiniCard('حاضر', '$presentToday', AppColors.present),
                              _buildAttendanceMiniCard('متأخر', '$lateToday', AppColors.late),
                              _buildAttendanceMiniCard('غائب', '$absentToday', AppColors.absent),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Row 3: Best Student Card
                  Card(
                    color: AppColors.primary.withOpacity(0.05),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.amber,
                        child: Icon(Icons.emoji_events, color: Colors.white),
                      ),
                      title: const Text(
                        'أفضل طالب حالياً (الأعلى نقاطاً)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
                      ),
                      subtitle: Text(
                        bestStudent,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryDark),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Group Performance Chart Card
                  if (groupAverages.isNotEmpty) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'متوسط درجات المجموعات (%)',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 16),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: groupAverages.length,
                              itemBuilder: (context, index) {
                                final item = groupAverages[index];
                                final groupName = item['group_name'] as String;
                                final avg = item['average'] as double;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(groupName, style: const TextStyle(fontWeight: FontWeight.w600)),
                                          Text('${avg.toStringAsFixed(1)}%', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: avg / 100,
                                          backgroundColor: Colors.grey[200],
                                          color: AppColors.primary,
                                          minHeight: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Leaderboard Panel
                  topStudentsAsync.when(
                    data: (leaderboard) {
                      if (leaderboard.isEmpty) return const SizedBox.shrink();
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'ترتيب الطلاب الأوائل (المراكز الـ 5 الأولى)',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 12),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: leaderboard.length,
                                itemBuilder: (context, index) {
                                  final student = leaderboard[index];
                                  final name = student['name'];
                                  final group = student['group_name'];
                                  final points = student['total_points'];
                                  final pct = (student['percentage'] as num?)?.toStringAsFixed(1) ?? '0';

                                  return ListTile(
                                    dense: true,
                                    leading: CircleAvatar(
                                      backgroundColor: index == 0
                                          ? Colors.amber
                                          : index == 1
                                              ? Colors.grey[400]
                                              : index == 2
                                                  ? Colors.orange[300]
                                                  : AppColors.primary.withOpacity(0.1),
                                      foregroundColor: index < 3 ? Colors.white : AppColors.primary,
                                      child: Text('${index + 1}'),
                                    ),
                                    title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    subtitle: Text(group),
                                    trailing: Text(
                                      '$points نقطة ($pct%)',
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                                    ),
                                    onTap: () => context.push('/students/profile/${student['id']}').then((_) => _refreshDashboard()),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (err, stack) => const SizedBox.shrink(),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('حدث خطأ أثناء تحميل الإحصائيات: $err')),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
            ),
            Text(
              title,
              style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceMiniCard(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }
}
