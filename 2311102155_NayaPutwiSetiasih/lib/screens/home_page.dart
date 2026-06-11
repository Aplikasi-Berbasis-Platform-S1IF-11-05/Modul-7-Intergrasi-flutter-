// NIM: 2311102155
// Nama: Naya Putwi Setiasih
// Modul 7 - Integrasi Flutter Firebase/Supabase (Notes App CRUD)
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../services/notification_service.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _firebaseService = AppFirebaseService();

  void _showNoteDialog({String? docId, String? initialTitle, String? initialContent}) {
    final titleController = TextEditingController(text: initialTitle);
    final contentController = TextEditingController(text: initialContent);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            docId == null ? 'Tambah Catatan' : 'Edit Catatan',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Judul',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.title),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: contentController,
                  decoration: InputDecoration(
                    labelText: 'Isi Catatan',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 4,
                ),
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                final title = titleController.text.trim();
                final content = contentController.text.trim();

                if (title.isEmpty || content.isEmpty) return;

                Navigator.pop(dialogContext);

                try {
                  if (docId == null) {
                    await _firebaseService.addNote(title, content);
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(content: Text('Catatan berhasil ditambahkan!')),
                    );
                    NotificationService().showNotification(
                      id: 1,
                      title: 'Tambah Catatan',
                      body: 'Catatan "$title" berhasil ditambahkan!',
                    );
                  } else {
                    await _firebaseService.updateNote(docId, title, content);
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(content: Text('Catatan berhasil diperbarui!')),
                    );
                    NotificationService().showNotification(
                      id: 2,
                      title: 'Edit Catatan',
                      body: 'Catatan "$title" berhasil diperbarui!',
                    );
                  }
                } catch (e) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(content: Text('Terjadi kesalahan: ${e.toString()}')),
                  );
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _deleteNote(String docId) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Hapus Catatan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Yakin ingin menghapus catatan ini?'),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await _firebaseService.deleteNote(docId);
                scaffoldMessenger.showSnackBar(
                  const SnackBar(content: Text('Catatan berhasil dihapus!')),
                );
                NotificationService().showNotification(
                  id: 3,
                  title: 'Hapus Catatan',
                  body: 'Catatan berhasil dihapus!',
                );
              } catch (e) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(content: Text('Terjadi kesalahan: ${e.toString()}')),
                );
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _logout() async {
    await _firebaseService.logout();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Dashboard', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text(
              'NIM: 2311102155 | Naya Putwi Setiasih',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: Colors.pink.shade100,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firebaseService.getNotesStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Terjadi kesalahan:\n${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final data = snapshot.data;
                if (data == null || data.docs.isEmpty) {
                  return const Center(
                    child: Text('Belum ada catatan. Tekan + untuk menambahkan.'),
                  );
                }

                return ListView.builder(
                  itemCount: data.docs.length,
                  itemBuilder: (context, index) {
                    final note = data.docs[index];
                    final docId = note.id;
                    final title = note['title'] as String;
                    final content = note['content'] as String;

                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(content),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showNoteDialog(
                                docId: docId,
                                initialTitle: title,
                                initialContent: content,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteNote(docId),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNoteDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
