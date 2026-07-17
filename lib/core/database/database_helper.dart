import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('mr_best.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getApplicationDocumentsDirectory();
    final path = join(dbPath.path, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onOpen: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const textNullableType = 'TEXT';
    const integerType = 'INTEGER NOT NULL';
    const realType = 'REAL NOT NULL';

    // 1. Groups Table
    await db.execute('''
      CREATE TABLE groups (
        id $idType,
        name $textType,
        grade_level $textType,
        created_at $textType
      )
    ''');

    // 2. Students Table
    await db.execute('''
      CREATE TABLE students (
        id $idType,
        group_id $integerType,
        name $textType,
        phone $textNullableType,
        parent_name $textNullableType,
        parent_phone $textNullableType,
        school $textNullableType,
        notes $textNullableType,
        created_at $textType,
        FOREIGN KEY (group_id) REFERENCES groups (id) ON DELETE CASCADE
      )
    ''');

    // 3. Sessions Table (for attendance dates)
    await db.execute('''
      CREATE TABLE sessions (
        id $idType,
        group_id $integerType,
        session_date $textType,
        title $textNullableType,
        created_at $textType,
        FOREIGN KEY (group_id) REFERENCES groups (id) ON DELETE CASCADE
      )
    ''');

    // 4. Attendance Table
    await db.execute('''
      CREATE TABLE attendance (
        id $idType,
        student_id $integerType,
        session_id $integerType,
        status $textType, -- 'حاضر', 'غائب', 'متأخر'
        created_at $textType,
        FOREIGN KEY (student_id) REFERENCES students (id) ON DELETE CASCADE,
        FOREIGN KEY (session_id) REFERENCES sessions (id) ON DELETE CASCADE
      )
    ''');

    // 5. Tasks Table (exams, quizzes, homeworks)
    await db.execute('''
      CREATE TABLE tasks (
        id $idType,
        group_id $integerType,
        title $textType,
        category $textType, -- 'الامتحان الشهري', 'التقييم الأسبوعي', 'اختبار الدرس', 'الواجب', 'امتحان نصف الترم', 'درجة المدرسة'
        total_score $realType,
        task_date $textType,
        created_at $textType,
        FOREIGN KEY (group_id) REFERENCES groups (id) ON DELETE CASCADE
      )
    ''');

    // 6. Grades Table
    await db.execute('''
      CREATE TABLE grades (
        id $idType,
        student_id $integerType,
        task_id $integerType,
        score $realType,
        created_at $textType,
        FOREIGN KEY (student_id) REFERENCES students (id) ON DELETE CASCADE,
        FOREIGN KEY (task_id) REFERENCES tasks (id) ON DELETE CASCADE
      )
    ''');
  }

  // --- CRUD Operations for GROUPS ---

  Future<int> insertGroup(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('groups', row);
  }

  Future<List<Map<String, dynamic>>> queryAllGroups() async {
    final db = await instance.database;
    return await db.query('groups', orderBy: 'name ASC');
  }

  Future<Map<String, dynamic>?> queryGroup(int id) async {
    final db = await instance.database;
    final results = await db.query('groups', where: 'id = ?', whereArgs: [id]);
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> updateGroup(Map<String, dynamic> row) async {
    final db = await instance.database;
    final id = row['id'];
    return await db.update('groups', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteGroup(int id) async {
    final db = await instance.database;
    return await db.delete('groups', where: 'id = ?', whereArgs: [id]);
  }

  // --- CRUD Operations for STUDENTS ---

  Future<int> insertStudent(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('students', row);
  }

  Future<List<Map<String, dynamic>>> queryStudentsByGroup(int groupId) async {
    final db = await instance.database;
    return await db.query('students', where: 'group_id = ?', whereArgs: [groupId], orderBy: 'name ASC');
  }

  Future<List<Map<String, dynamic>>> queryAllStudents() async {
    final db = await instance.database;
    return await db.query('students', orderBy: 'name ASC');
  }

  Future<Map<String, dynamic>?> queryStudent(int id) async {
    final db = await instance.database;
    final results = await db.query('students', where: 'id = ?', whereArgs: [id]);
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> updateStudent(Map<String, dynamic> row) async {
    final db = await instance.database;
    final id = row['id'];
    return await db.update('students', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteStudent(int id) async {
    final db = await instance.database;
    return await db.delete('students', where: 'id = ?', whereArgs: [id]);
  }

  // --- CRUD Operations for SESSIONS (Attendance sessions) ---

  Future<int> insertSession(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('sessions', row);
  }

  Future<List<Map<String, dynamic>>> querySessionsByGroup(int groupId) async {
    final db = await instance.database;
    return await db.query('sessions', where: 'group_id = ?', whereArgs: [groupId], orderBy: 'session_date DESC');
  }

  Future<int> deleteSession(int sessionId) async {
    final db = await instance.database;
    return await db.delete('sessions', where: 'id = ?', whereArgs: [sessionId]);
  }

  // --- CRUD Operations for ATTENDANCE ---

  Future<void> saveAttendance(int sessionId, List<Map<String, dynamic>> attendanceList) async {
    final db = await instance.database;
    await db.transaction((txn) async {
      for (final att in attendanceList) {
        // Check if attendance already exists for this student and session
        final existing = await txn.query(
          'attendance',
          where: 'student_id = ? AND session_id = ?',
          whereArgs: [att['student_id'], sessionId],
        );
        if (existing.isNotEmpty) {
          await txn.update(
            'attendance',
            {
              'status': att['status'],
              'created_at': DateTime.now().toIso8601String(),
            },
            where: 'student_id = ? AND session_id = ?',
            whereArgs: [att['student_id'], sessionId],
          );
        } else {
          await txn.insert('attendance', {
            'student_id': att['student_id'],
            'session_id': sessionId,
            'status': att['status'],
            'created_at': DateTime.now().toIso8601String(),
          });
        }
      }
    });
  }

  Future<List<Map<String, dynamic>>> queryAttendanceBySession(int sessionId) async {
    final db = await instance.database;
    return await db.query('attendance', where: 'session_id = ?', whereArgs: [sessionId]);
  }

  Future<List<Map<String, dynamic>>> queryAttendanceByStudent(int studentId) async {
    final db = await instance.database;
    return await db.rawQuery('''
      SELECT a.*, s.session_date, s.title as session_title
      FROM attendance a
      JOIN sessions s ON a.session_id = s.id
      WHERE a.student_id = ?
      ORDER BY s.session_date DESC
    ''', [studentId]);
  }

  // --- CRUD Operations for TASKS (Exams/Homeworks) ---

  Future<int> insertTask(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('tasks', row);
  }

  Future<List<Map<String, dynamic>>> queryTasksByGroup(int groupId) async {
    final db = await instance.database;
    return await db.query('tasks', where: 'group_id = ?', whereArgs: [groupId], orderBy: 'task_date DESC');
  }

  Future<int> deleteTask(int taskId) async {
    final db = await instance.database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [taskId]);
  }

  // --- CRUD Operations for GRADES ---

  Future<void> saveGrades(int taskId, List<Map<String, dynamic>> gradesList) async {
    final db = await instance.database;
    await db.transaction((txn) async {
      for (final gr in gradesList) {
        final existing = await txn.query(
          'grades',
          where: 'student_id = ? AND task_id = ?',
          whereArgs: [gr['student_id'], taskId],
        );
        if (existing.isNotEmpty) {
          await txn.update(
            'grades',
            {
              'score': gr['score'],
              'created_at': DateTime.now().toIso8601String(),
            },
            where: 'student_id = ? AND task_id = ?',
            whereArgs: [gr['student_id'], taskId],
          );
        } else {
          await txn.insert('grades', {
            'student_id': gr['student_id'],
            'task_id': taskId,
            'score': gr['score'],
            'created_at': DateTime.now().toIso8601String(),
          });
        }
      }
    });
  }

  Future<List<Map<String, dynamic>>> queryGradesByTask(int taskId) async {
    final db = await instance.database;
    return await db.query('grades', where: 'task_id = ?', whereArgs: [taskId]);
  }

  Future<List<Map<String, dynamic>>> queryGradesByStudent(int studentId) async {
    final db = await instance.database;
    return await db.rawQuery('''
      SELECT g.*, t.title as task_title, t.category as task_category, t.total_score as task_total_score, t.task_date
      FROM grades g
      JOIN tasks t ON g.task_id = t.id
      WHERE g.student_id = ?
      ORDER BY t.task_date DESC
    ''', [studentId]);
  }

  // --- Statistics & Analytical Queries ---

  // Dashboard Stats
  Future<Map<String, dynamic>> queryDashboardStats() async {
    final db = await instance.database;

    final studentsCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM students')) ?? 0;
    final groupsCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM groups')) ?? 0;

    // Attendance today (present / absent / late)
    final todayStr = DateTime.now().toIso8601String().substring(0, 10); // YYYY-MM-DD
    final attendanceToday = await db.rawQuery('''
      SELECT status, COUNT(*) as count 
      FROM attendance 
      WHERE DATE(created_at) = DATE('now')
      GROUP BY status
    ''');
    
    int presentToday = 0;
    int absentToday = 0;
    int lateToday = 0;

    for (final row in attendanceToday) {
      if (row['status'] == 'حاضر') presentToday = row['count'] as int;
      if (row['status'] == 'غائب') absentToday = row['count'] as int;
      if (row['status'] == 'متأخر') lateToday = row['count'] as int;
    }

    // Best student (overall points: sum of scores)
    final bestStudentRow = await db.rawQuery('''
      SELECT s.name as student_name, g.name as group_name, SUM(gr.score) as total_points
      FROM students s
      JOIN groups g ON s.group_id = g.id
      JOIN grades gr ON s.id = gr.student_id
      GROUP BY s.id
      ORDER BY total_points DESC
      LIMIT 1
    ''');

    String bestStudent = 'لا يوجد حالياً';
    if (bestStudentRow.isNotEmpty) {
      final name = bestStudentRow.first['student_name'];
      final gName = bestStudentRow.first['group_name'];
      final points = bestStudentRow.first['total_points'];
      bestStudent = '$name ($gName) - $points نقطة';
    }

    // Average grade percentage for each group
    final groupAverages = await db.rawQuery('''
      SELECT g.id, g.name, AVG(gr.score / t.total_score) * 100 as avg_pct
      FROM groups g
      JOIN tasks t ON g.id = t.group_id
      JOIN grades gr ON t.id = gr.task_id
      GROUP BY g.id
    ''');

    final List<Map<String, dynamic>> groupAveragesList = groupAverages.map((row) => {
      'group_name': row['name'],
      'average': (row['avg_pct'] as num?)?.toDouble() ?? 0.0,
    }).toList();

    return {
      'total_students': studentsCount,
      'total_groups': groupsCount,
      'attendance_today': {
        'present': presentToday,
        'absent': absentToday,
        'late': lateToday,
      },
      'best_student': bestStudent,
      'group_averages': groupAveragesList,
    };
  }

  // Get Top Students overall and in groups
  Future<List<Map<String, dynamic>>> queryTopStudents({int? groupId, String? gradeLevel, int limit = 5}) async {
    final db = await instance.database;
    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (groupId != null) {
      whereClause = 'WHERE s.group_id = ?';
      whereArgs = [groupId];
    } else if (gradeLevel != null) {
      whereClause = 'WHERE g.grade_level = ?';
      whereArgs = [gradeLevel];
    }

    return await db.rawQuery('''
      SELECT s.id, s.name, s.group_id, g.name as group_name, g.grade_level, SUM(gr.score) as total_points,
             AVG(gr.score / t.total_score) * 100 as percentage
      FROM students s
      JOIN groups g ON s.group_id = g.id
      JOIN grades gr ON s.id = gr.student_id
      JOIN tasks t ON gr.task_id = t.id
      $whereClause
      GROUP BY s.id
      ORDER BY total_points DESC
      LIMIT ?
    ''', [...whereArgs, limit]);
  }

  // Calculate Student rankings
  // 1. Group rank
  // 2. Grade level rank
  Future<Map<String, int>> queryStudentRanks(int studentId, int groupId, String gradeLevel) async {
    final db = await instance.database;

    // Get all students in the group with their points
    final groupRankings = await db.rawQuery('''
      SELECT s.id, SUM(COALESCE(gr.score, 0)) as total_points
      FROM students s
      LEFT JOIN grades gr ON s.id = gr.student_id
      WHERE s.group_id = ?
      GROUP BY s.id
      ORDER BY total_points DESC
    ''', [groupId]);

    // Get all students in same grade level
    final gradeRankings = await db.rawQuery('''
      SELECT s.id, SUM(COALESCE(gr.score, 0)) as total_points
      FROM students s
      JOIN groups g ON s.group_id = g.id
      LEFT JOIN grades gr ON s.id = gr.student_id
      WHERE g.grade_level = ?
      GROUP BY s.id
      ORDER BY total_points DESC
    ''', [gradeLevel]);

    int groupRank = 1;
    for (int i = 0; i < groupRankings.length; i++) {
      if (groupRankings[i]['id'] == studentId) {
        groupRank = i + 1;
        break;
      }
    }

    int gradeRank = 1;
    for (int i = 0; i < gradeRankings.length; i++) {
      if (gradeRankings[i]['id'] == studentId) {
        gradeRank = i + 1;
        break;
      }
    }

    return {
      'group_rank': groupRank,
      'grade_rank': gradeRank,
    };
  }

  // Backup and Restore Database
  Future<File> backupDatabase() async {
    final dbPath = await getApplicationDocumentsDirectory();
    final path = join(dbPath.path, 'mr_best.db');
    final dbFile = File(path);

    // Using documents or support dir to ensure write access
    final backupDir = await getApplicationSupportDirectory();
    final backupPath = join(backupDir.path, 'mr_best_backup.db');
    
    return await dbFile.copy(backupPath);
  }

  Future<void> restoreDatabase(File backupFile) async {
    final dbPath = await getApplicationDocumentsDirectory();
    final path = join(dbPath.path, 'mr_best.db');

    // Close database first if active
    if (_database != null) {
      await _database!.close();
      _database = null;
    }

    await backupFile.copy(path);
  }
}
