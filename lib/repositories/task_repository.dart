import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';

class TaskRepository {
  final DatabaseHelper _databaseHelper;

  TaskRepository(this._databaseHelper);

  // Display all tasks
  Future<List<Map<String, dynamic>>> getTasks() async {
    final Database db = await _databaseHelper.database;

    return db.query(
      'tasks',
      orderBy: 'id DESC',
    );
  }

  // Add a new task
  Future<int> addTask(String title) async {
    final Database db = await _databaseHelper.database;

    return db.insert('tasks', {
      'title': title,
      'completed': 0,
    });
  }

  // Mark a task as completed or not completed
  Future<int> updateCompleted(
    int id,
    bool completed,
  ) async {
    final Database db = await _databaseHelper.database;

    return db.update(
      'tasks',
      {
        'completed': completed ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete a task
  Future<int> deleteTask(int id) async {
    final Database db = await _databaseHelper.database;

    return db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}