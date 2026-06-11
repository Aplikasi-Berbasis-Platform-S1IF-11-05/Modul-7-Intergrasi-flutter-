import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task_model.dart';
import 'database_service.dart';

class SupabaseDatabaseService implements DatabaseService {
  final _supabase = Supabase.instance.client;

  @override
  Future<List<Task>> getTasks(String userId) async {
    try {
      final response = await _supabase
          .from('tasks')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      
      return (response as List).map((taskJson) => Task.fromJson(taskJson)).toList();
    } catch (e) {
      throw Exception('Gagal memuat tugas dari Supabase: $e');
    }
  }

  @override
  Future<Task> createTask(Task task) async {
    try {
      final response = await _supabase
          .from('tasks')
          .insert(task.toJson())
          .select()
          .single();
      
      return Task.fromJson(response);
    } catch (e) {
      throw Exception('Gagal membuat tugas di Supabase: $e');
    }
  }

  @override
  Future<Task> updateTask(Task task) async {
    try {
      final response = await _supabase
          .from('tasks')
          .update(task.toJson())
          .eq('id', task.id)
          .select()
          .single();
      
      return Task.fromJson(response);
    } catch (e) {
      throw Exception('Gagal memperbarui tugas di Supabase: $e');
    }
  }

  @override
  Future<void> deleteTask(String taskId) async {
    try {
      await _supabase.from('tasks').delete().eq('id', taskId);
    } catch (e) {
      throw Exception('Gagal menghapus tugas di Supabase: $e');
    }
  }
}
