import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../core/database/database_helper.dart';
import '../domain/student_model.dart';

class StudentRepository {
  final DatabaseHelper _dbHelper;

  StudentRepository(this._dbHelper);

  Future<List<StudentModel>> getStudentsByGroup(int groupId) async {
    final list = await _dbHelper.queryStudentsByGroup(groupId);
    return list.map((json) => StudentModel.fromJson(json)).toList();
  }

  Future<StudentModel?> getStudentById(int id) async {
    final json = await _dbHelper.queryStudent(id);
    if (json == null) return null;
    return StudentModel.fromJson(json);
  }

  Future<int> addStudent(StudentModel student) async {
    final row = student.toJson();
    row.remove('id');
    return await _dbHelper.insertStudent(row);
  }

  Future<int> updateStudent(StudentModel student) async {
    return await _dbHelper.updateStudent(student.toJson());
  }

  Future<int> deleteStudent(int id) async {
    return await _dbHelper.deleteStudent(id);
  }

  // Custom Search & Filter query returning list of students with group names
  Future<List<Map<String, dynamic>>> searchAndFilterStudents({
    String query = '',
    int? groupId,
    String? gradeLevel,
  }) async {
    final db = await _dbHelper.database;
    String sql = '''
      SELECT s.*, g.name as group_name, g.grade_level
      FROM students s
      JOIN groups g ON s.group_id = g.id
      WHERE 1=1
    ''';
    List<dynamic> args = [];

    if (query.isNotEmpty) {
      sql += " AND (s.name LIKE ? OR s.phone LIKE ? OR s.parent_phone LIKE ?)";
      args.addAll(['%$query%', '%$query%', '%$query%']);
    }

    if (groupId != null) {
      sql += " AND s.group_id = ?";
      args.add(groupId);
    }

    if (gradeLevel != null && gradeLevel.isNotEmpty) {
      sql += " AND g.grade_level = ?";
      args.add(gradeLevel);
    }

    sql += " ORDER BY s.name ASC";
    return await db.rawQuery(sql, args);
  }

  // Get student detail overview including statistics
  Future<Map<String, dynamic>?> getStudentOverview(int studentId) async {
    final db = await _dbHelper.database;
    final studentList = await db.rawQuery('''
      SELECT s.*, g.name as group_name, g.grade_level
      FROM students s
      JOIN groups g ON s.group_id = g.id
      WHERE s.id = ?
    ''', [studentId]);

    if (studentList.isEmpty) return null;
    final studentData = Map<String, dynamic>.from(studentList.first);

    // 1. Attendance statistics
    final attRows = await db.rawQuery('''
      SELECT status, COUNT(*) as count
      FROM attendance
      WHERE student_id = ?
      GROUP BY status
    ''', [studentId]);

    int presentCount = 0;
    int absentCount = 0;
    int lateCount = 0;

    for (final row in attRows) {
      if (row['status'] == 'حاضر') presentCount = row['count'] as int;
      if (row['status'] == 'غائب') absentCount = row['count'] as int;
      if (row['status'] == 'متأخر') lateCount = row['count'] as int;
    }

    int totalSessions = presentCount + absentCount + lateCount;
    double commitmentRate = totalSessions > 0
        ? ((presentCount + lateCount) / totalSessions) * 100
        : 100.0; // Assume 100% if no sessions yet

    // 2. Grades statistics
    final gradesRows = await db.rawQuery('''
      SELECT SUM(g.score) as total_score, SUM(t.total_score) as total_possible
      FROM grades g
      JOIN tasks t ON g.task_id = t.id
      WHERE g.student_id = ?
    ''', [studentId]);

    double earnedPoints = 0.0;
    double possiblePoints = 0.0;

    if (gradesRows.isNotEmpty && gradesRows.first['total_score'] != null) {
      earnedPoints = (gradesRows.first['total_score'] as num).toDouble();
      possiblePoints = (gradesRows.first['total_possible'] as num).toDouble();
    }

    double gradePercentage = possiblePoints > 0
        ? (earnedPoints / possiblePoints) * 100
        : 0.0;

    // 3. Ranks
    final ranks = await _dbHelper.queryStudentRanks(
      studentId,
      studentData['group_id'] as int,
      studentData['grade_level'] as String,
    );

    studentData['attendance_stats'] = {
      'present': presentCount,
      'absent': absentCount,
      'late': lateCount,
      'total': totalSessions,
      'rate': commitmentRate,
    };

    studentData['grade_stats'] = {
      'earned_points': earnedPoints,
      'possible_points': possiblePoints,
      'percentage': gradePercentage,
    };

    studentData['ranks'] = ranks;

    return studentData;
  }
}

// Riverpod Provider
final studentRepositoryProvider = Provider<StudentRepository>((ref) {
  return StudentRepository(DatabaseHelper.instance);
});

// A StateProvider or StateNotifierProvider for student search filters
class StudentSearchFilter {
  final String query;
  final int? groupId;
  final String? gradeLevel;

  StudentSearchFilter({this.query = '', this.groupId, this.gradeLevel});

  StudentSearchFilter copyWith({
    String? query,
    int? groupId,
    String? gradeLevel,
    bool clearGroup = false,
    bool clearGrade = false,
  }) {
    return StudentSearchFilter(
      query: query ?? this.query,
      groupId: clearGroup ? null : (groupId ?? this.groupId),
      gradeLevel: clearGrade ? null : (gradeLevel ?? this.gradeLevel),
    );
  }
}

final studentSearchFilterProvider = StateProvider<StudentSearchFilter>((ref) => StudentSearchFilter());

// FutureProvider that watches the filters and returns student search results
final studentsSearchResultProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.watch(studentRepositoryProvider);
  final filter = ref.watch(studentSearchFilterProvider);
  return await repo.searchAndFilterStudents(
    query: filter.query,
    groupId: filter.groupId,
    gradeLevel: filter.gradeLevel,
  );
});
