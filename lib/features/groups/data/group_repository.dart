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
    // Convert GroupModel to Map for DB insertion. Since we use json_serializable, we can use toJson().
    final row = group.toJson();
    row.remove('id'); // ID is autoincremented
    return await _dbHelper.insertGroup(row);
  }

  Future<int> updateGroup(GroupModel group) async {
    return await _dbHelper.updateGroup(group.toJson());
  }

  Future<int> deleteGroup(int id) async {
    return await _dbHelper.deleteGroup(id);
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
