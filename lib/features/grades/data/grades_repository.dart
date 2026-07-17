import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database_helper.dart';
import '../domain/task_model.dart';
import '../domain/grade_model.dart';

class GradesRepository {
  final DatabaseHelper _dbHelper;

  GradesRepository(this._dbHelper);

  Future<List<TaskModel>> getTasksByGroup(int groupId) async {
    final list = await _dbHelper.queryTasksByGroup(groupId);
    return list.map((json) => TaskModel.fromJson(json)).toList();
  }

  Future<int> addTask(TaskModel task) async {
    final row = task.toJson();
    row.remove('id');
    return await _dbHelper.insertTask(row);
  }

  Future<int> deleteTask(int taskId) async {
    return await _dbHelper.deleteTask(taskId);
  }

  Future<List<GradeModel>> getGradesByTask(int taskId) async {
    final list = await _dbHelper.queryGradesByTask(taskId);
    return list.map((json) => GradeModel.fromJson(json)).toList();
  }

  Future<List<Map<String, dynamic>>> getGradesByStudent(int studentId) async {
    return await _dbHelper.queryGradesByStudent(studentId);
  }

  Future<void> saveGrades(int taskId, List<Map<String, dynamic>> gradesList) async {
    await _dbHelper.saveGrades(taskId, gradesList);
  }

  // Get students with their grade scores for a specific task
  Future<List<Map<String, dynamic>>> getStudentsGradesForTask(int groupId, int taskId) async {
    final db = await _dbHelper.database;
    return await db.rawQuery('''
      SELECT s.id as student_id, s.name as student_name, g.score
      FROM students s
      LEFT JOIN grades g ON s.id = g.student_id AND g.task_id = ?
      WHERE s.group_id = ?
      ORDER BY s.name ASC
    ''', [taskId, groupId]);
  }
}

// Riverpod Provider
final gradesRepositoryProvider = Provider<GradesRepository>((ref) {
  return GradesRepository(DatabaseHelper.instance);
});

// A family provider to fetch tasks for a specific group
final groupTasksProvider = FutureProvider.family<List<TaskModel>, int>((ref, groupId) async {
  final repo = ref.watch(gradesRepositoryProvider);
  return await repo.getTasksByGroup(groupId);
});
