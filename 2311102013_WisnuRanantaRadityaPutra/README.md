<div align="center">
  <br />
  <h1>LAPORAN PRAKTIKUM <br> APLIKASI BERBASIS PLATFORM </h1>
  <br />
  <h3>MODUL 7<br> Flutter </h3>
  <br />
  <img width="512" height="512" alt="telyu" src="https://github.com/user-attachments/assets/724a3291-bcf9-448d-a395-3886a8659d79" />
  <br />
  <br />
  <br />
  <h3>Disusun Oleh :</h3>
  <p>
    <strong>Wisnu Rananta Raditya Putra</strong>
    <br>
    <strong>2311102013</strong>
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
Flutter merupakan framework open-source yang dikembangkan oleh Google untuk membangun aplikasi mobile, web, dan desktop menggunakan satu basis kode (single codebase). Flutter menggunakan bahasa pemrograman Dart dan menyediakan berbagai widget yang memudahkan pengembangan antarmuka pengguna yang responsif dan menarik. Dengan pendekatan single codebase, pengembang dapat membuat aplikasi untuk berbagai platform secara lebih efisien tanpa perlu menulis kode yang berbeda untuk setiap sistem operasi. Selain itu, Flutter juga memiliki fitur Hot Reload yang memungkinkan perubahan kode dapat langsung terlihat tanpa harus menjalankan ulang aplikasi secara keseluruhan.
</p>

<p align='justify'>
Dalam pengembangan aplikasi modern, Flutter sering dipadukan dengan layanan Backend as a Service (BaaS) seperti Firebase dan Supabase. Firebase menyediakan layanan backend berupa Authentication, Cloud Firestore, Realtime Database, Storage, dan Cloud Messaging, sedangkan Supabase merupakan platform open-source yang menggunakan database PostgreSQL serta menyediakan fitur Authentication, Database, Storage, dan Realtime API. Penggunaan Firebase maupun Supabase memungkinkan pengembang membangun aplikasi tanpa harus membuat dan mengelola server backend secara mandiri sehingga proses pengembangan menjadi lebih cepat dan efisien, terutama dalam implementasi fitur login, penyimpanan data online, operasi CRUD (Create, Read, Update, Delete), serta notifikasi pada aplikasi.
</p>

# Task 4 - Mobile
## Source Code main.dart
```dart
<!-- 2311102013
Wisnu Rananta Raditya Putra
S1IF-11-05 -->
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'notification_service.dart';
import 'auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://orowyjkhvhhcekkyrfmb.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9yb3d5amtodmhoY2Vra3lyZm1iIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODEyMzYwODYsImV4cCI6MjA5NjgxMjA4Nn0.NMd9-56U1w9I7B4KV3QD8EHAazTQ8su64D-exqFAkwI',
  );

  await NotificationService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventory',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const AuthScreen(),
    );
  }
}
```
## Source Code auth_screen.dart
```dart
<!-- 2311102013
Wisnu Rananta Raditya Putra
S1IF-11-05 -->
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _supabase = Supabase.instance.client;
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() => _isLoading = true);
    try {
      await _supabase.auth.signInWithPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
    setState(() => _isLoading = false);
  }

  Future<void> _register() async {
    setState(() => _isLoading = true);
    try {
      await _supabase.auth.signUp(
        email: _emailController.text,
        password: _passwordController.text,
      );
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registrasi sukses! Silakan login.')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.inventory_2_outlined, size: 64, color: Colors.teal),
              const SizedBox(height: 16),
              Text(
                'Login Inventaris',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal.shade800),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: _login,
                        child: const Text('Login', style: TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _isLoading ? null : _register,
                child: const Text('Belum punya akun? Register', style: TextStyle(color: Colors.teal)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
```

## Source Code home_screen.dart
```dart
<!-- 2311102013
Wisnu Rananta Raditya Putra
S1IF-11-05 -->
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'notification_service.dart';
import 'form_screen.dart';
import 'auth_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _supabase = Supabase.instance.client;
  List<dynamic> _inventory = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final response = await _supabase.from('inventory').select();
    setState(() {
      _inventory = response;
    });
  }

  // Fungsi untuk mengeksekusi penghapusan ke Supabase
  Future<void> _deleteItem(String id, String itemName) async {
    await _supabase.from('inventory').delete().eq('id', id);
    NotificationService.showNotification(
      title: 'Barang Dihapus',
      body: '$itemName berhasil dihapus dari sistem.',
    );
    _fetchData();
  }

  // TAMBAHAN: Fungsi untuk memunculkan Dialog Konfirmasi
  Future<void> _showDeleteConfirmation(String id, String itemName) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Pengguna harus memilih tombol, tidak bisa klik di luar dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: Text('Apakah Anda yakin ingin menghapus "$itemName"? Action ini tidak dapat dibatalkan.'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog tanpa hapus
              },
            ),
            TextButton(
              child: const Text('Hapus', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
                _deleteItem(id, itemName); // Jalankan fungsi hapus data
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout() async {
    await _supabase.auth.signOut();
    if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AuthScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text('Inventaris', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout), 
            onPressed: _logout,
          ),
        ],
      ),
      body: _inventory.isEmpty
          ? const Center(child: Text('Inventaris kosong.', style: TextStyle(fontSize: 16, color: Colors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _inventory.length,
              itemBuilder: (context, index) {
                final item = _inventory[index];
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const Icon(Icons.inventory, color: Colors.teal),
                    title: Text(item['item_name'], style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('Stok: ${item['quantity']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blueGrey),
                          onPressed: () async {
                            await Navigator.push(context, MaterialPageRoute(builder: (_) => FormScreen(item: item)));
                            _fetchData();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          // DIUBAH: Sekarang memanggil fungsi dialog konfirmasi terlebih dahulu
                          onPressed: () => _showDeleteConfirmation(item['id'], item['item_name']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const FormScreen()));
          _fetchData();
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
```

## Source Code form_screen.dart
```dart
<!-- 2311102013
Wisnu Rananta Raditya Putra
S1IF-11-05 -->
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
  final _nameController = TextEditingController();
  final _qtyController = TextEditingController();
  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _nameController.text = widget.item!['item_name'];
      _qtyController.text = widget.item!['quantity'].toString();
    }
  }

  Future<void> _saveData() async {
    final userId = _supabase.auth.currentUser!.id;
    final name = _nameController.text;
    final qty = int.tryParse(_qtyController.text) ?? 0;

    if (widget.item == null) {
      await _supabase.from('inventory').insert({
        'user_id': userId,
        'item_name': name,
        'quantity': qty,
      });
      NotificationService.showNotification(title: 'Barang Ditambahkan', body: '$name berhasil dimasukkan ke inventaris.');
    } else {
      await _supabase.from('inventory').update({
        'item_name': name,
        'quantity': qty,
      }).eq('id', widget.item!['id']);
      NotificationService.showNotification(title: 'Barang Diperbarui', body: 'Data $name telah diubah.');
    }
    
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text(widget.item == null ? 'Tambah Barang' : 'Edit Barang', style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController, 
              decoration: InputDecoration(
                labelText: 'Nama Barang',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              )
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _qtyController, 
              keyboardType: TextInputType.number, 
              decoration: InputDecoration(
                labelText: 'Jumlah Stok',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              )
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _saveData, 
                child: const Text('Simpan', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Source Code notificarion_service.dart
```dart
<!-- 2311102013
Wisnu Rananta Raditya Putra
S1IF-11-05 -->
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin
      flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future init() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
        InitializationSettings(
      android: androidSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings,
    );
  }

  static Future showNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'coffee_channel',
      'Coffee Notification',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails details =
        NotificationDetails(
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecond,
      title,
      body,
      details,
    );
  }
}
```
# Screenshots Output
<img src="ss-login.png" alt="preview" style="width:70%">
<img src="ss-home.png" alt="preview" style="width:70%">
<img src="ss-add.png" alt="preview" style="width:70%">
<img src="ss-edit.png" alt="preview" style="width:70%">
<img src="ss-delete.png" alt="preview" style="width:70%">
<img src="ss-schemadb.png" alt="preview" style="width:70%">
<img src="ss-auth.png" alt="preview" style="width:70%">
<img src="ss-db.png" alt="preview" style="width:70%">

# Penjelasan
<p align="justify">
Kode diatas merupakan aplikasi inventaris barang ini dikembangkan menggunakan Flutter sebagai framework frontend dan Supabase sebagai layanan backend yang menyediakan fitur autentikasi serta penyimpanan data. Pada saat aplikasi dijalankan, pengguna akan diarahkan ke halaman login untuk melakukan autentikasi menggunakan email dan password. Jika pengguna belum memiliki akun, tersedia fitur registrasi yang akan menyimpan data akun ke Supabase Authentication. Setelah berhasil login, pengguna dapat mengakses halaman utama yang menampilkan daftar barang inventaris yang tersimpan pada database. Data inventaris diambil secara real-time dari tabel inventory menggunakan layanan Supabase dan ditampilkan dalam bentuk daftar yang mudah dikelola oleh pengguna.
</p>

<p align="justify">
Aplikasi ini menerapkan konsep CRUD (Create, Read, Update, Delete) untuk pengelolaan data inventaris. Pengguna dapat menambahkan barang baru dengan mengisi nama barang dan jumlah stok, mengubah data barang yang sudah ada, serta menghapus barang yang tidak diperlukan lagi. Setiap perubahan data akan langsung disimpan ke database Supabase sehingga data tetap konsisten dan terintegrasi. Selain itu, aplikasi memanfaatkan Flutter Local Notifications untuk menampilkan notifikasi lokal ketika terjadi proses penambahan, pembaruan, atau penghapusan data barang. Dengan kombinasi Flutter, Supabase, dan notifikasi lokal, aplikasi ini mampu memberikan solusi pengelolaan inventaris yang sederhana, responsif, dan mudah digunakan.
<p>