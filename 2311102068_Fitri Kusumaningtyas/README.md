<div align="center">
  <br />
  <h1>LAPORAN PRAKTIKUM <br> APLIKASI BERBASIS PLATFORM </h1>
  <br />
  <h3>MODUL 7 <br> INTEGRASI FLUTTER FIREBASE/SUPABASE </h3>
  <br />
  <img width="512" height="512" alt="telyu" src="https://github.com/user-attachments/assets/724a3291-bcf9-448d-a395-3886a8659d79" />
  <br />
  <br />
  <br />
  <h3>Disusun Oleh :</h3>
  <p>
    <strong>Fitri Kusumaningtyas</strong>
    <br>
    <strong>2311102068</strong>
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

## Dasar Teori

Flutter merupakan framework pengembangan aplikasi mobile open-source yang dikembangkan oleh Google, menggunakan bahasa pemrograman Dart. Framework ini memungkinkan pengembang membangun aplikasi untuk berbagai platform (Android, iOS, web, dan desktop) dari satu basis kode yang sama, dengan keunggulan utama berupa proses kompilasi native yang menghasilkan performa tinggi serta fitur hot reload yang memudahkan proses pengembangan dan pengujian secara cepat.
Authentication atau autentikasi adalah proses verifikasi identitas pengguna untuk memastikan bahwa pengguna yang mengakses sistem benar-benar memiliki hak akses yang sah. Dalam aplikasi ini, proses autentikasi diimplementasikan menggunakan layanan Supabase Auth, yang menyediakan mekanisme registrasi (sign up) dan login (sign in) berbasis email dan password. Setiap pengguna yang berhasil melakukan autentikasi akan memperoleh sesi unik yang digunakan sistem untuk mengidentifikasi data milik pengguna tersebut secara aman.
CRUD merupakan akronim dari Create, Read, Update, dan Delete, yaitu empat operasi dasar yang digunakan dalam manajemen data pada suatu sistem basis data. Operasi Create digunakan untuk menambahkan data baru, Read untuk menampilkan atau membaca data yang tersimpan, Update untuk memperbarui data yang sudah ada, dan Delete untuk menghapus data. Dalam aplikasi ini, operasi CRUD diterapkan pada data tugas (task) yang disimpan dalam tabel basis data dan dapat dikelola langsung oleh pengguna melalui antarmuka aplikasi.
Supabase adalah platform Backend-as-a-Service (BaaS) open-source yang menyediakan berbagai layanan backend siap pakai, antara lain basis data PostgreSQL, sistem autentikasi, penyimpanan file, dan API yang dapat diakses secara real-time. Supabase memungkinkan pengembang untuk membangun aplikasi yang terhubung dengan basis data online tanpa perlu membangun infrastruktur backend dari awal. Pada aplikasi ini, Supabase digunakan sebagai backend untuk menangani proses autentikasi pengguna serta penyimpanan dan pengelolaan data tugas, dengan penerapan Row Level Security (RLS) untuk memastikan setiap pengguna hanya dapat mengakses data miliknya sendiri.
Notifikasi merupakan mekanisme pemberitahuan yang ditampilkan kepada pengguna untuk memberikan informasi terkait suatu kejadian atau perubahan status dalam aplikasi. Pada aplikasi ini, notifikasi diimplementasikan menggunakan pustaka flutter_local_notifications, yang memungkinkan aplikasi menampilkan notifikasi lokal pada perangkat pengguna setiap kali terjadi operasi CRUD, seperti penambahan, pengubahan, atau penghapusan data tugas, sehingga pengguna mendapatkan umpan balik secara langsung atas aksi yang dilakukan.


##  Tugas Modul 7 (To-Do App)
### Source code main.dart
``` dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/notification_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

const supabaseUrl = 'https://kiuejuklmaldpgjknbxp.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtpdWVqdWtsbWFsZHBnamtuYnhwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODEyNTkyNzYsImV4cCI6MjA5NjgzNTI3Nn0.o4LMEKKJbRZaj8c0S76PCa4HTH_yS6_Vjx5GdnSUnKk';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  await NotificationService.init();

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      home: supabase.auth.currentSession == null
          ? const LoginScreen()
          : const HomeScreen(),
    );
  }
}
```

### Source code auth_Service.dart
``` dart
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<AuthResponse> signUp(String email, String password) {
    return _client.auth.signUp(email: email, password: password);
  }

  Future<AuthResponse> signIn(String email, String password) {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() {
    return _client.auth.signOut();
  }

  User? get currentUser => _client.auth.currentUser;
}
```

### Source code notification_service.dart
``` dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(settings);
  }

  static Future<void> show(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'task_channel',
      'Task Notifications',
      channelDescription: 'Notifikasi CRUD tugas',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );
  }
}
```
### Source code task_service.dart
``` dart
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
```
### Source code home_screen.dart
``` dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/task_service.dart';
import '../services/notification_service.dart';
import 'login_screen.dart';
import 'task_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _taskService = TaskService();
  final _authService = AuthService();
  List<Task> _tasks = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _loading = true);
    final tasks = await _taskService.getTasks();
    setState(() {
      _tasks = tasks;
      _loading = false;
    });
  }

  Future<void> _deleteTask(Task task) async {
    await _taskService.deleteTask(task.id);
    await NotificationService.show(
      'Tugas Dihapus',
      '"${task.title}" telah dihapus',
    );
    _loadTasks();
  }

  Future<void> _toggleDone(Task task) async {
    await _taskService.toggleDone(task.id, !task.isDone);
    await NotificationService.show(
      task.isDone ? 'Tugas Dibuka Lagi' : 'Tugas Selesai',
      '"${task.title}" ${task.isDone ? 'ditandai belum selesai' : 'selesai dikerjakan'}',
    );
    _loadTasks();
  }

  Future<void> _logout() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  Future<void> _openForm({Task? task}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TaskFormScreen(task: task)),
    );
    if (result == true) {
      await NotificationService.show(
        task == null ? 'Tugas Ditambahkan' : 'Tugas Diperbarui',
        task == null
            ? 'Tugas baru berhasil ditambahkan'
            : 'Tugas berhasil diperbarui',
      );
      _loadTasks();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Tugas'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _tasks.isEmpty
              ? const Center(child: Text('Belum ada tugas'))
              : RefreshIndicator(
                  onRefresh: _loadTasks,
                  child: ListView.builder(
                    itemCount: _tasks.length,
                    itemBuilder: (context, index) {
                      final task = _tasks[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        child: ListTile(
                          leading: Checkbox(
                            value: task.isDone,
                            onChanged: (_) => _toggleDone(task),
                          ),
                          title: Text(
                            task.title,
                            style: TextStyle(
                              decoration: task.isDone
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          subtitle: Text(task.description),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _openForm(task: task),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _deleteTask(task),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
```
### Source code login_screen.dart
``` dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'register_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _loading = false;

  Future<void> _login() async {
    setState(() => _loading = true);
    try {
      await _authService.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login gagal: $e')),
        );
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _login,
                    child: const Text('Login'),
                  ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                );
              },
              child: const Text('Belum punya akun? Daftar'),
            ),
          ],
        ),
      ),
    );
  }
}
```
### Source code register_screen.dart
``` dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _loading = false;

  Future<void> _register() async {
    setState(() => _loading = true);
    try {
      await _authService.signUp(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Registrasi berhasil! Silakan cek email & login.')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registrasi gagal: $e')),
        );
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _register,
                    child: const Text('Daftar'),
                  ),
          ],
        ),
      ),
    );
  }
}
```
### Source code task_form_screen.dart
``` dart
import 'package:flutter/material.dart';
import '../services/task_service.dart';

class TaskFormScreen extends StatefulWidget {
  final Task? task;
  const TaskFormScreen({super.key, this.task});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  final _taskService = TaskService();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descController =
        TextEditingController(text: widget.task?.description ?? '');
  }

  Future<void> _save() async {
    if (_titleController.text.trim().isEmpty) return;
    setState(() => _saving = true);

    if (widget.task == null) {
      await _taskService.addTask(
        _titleController.text.trim(),
        _descController.text.trim(),
      );
    } else {
      await _taskService.updateTask(
        widget.task!.id,
        _titleController.text.trim(),
        _descController.text.trim(),
      );
    }

    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.task != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Tugas' : 'Tambah Tugas')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Judul Tugas'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Deskripsi'),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            _saving
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _save,
                    child: Text(isEdit ? 'Simpan Perubahan' : 'Tambah Tugas'),
                  ),
          ],
        ),
      ),
    );
  }
}
```

### Screenshot Output
<img src="Auth Supabase.png" alt="Keterangan Foto" width="100%">
<img src="Dashboard.png" alt="Keterangan Foto" width="100%">
<img src="Daftar" alt="Keterangan Foto" width="100%">
<img src="Dashboard After Daftar.png" alt="Keterangan Foto" width="100%">
<img src="Login.png" alt="Keterangan Foto" width="100%">
<img src="Tampilan Before Add List.png" alt="Keterangan Foto" width="100%">
<img src="Tampilan Add List.png" alt="Keterangan Foto" width="100%">
<img src="Tampilan Read.png" alt="Keterangan Foto" width="100%">
<img src="Tampilan Edit.png" alt="Keterangan Foto" width="100%">
<img src="Tampilan After Edit.png" alt="Keterangan Foto" width="100%">
<img src="Tampilan Ceklis.png" alt="Keterangan Foto" width="100%">
<img src="Tampilan after delete.png" alt="Keterangan Foto" width="100%">

## Penjelasan Kode
 
### 1. main.dart
 
File ini adalah titik masuk (entry point) aplikasi. Sebelum aplikasi dijalankan, dilakukan inisialisasi koneksi ke Supabase menggunakan `Supabase.initialize()` dengan parameter `url` dan `anonKey` project. Fungsi `main()` dibuat `async` karena proses inisialisasi Supabase dan notifikasi bersifat asynchronous (membutuhkan waktu). `WidgetsFlutterBinding.ensureInitialized()` dipanggil untuk memastikan binding Flutter siap sebelum memanggil kode native.
 
Setelah inisialisasi selesai, `NotificationService.init()` dipanggil untuk menyiapkan sistem notifikasi lokal. Widget `MyApp` kemudian memeriksa `supabase.auth.currentSession` — jika `null` (belum login), aplikasi menampilkan `LoginScreen`; jika sudah ada sesi aktif, langsung menampilkan `HomeScreen`. Ini memungkinkan pengguna yang sudah login sebelumnya tidak perlu login ulang setiap membuka aplikasi.
 
### 2. auth_service.dart
 
File ini berfungsi sebagai lapisan abstraksi (service layer) untuk semua operasi autentikasi, sehingga logika autentikasi terpisah dari tampilan (UI). Class `AuthService` membungkus tiga fungsi utama dari `Supabase.auth`:
 
| Method | Fungsi |
|---|---|
| `signUp()` | Mendaftarkan pengguna baru dengan email dan password |
| `signIn()` | Melakukan login dan mengembalikan objek `AuthResponse` berisi data sesi pengguna |
| `signOut()` | Mengakhiri sesi pengguna yang sedang login |
 
Getter `currentUser` mengembalikan objek `User` yang sedang aktif, digunakan untuk mengambil `user_id` saat melakukan operasi CRUD.
 
### 3. task_service.dart
 
File ini menangani seluruh operasi CRUD pada tabel `tasks` di Supabase, terdiri dari dua bagian:
 
**Model `Task`** — merepresentasikan struktur data satu tugas (`id`, `title`, `description`, `isDone`). Method `Task.fromMap()` adalah factory constructor yang mengonversi data berbentuk `Map` (hasil response dari Supabase) menjadi objek `Task` yang mudah digunakan di Flutter.
 
**Class `TaskService`** — berisi method-method CRUD:
 
| Method | Operasi | Keterangan |
|---|---|---|
| `getTasks()` | Read | Mengambil seluruh data tugas milik user yang sedang login, diurutkan dari yang terbaru |
| `addTask()` | Create | Menyisipkan baris baru ke tabel `tasks` dengan status `is_done` default `false` |
| `updateTask()` | Update | Memperbarui `title` dan `description` pada baris dengan `id` tertentu |
| `toggleDone()` | Update | Mengubah status `is_done` (selesai/belum selesai) |
| `deleteTask()` | Delete | Menghapus baris berdasarkan `id` |
 
Karena tabel `tasks` memiliki Row Level Security (RLS) dengan policy `auth.uid() = user_id`, Supabase secara otomatis hanya mengizinkan setiap user mengakses data miliknya sendiri, sehingga query di sisi aplikasi tidak perlu khawatir data antar-user tercampur.
 
### 4. notification_service.dart
 
File ini mengelola notifikasi lokal menggunakan package `flutter_local_notifications`. Method `init()` melakukan konfigurasi awal plugin notifikasi (termasuk ikon aplikasi yang digunakan untuk notifikasi Android). Method `show()` menampilkan notifikasi dengan judul dan isi (`title`, `body`) yang ditentukan, menggunakan `AndroidNotificationDetails` untuk mengatur channel, prioritas, dan tingkat kepentingan notifikasi. Setiap notifikasi diberi ID unik berdasarkan timestamp (`DateTime.now().millisecondsSinceEpoch`) agar notifikasi sebelumnya tidak tertimpa.
 
### 5. login_screen.dart & register_screen.dart
 
Kedua screen ini menyediakan form input email dan password menggunakan `TextEditingController`. Saat tombol ditekan, data diambil dari controller dan dikirim ke `AuthService` (`signIn()` atau `signUp()`). Selama proses berjalan, ditampilkan `CircularProgressIndicator` (loading) melalui state `_loading`.
 
- Jika **login** berhasil, pengguna diarahkan ke `HomeScreen`.
- Jika **register** berhasil, ditampilkan notifikasi sukses dan pengguna dikembalikan ke halaman login.
- Jika gagal (misalnya email/password salah), ditampilkan `SnackBar` berisi pesan error.
### 6. home_screen.dart
 
Merupakan halaman utama yang menampilkan daftar tugas dalam bentuk `ListView`. Saat halaman dibuka (`initState`), method `_loadTasks()` dipanggil untuk mengambil data dari Supabase melalui `TaskService.getTasks()`.
 
Setiap item tugas ditampilkan dalam `Card` dengan:
 
- **Checkbox** : menandai tugas selesai/belum, memanggil `_toggleDone()`
- **Icon edit** : membuka `TaskFormScreen` dalam mode edit
- **Icon delete** : memanggil `_deleteTask()`
Setiap aksi CRUD (tambah, edit, hapus, ubah status) memanggil `NotificationService.show()` untuk menampilkan notifikasi sesuai jenis aksinya, lalu memanggil `_loadTasks()` kembali untuk memperbarui tampilan daftar. Tombol `FloatingActionButton` digunakan untuk membuka form tambah tugas baru. Tombol logout di `AppBar` memanggil `AuthService.signOut()` dan mengarahkan kembali ke `LoginScreen`.
 
### 7. task_form_screen.dart
 
Form ini digunakan untuk dua keperluan: **menambah** tugas baru dan **mengedit** tugas yang sudah ada, dibedakan melalui parameter `task` (jika `null` berarti mode tambah, jika tidak `null` berarti mode edit). Saat `initState`, jika `task` tidak `null`, `TextEditingController` diisi dengan data tugas yang akan diedit.
 
Saat tombol simpan ditekan, method `_save()` memeriksa mode (`isEdit`) dan memanggil `TaskService.addTask()` atau `TaskService.updateTask()` sesuai kondisi. Setelah berhasil, halaman ditutup (`Navigator.pop(context, true)`) dengan mengembalikan nilai `true`, yang digunakan oleh `home_screen.dart` sebagai sinyal untuk menampilkan notifikasi dan memuat ulang daftar tugas.
 