import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/mood_model.dart';

class MoodService {
  final _client = Supabase.instance.client;

  // READ
  Future<List<MoodModel>> getMoods() async {
    final data = await _client
        .from('moods')
        .select()
        .order('created_at', ascending: false);
    return (data as List).map((e) => MoodModel.fromMap(e)).toList();
  }

  // CREATE
  Future<void> addMood(MoodModel mood) async {
    await _client.from('moods').insert(mood.toMap());
  }

  // UPDATE
  Future<void> updateMood(String id, String note) async {
    await _client.from('moods').update({'note': note}).eq('id', id);
  }

  // DELETE
  Future<void> deleteMood(String id) async {
    await _client.from('moods').delete().eq('id', id);
  }
}
