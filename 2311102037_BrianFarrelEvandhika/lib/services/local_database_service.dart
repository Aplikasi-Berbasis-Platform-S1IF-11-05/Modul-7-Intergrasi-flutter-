import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_model.dart';
import 'database_service.dart';

class LocalDatabaseService implements DatabaseService {
  static const String _tasksKey = 'local_tasks_key';

  Future<List<Task>> _getLocalTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksString = prefs.getString(_tasksKey);
    if (tasksString == null) return [];
    
    final List<dynamic> decoded = jsonDecode(tasksString);
    return decoded.map((item) => Task.fromJson(item)).toList();
  }

  Future<void> _saveLocalTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(tasks.map((task) => task.toMap()).toList());
    await prefs.setString(_tasksKey, encoded);
  }

  @override
  Future<List<Task>> getTasks(String userId) async {
    // Return mock local tasks for user
    final tasks = await _getLocalTasks();
    return tasks.where((task) => task.userId == userId).toList();
  }

  @override
  Future<Task> createTask(Task task) async {
    final tasks = await _getLocalTasks();
    
    // Generate a unique ID if not already set
    final newTask = task.copyWith(
      id: task.id.isEmpty ? DateTime.now().microsecondsSinceEpoch.toString() : task.id,
      createdAt: DateTime.now(),
    );
    
    tasks.add(newTask);
    await _saveLocalTasks(tasks);
    return newTask;
  }

  @override
  Future<Task> updateTask(Task task) async {
    final tasks = await _getLocalTasks();
    final index = tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      tasks[index] = task;
      await _saveLocalTasks(tasks);
      return task;
    }
    throw Exception('Tugas tidak ditemukan secara lokal');
  }

  @override
  Future<void> deleteTask(String taskId) async {
    final tasks = await _getLocalTasks();
    tasks.removeWhere((t) => t.id == taskId);
    await _saveLocalTasks(tasks);
  }
}
