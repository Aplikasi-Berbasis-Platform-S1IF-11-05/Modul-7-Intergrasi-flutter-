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