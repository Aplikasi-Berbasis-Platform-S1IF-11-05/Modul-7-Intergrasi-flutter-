// 2311102119 - Megan Sulthon Aryomukti

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://jvgnuhlmcxewfvvrktjy.supabase.co',
    publishableKey: 'sb_publishable_2h4mNlZ51_sDHUhkMAVRpg_0VmNMawP',
  );

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Session? session;
  late final StreamSubscription<AuthState> authSubscription;

  @override
  void initState() {
    super.initState();

    session = supabase.auth.currentSession;

    authSubscription = supabase.auth.onAuthStateChange.listen((data) {
      setState(() {
        session = data.session;
      });
    });
  }

  @override
  void dispose() {
    authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catatan Online',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
      ),
      home: session == null ? const AuthPage() : const NotesPage(),
    );
  }
}

// =======================
// HALAMAN LOGIN / REGISTER
// =======================

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLogin = true;
  bool isLoading = false;

  Future<void> authAction() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showMessage('Email dan password wajib diisi');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      if (isLogin) {
        await supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );

        showMessage('Login berhasil');
      } else {
        await supabase.auth.signUp(
          email: email,
          password: password,
        );

        showMessage('Register berhasil, silakan login');
        setState(() {
          isLogin = true;
        });
      }
    } on AuthException catch (e) {
      showMessage(e.message);
    } catch (e) {
      showMessage('Terjadi kesalahan: $e');
    }

    setState(() {
      isLoading = false;
    });
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.note_alt,
                    size: 80,
                    color: Colors.deepPurple,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isLogin ? 'Login Catatan Online' : 'Register Akun',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : authAction,
                      child: isLoading
                          ? const CircularProgressIndicator()
                          : Text(isLogin ? 'Login' : 'Register'),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        isLogin = !isLogin;
                      });
                    },
                    child: Text(
                      isLogin
                          ? 'Belum punya akun? Register'
                          : 'Sudah punya akun? Login',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =======================
// HALAMAN CRUD CATATAN
// =======================

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  List<Map<String, dynamic>> notes = [];
  bool isLoading = true;

  final titleController = TextEditingController();
  final contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchNotes();
  }

  Future<void> fetchNotes() async {
    setState(() {
      isLoading = true;
    });

    try {
      final user = supabase.auth.currentUser;

      if (user == null) {
        return;
      }

      final data = await supabase
          .from('notes')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      setState(() {
        notes = List<Map<String, dynamic>>.from(data);
      });
    } catch (e) {
      showMessage('Gagal mengambil data: $e');
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> addNote() async {
    final title = titleController.text.trim();
    final content = contentController.text.trim();
    final user = supabase.auth.currentUser;

    if (title.isEmpty || content.isEmpty) {
      showMessage('Judul dan isi catatan wajib diisi');
      return;
    }

    if (user == null) {
      showMessage('User belum login');
      return;
    }

    try {
      await supabase.from('notes').insert({
        'title': title,
        'content': content,
        'user_id': user.id,
      });

      titleController.clear();
      contentController.clear();

      Navigator.pop(context);
      showMessage('Catatan berhasil ditambahkan');
      fetchNotes();
    } catch (e) {
      showMessage('Gagal menambah catatan: $e');
    }
  }

  Future<void> updateNote(int id) async {
    final title = titleController.text.trim();
    final content = contentController.text.trim();
    final user = supabase.auth.currentUser;

    if (title.isEmpty || content.isEmpty) {
      showMessage('Judul dan isi catatan wajib diisi');
      return;
    }

    if (user == null) {
      showMessage('User belum login');
      return;
    }

    try {
      await supabase
          .from('notes')
          .update({
        'title': title,
        'content': content,
      })
          .eq('id', id)
          .eq('user_id', user.id);

      titleController.clear();
      contentController.clear();

      Navigator.pop(context);
      showMessage('Catatan berhasil diperbarui');
      fetchNotes();
    } catch (e) {
      showMessage('Gagal memperbarui catatan: $e');
    }
  }

  Future<void> deleteNote(int id) async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      showMessage('User belum login');
      return;
    }

    try {
      await supabase
          .from('notes')
          .delete()
          .eq('id', id)
          .eq('user_id', user.id);

      showMessage('Catatan berhasil dihapus');
      fetchNotes();
    } catch (e) {
      showMessage('Gagal menghapus catatan: $e');
    }
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
  }

  void showNoteDialog({Map<String, dynamic>? note}) {
    final isEdit = note != null;

    if (isEdit) {
      titleController.text = note['title'];
      contentController.text = note['content'];
    } else {
      titleController.clear();
      contentController.clear();
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEdit ? 'Edit Catatan' : 'Tambah Catatan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Judul',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contentController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Isi Catatan',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (isEdit) {
                  updateNote(note['id']);
                } else {
                  addNote();
                }
              },
              child: Text(isEdit ? 'Update' : 'Simpan'),
            ),
          ],
        );
      },
    );
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = supabase.auth.currentUser?.email ?? '-';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Online'),
        actions: [
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.deepPurple.shade50,
            child: Text(
              'Login sebagai: $userEmail',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(
              child: CircularProgressIndicator(),
            )
                : notes.isEmpty
                ? const Center(
              child: Text('Belum ada catatan'),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.notes),
                    ),
                    title: Text(
                      note['title'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(note['content']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            showNoteDialog(note: note);
                          },
                          icon: const Icon(Icons.edit),
                        ),
                        IconButton(
                          onPressed: () {
                            deleteNote(note['id']);
                          },
                          icon: const Icon(Icons.delete),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showNoteDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}