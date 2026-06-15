import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _tugasList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTugas(); // Ambil data saat halaman pertama kali dibuka
  }

  // === FITUR NOTIFIKASI CRUD ===
  void _showNotification(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blueAccent,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // === FITUR READ (Membaca Data) ===
  Future<void> _fetchTugas() async {
    setState(() => _isLoading = true);
    try {
      final userId = _supabase.auth.currentUser!.id;
      // Filter agar user hanya melihat tugas milik akunnya sendiri
      final response = await _supabase
          .from('tabel_tugas')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      
      setState(() {
        _tugasList = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      _showNotification('Gagal memuat daftar tugas!');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // === FITUR CREATE (Menambah Data) ===
  Future<void> _tambahTugas(String judul) async {
    if (judul.isEmpty) return;
    try {
      final userId = _supabase.auth.currentUser!.id;
      await _supabase.from('tabel_tugas').insert({
        'user_id': userId,
        'judul_tugas': judul,
      });
      _showNotification('Tugas baru berhasil ditambahkan!'); // Notifikasi Create
      _fetchTugas(); // Refresh list setelah ditambah
    } catch (e) {
      // Menampilkan error asli ke layar dan terminal
      _showNotification('Error: $e'); 
      print('DEBUG ERROR: $e');
    }
  }

  // === FITUR UPDATE (Mengubah Status) ===
  Future<void> _updateStatus(int id, bool isSelesai) async {
    try {
      await _supabase
          .from('tabel_tugas')
          .update({'is_selesai': isSelesai})
          .eq('id', id);
      _showNotification(isSelesai ? 'Mantap, tugas diselesaikan!' : 'Tugas batal selesai.'); // Notifikasi Update
      _fetchTugas(); // Refresh list setelah diubah
    } catch (e) {
      _showNotification('Gagal mengupdate tugas!');
    }
  }

  // === FITUR DELETE (Menghapus Data) ===
  Future<void> _hapusTugas(int id) async {
    try {
      await _supabase.from('tabel_tugas').delete().eq('id', id);
      _showNotification('Tugas berhasil dihapus!'); // Notifikasi Delete
      _fetchTugas(); // Refresh list setelah dihapus
    } catch (e) {
      _showNotification('Gagal menghapus tugas!');
    }
  }

  // === FITUR LOGOUT ===
  Future<void> _logout() async {
    await _supabase.auth.signOut();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  // Dialog Pop-up untuk Form Tambah Tugas
  void _showAddDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Tugas Baru'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Contoh: Tugas Modul 7'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _tambahTugas(controller.text);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Tugas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tugasList.isEmpty
              ? const Center(child: Text('Belum ada tugas. Yeay!'))
              : ListView.builder(
                  itemCount: _tugasList.length,
                  itemBuilder: (context, index) {
                    final tugas = _tugasList[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: ListTile(
                        leading: Checkbox(
                          value: tugas['is_selesai'] ?? false,
                          onChanged: (value) => _updateStatus(tugas['id'], value!),
                        ),
                        title: Text(
                          tugas['judul_tugas'],
                          style: TextStyle(
                            decoration: (tugas['is_selesai'] ?? false)
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _hapusTugas(tugas['id']),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}