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
  List<dynamic> _applications = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final response = await _supabase.from('job_applications').select().order('company_name', ascending: true);
    setState(() {
      _applications = response;
    });
  }

  Future<void> _deleteItem(String id, String company) async {
    await _supabase.from('job_applications').delete().eq('id', id);
    NotificationService.showNotification(
      title: 'Data Dihapus',
      body: 'Lamaran ke $company telah dihapus dari sistem.',
    );
    _fetchData();
  }

  Future<void> _showDeleteConfirmation(String id, String company) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hapus Lamaran?'),
          content: Text('Hapus riwayat lamaran ke $company?'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Hapus', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteItem(id, company);
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
        backgroundColor: const Color(0xFF0A2647),
        title: const Text('Daftar Lamaran', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: _applications.isEmpty
          ? const Center(child: Text('Belum ada lamaran terkirim.', style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _applications.length,
              itemBuilder: (context, index) {
                final item = _applications[index];
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: Colors.amber.shade100,
                      child: const Icon(Icons.business, color: Colors.amber),
                    ),
                    title: Text(item['company_name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(item['position'], style: const TextStyle(color: Color(0xFF0A2647))),
                    ),
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
                          onPressed: () => _showDeleteConfirmation(item['id'], item['company_name']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.amber,
        foregroundColor: const Color(0xFF0A2647),
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const FormScreen()));
          _fetchData();
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah Data', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}