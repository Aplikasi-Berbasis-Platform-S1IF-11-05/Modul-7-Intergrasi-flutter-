import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'notification_service.dart';

class FormScreen extends StatefulWidget {
  final Map<String, dynamic>? item;
  const FormScreen({super.key, this.item});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _taskController = TextEditingController();
  final _courseController = TextEditingController();
  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _taskController.text = widget.item!['task_name'];
      _courseController.text = widget.item!['course_name'];
    }
  }

  Future<void> _saveData() async {
    final userId = _supabase.auth.currentUser!.id;
    final task = _taskController.text;
    final course = _courseController.text;

    if (widget.item == null) {
      await _supabase.from('tasks').insert({
        'user_id': userId,
        'task_name': task,
        'course_name': course,
      });
      NotificationService.showNotification(
        title: 'Tugas Ditambahkan', 
        body: 'Semangat mengerjakan $task!'
      );
    } else {
      await _supabase.from('tasks').update({
        'task_name': task,
        'course_name': course,
      }).eq('id', widget.item!['id']);
      NotificationService.showNotification(
        title: 'Tugas Diperbarui', 
        body: 'Detail tugas $task berhasil diubah.'
      );
    }
    
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        title: Text(widget.item == null ? 'Tambah Tugas' : 'Edit Tugas', style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _taskController, 
              decoration: InputDecoration(
                labelText: 'Nama Tugas',
                hintText: 'Contoh: Laporan Modul 7...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              )
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _courseController, 
              decoration: InputDecoration(
                labelText: 'Mata Kuliah',
                hintText: 'Contoh: Pemrograman Mobile...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              )
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                ),
                onPressed: _saveData, 
                child: const Text('Simpan Tugas', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}