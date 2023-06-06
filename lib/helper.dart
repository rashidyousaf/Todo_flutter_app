import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'models/sub_task.dart';
import 'models/task.dart';

class DatabaseHelper {
  static const String _tasksTable = 'tasks';
  static const String _subTasksTable = 'subtasks';
  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _database;

  DatabaseHelper._();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    } else {
      _database = await _initDatabase();
      return _database!;
    }
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'tasks.db');

    return await openDatabase(path, version: 1, onCreate: _createDatabase);
  }

  void _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tasksTable(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        isCompleted INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE $_subTasksTable(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        taskId INTEGER,
        title TEXT,
        isCompleted INTEGER,
        FOREIGN KEY(taskId) REFERENCES $_tasksTable(id) ON DELETE CASCADE
      )
    ''');
  }

  Future<int> insertTask(Task task) async {
    final db = await database;

    return await db.insert(_tasksTable, task.toMap());
  }

  Future<int> updateTask(Task task) async {
    final db = await database;

    return await db.update(_tasksTable, task.toMap(),
        where: 'id = ?', whereArgs: [task.id]);
  }

  Future<int> deleteTask(int id) async {
    final db = await database;

    return await db.delete(_tasksTable, where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<Task>> getTasks() async {
    final db = await DatabaseHelper.instance.database;
    final taskMaps = await db.query(_tasksTable);
    return taskMaps.map((taskMap) => Task.fromMap(taskMap)).toList();
  }

  Future<int> insertSubtask(Subtask subTask) async {
    final db = await database;

    return await db.insert(_subTasksTable, subTask.toMap());
  }

  Future<int> updateSubtask(Subtask subTask) async {
    final db = await database;

    return await db.update(_subTasksTable, subTask.toMap(),
        where: 'id = ?', whereArgs: [subTask.id]);
  }

  Future<int> deleteSubtask(int id) async {
    final db = await database;

    return await db.delete(_subTasksTable, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Subtask>> getSubtasks(int taskId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db
        .query(_subTasksTable, where: 'taskId = ?', whereArgs: [taskId]);
    return List.generate(maps.length, (i) {
      return Subtask.fromMap(maps[i]);
    });
  }

  Future<int> deleteTask2(int id) async {
    final db = await database;

    // Delete all related subtasks
    await db.delete(_subTasksTable, where: 'taskId = ?', whereArgs: [id]);

    // Delete the task
    return await db.delete(_tasksTable, where: 'id = ?', whereArgs: [id]);
  }
}
