import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'notification_service.dart';
import 'form.dart';
import 'auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _supabase = Supabase.instance.client;
  List<dynamic> _wishlist = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final response = await _supabase.from('wishlist').select().order('item_name', ascending: true);
    setState(() {
      _wishlist = response;
    });
  }

  Future<void> _deleteItem(String id, String itemName) async {
    await _supabase.from('wishlist').delete().eq('id', id);
    NotificationService.showNotification(
      title: 'Wishlist Dihapus',
      body: '"$itemName" telah dihapus dari rencanamu.',
    );
    _fetchData();
  }

  Future<void> _showDeleteConfirmation(String id, String itemName) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Hapus Target?'),
          content: Text('Apakah kamu yakin ingin membatalkan target "$itemName"?'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Hapus', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteItem(id, itemName);
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
        elevation: 0,
        backgroundColor: Colors.transparent,
        toolbarHeight: 80,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Wishlist', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 22)),
            Text('Target Wishlist Kamu', style: TextStyle(color: Colors.black54, fontSize: 14)),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: IconButton(icon: const Icon(Icons.logout, color: Colors.blueAccent), onPressed: _logout),
          ),
        ],
      ),
      body: _wishlist.isEmpty
          ? const Center(child: Text('Belum ada target wishlist.', style: TextStyle(fontSize: 16, color: Colors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _wishlist.length,
              itemBuilder: (context, index) {
                final item = _wishlist[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueAccent.withOpacity(0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.shopping_bag_rounded, color: Colors.blueAccent),
                    ),
                    title: Text(item['item_name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Text('Rp ${item['price']}', style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_note, color: Colors.blueGrey, size: 28),
                          onPressed: () async {
                            await Navigator.push(context, MaterialPageRoute(builder: (_) => FormScreen(item: item)));
                            _fetchData();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 26),
                          onPressed: () => _showDeleteConfirmation(item['id'], item['item_name']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blueAccent,
        elevation: 4,
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const FormScreen()));
          _fetchData();
        },
        icon: const Icon(Icons.add_circle_outline, color: Colors.white),
        label: const Text('Tambah Target', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}