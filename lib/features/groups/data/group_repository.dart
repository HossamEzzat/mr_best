import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database_helper.dart';
import '../domain/group_model.dart';

class GroupRepository {
  final DatabaseHelper _dbHelper;

  GroupRepository(this._dbHelper);

  Future<List<GroupModel>> getAllGroups() async {
    final list = await _dbHelper.queryAllGroups();
    return list.map((json) => GroupModel.fromJson(json)).toList();
  }

  // Returns group list with student count included
  Future<List<Map<String, dynamic>>> getGroupsWithCount() async {
    final db = await _dbHelper.database;
    return await db.rawQuery('''
      SELECT g.*, COUNT(s.id) as student_count
      FROM groups g
      LEFT JOIN students s ON g.id = s.group_id
      GROUP BY g.id
      ORDER BY g.name ASC
    ''');
  }

  Future<GroupModel?> getGroupById(int id) async {
    final json = await _dbHelper.queryGroup(id);
    if (json == null) return null;
    return GroupModel.fromJson(json);
  }

  Future<int> addGroup(GroupModel group) async {
    final row = group.toJson();
    row.remove('id');
    return await _dbHelper.insertGroup(row);
  }

  Future<int> updateGroup(GroupModel group) async {
    return await _dbHelper.updateGroup(group.toJson());
  }

  Future<int> deleteGroup(int id) async {
    return await _dbHelper.deleteGroup(id);
  }

  // Get complete group overview for PDF report export with student stats
  Future<Map<String, dynamic>> getGroupReportData(int groupId) async {
    final db = await _dbHelper.database;
    final groupMap = await _dbHelper.queryGroup(groupId);
    final String groupName = groupMap?['name'] ?? 'المجموعة';
    final String gradeLevel = groupMap?['grade_level'] ?? 'الصف';

    final students = await db.rawQuery('''
      SELECT s.*,
             (SELECT COUNT(*) FROM attendance WHERE student_id = s.id AND status IN ('حاضر', 'متأخر')) as present_count,
             (SELECT COUNT(*) FROM attendance WHERE student_id = s.id) as total_sessions,
             (SELECT SUM(score) FROM grades WHERE student_id = s.id) as total_earned,
             (SELECT SUM(t.total_score) FROM grades gr JOIN tasks t ON gr.task_id = t.id WHERE gr.student_id = s.id) as total_possible
      FROM students s
      WHERE s.group_id = ?
      ORDER BY s.name ASC
    ''', [groupId]);

    final List<Map<String, dynamic>> studentsWithStats = students.map((s) {
      final map = Map<String, dynamic>.from(s);
      final present = (map['present_count'] as num?)?.toInt() ?? 0;
      final totalSessions = (map['total_sessions'] as num?)?.toInt() ?? 0;
      final earned = (map['total_earned'] as num?)?.toDouble() ?? 0.0;
      final possible = (map['total_possible'] as num?)?.toDouble() ?? 0.0;

      final attRate = totalSessions > 0 ? (present / totalSessions) * 100 : 100.0;
      final gradePct = possible > 0 ? (earned / possible) * 100 : 0.0;

      map['attendance_rate'] = attRate;
      map['grade_percentage'] = gradePct;
      return map;
    }).toList();

    return {
      'name': groupName,
      'grade_level': gradeLevel,
      'students_list': studentsWithStats,
    };
  }
}

// Riverpod Provider
final groupRepositoryProvider = Provider<GroupRepository>((ref) {
  return GroupRepository(DatabaseHelper.instance);
});

// A FutureProvider for listing groups
final groupsListProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.watch(groupRepositoryProvider);
  return await repo.getGroupsWithCount();
});
