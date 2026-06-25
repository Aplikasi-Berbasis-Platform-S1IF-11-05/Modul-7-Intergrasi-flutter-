<div align="center">
  <br />
  <h1>LAPORAN PRAKTIKUM <br> APLIKASI BERBASIS PLATFORM </h1>
  <br />
  <h3>MODUL 7 <br> Integrasi Flutter Firebase/Supabase </h3>
  <br />
  <img width="512" height="512" alt="telyu" src="https://github.com/user-attachments/assets/724a3291-bcf9-448d-a395-3886a8659d79" />
  <br />
  <br />
  <br />
  <h3>Disusun Oleh :</h3>
  <p>
    <strong>Adrian Basari Rhesa</strong>
    <br>
    <strong>2311102105</strong>
    <br>
    <strong>S1 IF-11-REG05</strong>
  </p>
  <br />
  <h3>Dosen Pengampu :</h3>
  <p>
    <strong>Dedi Agung Prabowo, S.Kom., M.Kom</strong>
  </p>
  <br />
  <br />
  <h4>Asisten Praktikum :</h4>
  <strong>Apri Pandu Wicaksono </strong>
  <br>
  <strong>Hamka Zaenul Ardi</strong>
  <br />
  <h3>LABORATORIUM HIGH PERFORMANCE <br>FAKULTAS INFORMATIKA <br>UNIVERSITAS TELKOM PURWOKERTO <br>2026 </h3>
</div>

<hr>

# Dasar Teori

<p align="justify">
Flutter merupakan framework open-source yang digunakan untuk membangun aplikasi multiplatform dengan bahasa pemrograman Dart. Pada praktikum ini, Flutter digunakan untuk membuat aplikasi sederhana bertema Catatan Online yang memiliki fitur login, register, serta pengelolaan data catatan. </p> <p align="justify"> Authentication merupakan proses autentikasi pengguna agar aplikasi hanya dapat diakses oleh pengguna yang memiliki akun. Pada aplikasi ini, authentication diterapkan melalui fitur register dan login menggunakan email serta password. Setelah pengguna berhasil login, pengguna dapat masuk ke halaman utama aplikasi. </p> <p align="justify"> CRUD merupakan singkatan dari Create, Read, Update, dan Delete. Fitur CRUD digunakan untuk mengelola data pada aplikasi. Pada praktikum ini, CRUD diterapkan pada data catatan, yaitu menambahkan catatan baru, menampilkan daftar catatan, mengubah catatan, dan menghapus catatan. </p> <p align="justify"> Supabase digunakan sebagai backend untuk menyimpan data secara online. Supabase menyediakan layanan authentication dan database yang dapat dihubungkan dengan aplikasi Flutter. Dengan menggunakan Supabase, data akun pengguna dan data catatan dapat tersimpan secara online. </p> <p align="justify"> Notifikasi CRUD digunakan untuk memberikan informasi kepada pengguna setelah melakukan aksi pada data. Pada aplikasi ini, notifikasi ditampilkan menggunakan SnackBar ketika pengguna berhasil menambah, mengubah, atau menghapus catatan.
</p>

## Source Code 
```dart
// 2311102105 - AdrianBasariRhesa

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://jubtxmzbezyalmuvrcun.supabase.co',
    publishableKey: 'sb_publishable_QMOkdEupWYYDbVJFf7_EaA_z42Y1m4h',
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
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.deepPurple),
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
        await supabase.auth.signUp(email: email, password: password);

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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
          .update({'title': title, 'content': content})
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
      await supabase.from('notes').delete().eq('id', id).eq('user_id', user.id);

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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = supabase.auth.currentUser?.email ?? '-';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Online'),
        actions: [
          IconButton(onPressed: logout, icon: const Icon(Icons.logout)),
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
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : notes.isEmpty
                ? const Center(child: Text('Belum ada catatan'))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      final note = notes[index];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: const CircleAvatar(child: Icon(Icons.notes)),
                          title: Text(
                            note['title'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
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
```
# Screenshots Output
## Tampilan Beranda
![Tampilan Beranda](<screenshots/Beranda.png>)

## Tampilan Halaman Utama
![Tampilan Halaman Utama](<screenshots/Halaman Utama.png>)

## Tampilan Tambah Catatan
![Tampilan Tambah Catatan](<screenshots/Tambah Catatan.png>)

## Tambah Halaman Update
![Tambah Halaman Update](<screenshots/Halaman Update.png>)

## Hasil Tambah Halaman Register
![Hasil Tambah Halaman Register](<screenshots/Halaman Register.png>)

## Edit Halaman Hapus
![Edit Halaman Hapus](<screenshots/Halaman Hapus.png>)
# Penjelasan
<p align="justify">
<p align="justify">
Output aplikasi menampilkan beberapa tampilan utama, yaitu halaman login, halaman register akun, halaman beranda catatan, halaman tambah catatan, hasil tambah catatan, dan halaman edit catatan. Pada halaman login dan register, pengguna dapat melakukan autentikasi menggunakan email dan password sebelum masuk ke halaman utama aplikasi.
</p>
<p align="justify">
Setelah pengguna berhasil login, aplikasi akan menampilkan halaman beranda yang berisi daftar catatan. Pengguna dapat menambahkan catatan baru melalui tombol tambah, kemudian data catatan yang berhasil ditambahkan akan tampil pada halaman beranda. Selain itu, pengguna juga dapat mengubah data catatan melalui fitur edit dan menghapus catatan yang sudah tidak diperlukan.
</p>
<p align="justify">
Setiap proses CRUD pada aplikasi akan menampilkan notifikasi sebagai tanda bahwa aksi berhasil dilakukan, seperti catatan berhasil ditambahkan, catatan berhasil diperbarui, dan catatan berhasil dihapus. Aplikasi ini sudah terhubung dengan Supabase sebagai backend, sehingga data akun pengguna dan data catatan dapat tersimpan secara online.
</p>
</p>