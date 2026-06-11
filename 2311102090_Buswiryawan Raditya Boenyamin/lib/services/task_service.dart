// 2311102090-Buswiryawan Raditya Boenyamin
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import 'notification_service.dart';
import 'auth_service.dart';

class TaskService {
  static final TaskService _instance = TaskService._internal();

  factory TaskService() {
    return _instance;
  }

  TaskService._internal();

  final _supabase = Supabase.instance.client;
  final _authService = AuthService();
  final _notificationService = NotificationService();
  static const String _tableName = 'tasks';

  // CREATE - Tambah task baru
  Future<Task?> createTask({
    required String title,
    required String description,
  }) async {
    try {
      final userId = _authService.userId;
      if (userId == null) throw Exception('User tidak terautentikasi');

      final taskId = const Uuid().v4();
      final now = DateTime.now();

      final task = Task(
        id: taskId,
        userId: userId,
        title: title,
        description: description,
        isCompleted: false,
        createdAt: now,
        updatedAt: now,
      );

      // Gunakan .select() untuk memastikan data berhasil di-insert dan didapat kembali
      await _supabase.from(_tableName).insert(task.toMap()).select();
      
      await _notificationService.showTaskCreatedNotification(title);
      return task;
    } catch (e) {
      await _notificationService.showErrorNotification(
        'Gagal membuat task: ${e.toString()}',
      );
      rethrow;
    }
  }

  // READ - Ambil semua task user
  Future<List<Task>> getAllTasks() async {
    try {
      final userId = _authService.userId;
      if (userId == null) throw Exception('User tidak terautentikasi');

      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final tasks = (response as List)
          .map((task) => Task.fromMap(task as Map<String, dynamic>))
          .toList();

      return tasks;
    } catch (e) {
      await _notificationService.showErrorNotification(
        'Gagal memuat task: ${e.toString()}',
      );
      rethrow;
    }
  }

  // READ (Stream) - Real-time update tasks
  Stream<List<Task>> getTasksStream() {
    final userId = _authService.userId;
    if (userId == null) {
      throw Exception('User tidak terautentikasi');
    }

    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map((data) {
          return data
              .map((task) => Task.fromMap(task))
              .toList();
        });
  }

  // UPDATE - Perbarui task
  Future<Task?> updateTask({
    required String taskId,
    required String title,
    required String description,
    required bool isCompleted,
  }) async {
    try {
      final userId = _authService.userId;
      if (userId == null) throw Exception('User tidak terautentikasi');

      final now = DateTime.now();

      await _supabase
          .from(_tableName)
          .update({
            'title': title,
            'description': description,
            'is_completed': isCompleted,
            'updated_at': now.toIso8601String(),
          })
          .eq('id', taskId)
          .eq('user_id', userId);

      await _notificationService.showTaskUpdatedNotification(title);

      // Fetch dan return updated task
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('id', taskId)
          .eq('user_id', userId)
          .single();

      return Task.fromMap(response);
    } catch (e) {
      await _notificationService.showErrorNotification(
        'Gagal update task: ${e.toString()}',
      );
      rethrow;
    }
  }

  // UPDATE - Toggle task completion
  Future<void> toggleTaskCompletion({
    required String taskId,
    required bool currentStatus,
    required String taskTitle,
  }) async {
    try {
      final userId = _authService.userId;
      if (userId == null) throw Exception('User tidak terautentikasi');

      final newStatus = !currentStatus;

      await _supabase
          .from(_tableName)
          .update({
            'is_completed': newStatus,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', taskId)
          .eq('user_id', userId);

      if (newStatus) {
        await _notificationService.showTaskCompletedNotification(taskTitle);
      } else {
        await _notificationService.showTaskUpdatedNotification(taskTitle);
      }
    } catch (e) {
      await _notificationService.showErrorNotification(
        'Gagal update status task: ${e.toString()}',
      );
      rethrow;
    }
  }

  // DELETE - Hapus task
  Future<bool> deleteTask({
    required String taskId,
    required String taskTitle,
  }) async {
    try {
      final userId = _authService.userId;
      if (userId == null) throw Exception('User tidak terautentikasi');

      await _supabase
          .from(_tableName)
          .delete()
          .eq('id', taskId)
          .eq('user_id', userId)
          .select(); // Ensure the operation triggers a realtime update

      await _notificationService.showTaskDeletedNotification(taskTitle);
      return true;
    } catch (e) {
      await _notificationService.showErrorNotification(
        'Gagal hapus task: ${e.toString()}',
      );
      rethrow;
    }
  }

  // Get task statistics
  Future<Map<String, int>> getTaskStats() async {
    try {
      final userId = _authService.userId;
      if (userId == null) throw Exception('User tidak terautentikasi');

      final allTasks = await getAllTasks();
      final completedTasks =
          allTasks.where((task) => task.isCompleted).length;

      return {
        'total': allTasks.length,
        'completed': completedTasks,
        'pending': allTasks.length - completedTasks,
      };
    } catch (e) {
      return {'total': 0, 'completed': 0, 'pending': 0};
    }
  }
}
