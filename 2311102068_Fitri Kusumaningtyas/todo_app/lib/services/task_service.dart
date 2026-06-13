import 'package:supabase_flutter/supabase_flutter.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final bool isDone;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.isDone,
  });

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'] ?? '',
      isDone: map['is_done'] ?? false,
    );
  }
}

class TaskService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Task>> getTasks() async {
    final userId = _client.auth.currentUser!.id;
    final response = await _client
        .from('tasks')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List).map((e) => Task.fromMap(e)).toList();
  }

  Future<void> addTask(String title, String description) async {
    final userId = _client.auth.currentUser!.id;
    await _client.from('tasks').insert({
      'user_id': userId,
      'title': title,
      'description': description,
      'is_done': false,
    });
  }

  Future<void> updateTask(String id, String title, String description) async {
    await _client.from('tasks').update({
      'title': title,
      'description': description,
    }).eq('id', id);
  }

  Future<void> toggleDone(String id, bool isDone) async {
    await _client.from('tasks').update({'is_done': isDone}).eq('id', id);
  }

  Future<void> deleteTask(String id) async {
    await _client.from('tasks').delete().eq('id', id);
  }
}