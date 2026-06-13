import '../models/task_model.dart';

abstract class DatabaseService {
  Future<List<Task>> getTasks(String userId);
  Future<Task> createTask(Task task);
  Future<Task> updateTask(Task task);
  Future<void> deleteTask(String taskId);
}
