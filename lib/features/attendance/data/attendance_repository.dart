import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database_helper.dart';
import '../domain/session_model.dart';
import '../domain/attendance_model.dart';

class AttendanceRepository {
  final DatabaseHelper _dbHelper;

  AttendanceRepository(this._dbHelper);

  Future<List<SessionModel>> getSessionsByGroup(int groupId) async {
    final list = await _dbHelper.querySessionsByGroup(groupId);
    return list.map((json) => SessionModel.fromJson(json)).toList();
  }

  Future<int> addSession(SessionModel session) async {
    final row = session.toJson();
    row.remove('id');
    return await _dbHelper.insertSession(row);
  }

  Future<int> deleteSession(int sessionId) async {
    return await _dbHelper.deleteSession(sessionId);
  }

  Future<List<AttendanceModel>> getAttendanceBySession(int sessionId) async {
    final list = await _dbHelper.queryAttendanceBySession(sessionId);
    return list.map((json) => AttendanceModel.fromJson(json)).toList();
  }

  Future<List<Map<String, dynamic>>> getAttendanceByStudent(int studentId) async {
    return await _dbHelper.queryAttendanceByStudent(studentId);
  }

  Future<void> saveAttendance(int sessionId, List<Map<String, dynamic>> attendanceList) async {
    await _dbHelper.saveAttendance(sessionId, attendanceList);
  }

  // Helper method to retrieve students with their attendance status for a session (if already recorded)
  Future<List<Map<String, dynamic>>> getStudentsAttendanceForSession(int groupId, int sessionId) async {
    final db = await _dbHelper.database;
    return await db.rawQuery('''
      SELECT s.id as student_id, s.name as student_name, a.status
      FROM students s
      LEFT JOIN attendance a ON s.id = a.student_id AND a.session_id = ?
      WHERE s.group_id = ?
      ORDER BY s.name ASC
    ''', [sessionId, groupId]);
  }
}

// Riverpod Provider
final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return AttendanceRepository(DatabaseHelper.instance);
});

// A family provider to fetch sessions for a specific group
final groupSessionsProvider = FutureProvider.family<List<SessionModel>, int>((ref, groupId) async {
  final repo = ref.watch(attendanceRepositoryProvider);
  return await repo.getSessionsByGroup(groupId);
});
