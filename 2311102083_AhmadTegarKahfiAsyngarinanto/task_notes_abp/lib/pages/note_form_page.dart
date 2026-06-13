import 'package:flutter/material.dart';
import '../models/note_model.dart';
import '../services/note_service.dart';
import '../services/notification_service.dart';

class NoteFormPage extends StatefulWidget {
  final NoteModel? note;

  const NoteFormPage({super.key, this.note});

  @override
  State<NoteFormPage> createState() => _NoteFormPageState();
}

class _NoteFormPageState extends State<NoteFormPage> {
  final NoteService noteService = NoteService();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  bool isLoading = false;

  bool get isEdit => widget.note != null;

  @override
  void initState() {
    super.initState();

    if (isEdit) {
      titleController.text = widget.note!.title;
      descriptionController.text = widget.note!.description;
    }
  }

  Future<void> saveNote() async {
    if (titleController.text.isEmpty || descriptionController.text.isEmpty) {
      showMessage('Judul dan deskripsi wajib diisi');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      if (isEdit) {
        await noteService.updateNote(
          id: widget.note!.id,
          title: titleController.text.trim(),
          description: descriptionController.text.trim(),
        );

        await NotificationService.showNotification(
          title: 'Data Diperbarui',
          body: 'Catatan berhasil diperbarui',
        );
      } else {
        await noteService.addNote(
          title: titleController.text.trim(),
          description: descriptionController.text.trim(),
        );

        await NotificationService.showNotification(
          title: 'Data Ditambahkan',
          body: 'Catatan berhasil ditambahkan',
        );
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      showMessage('Gagal menyimpan data: ${e.toString()}');
    }

    setState(() {
      isLoading = false;
    });
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Catatan' : 'Tambah Catatan')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Judul Tugas',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: descriptionController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Deskripsi Tugas',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : saveNote,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : Text(isEdit ? 'Update' : 'Simpan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
