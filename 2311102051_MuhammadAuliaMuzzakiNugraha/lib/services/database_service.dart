/// NIM: 2311102051
/// Nama: Muhammad Aulia Muzzaki Nugraha
/// Kelas: Praktikum Aplikasi Berbasis Platform

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task_model.dart';

class DatabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // READ: Realtime Stream of tasks for a specific user
  Stream<List<Task>> getTasksStream(String userId) {
    return _client
        .from('tasks')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('due_date', ascending: true)
        .map((listOfMaps) =>
            listOfMaps.map((map) => Task.fromJson(map)).toList());
  }

  // READ: One-off Future fetch of tasks (useful fallback if real-time stream is not configured on Supabase)
  Future<List<Task>> getTasks(String userId) async {
    try {
      final response = await _client
          .from('tasks')
          .select()
          .eq('user_id', userId)
          .order('due_date', ascending: true);
      
      final List<dynamic> data = response as List<dynamic>;
      return data.map((map) => Task.fromJson(map as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // CREATE: Add new task
  Future<Task> createTask(Task task) async {
    try {
      final response = await _client
          .from('tasks')
          .insert(task.toJson())
          .select()
          .single();
      
      return Task.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // UPDATE: Edit task details or toggle status
  Future<Task> updateTask(Task task) async {
    if (task.id == null) {
      throw Exception("Task ID cannot be null for updates");
    }
    try {
      final response = await _client
          .from('tasks')
          .update(task.toJson())
          .eq('id', task.id!)
          .select()
          .single();
      
      return Task.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // DELETE: Remove task
  Future<void> deleteTask(String taskId) async {
    try {
      await _client
          .from('tasks')
          .delete()
          .eq('id', taskId);
    } catch (e) {
      rethrow;
    }
  }
}
