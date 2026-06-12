// 2311102315
// Muhamad Rafli Al Farizqi
// S1IF-11-05
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'notification_service.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final supabase = Supabase.instance.client;

  List orders = [];

  void showCustomSnackBar({
    required String message,
    required IconData icon,
    required Color color,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: color,
        elevation: 10,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future loadData() async {
    final response = await supabase.from('orders').select().order('id');
    setState(() => orders = response);
  }

  Future _orderForm({Map? data}) async {
    final coffee = TextEditingController(text: data?['coffee_name'] ?? '');
    final size = TextEditingController(text: data?['size'] ?? '');
    final qty = TextEditingController(
        text: data?['quantity']?.toString() ?? '');
    final isEdit = data != null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isEdit ? "Edit Pesanan" : "Tambah Pesanan",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade800,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: coffee,
                decoration: const InputDecoration(
                  labelText: "Nama Kopi",
                  prefixIcon: Icon(Icons.local_cafe_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: size,
                decoration: const InputDecoration(
                  labelText: "Ukuran (Size)",
                  prefixIcon: Icon(Icons.straighten),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: qty,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Jumlah",
                  prefixIcon: Icon(Icons.confirmation_number_outlined),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () async {
                  if (isEdit) {
                    await supabase.from('orders').update({
                      'coffee_name': coffee.text,
                      'size': size.text,
                      'quantity': int.tryParse(qty.text) ?? 1,
                    }).eq('id', data['id']);
                  } else {
                    await supabase.from('orders').insert({
                      'coffee_name': coffee.text,
                      'size': size.text,
                      'quantity': int.tryParse(qty.text) ?? 1,
                      'user_id': supabase.auth.currentUser!.id,
                    });
                  }

                  if (!mounted) return;
                  Navigator.pop(context);

                  await NotificationService.showNotification(
                    title: "Coffee Order",
                    body: isEdit
                        ? "${coffee.text} berhasil diperbarui"
                        : "${coffee.text} berhasil ditambahkan",
                  );

                  showCustomSnackBar(
                    message: isEdit
                        ? "Order berhasil diperbarui"
                        : "Order berhasil ditambahkan",
                    icon: isEdit ? Icons.edit : Icons.local_cafe,
                    color: isEdit ? Colors.orange : Colors.green,
                  );

                  loadData();
                },
                icon: Icon(isEdit ? Icons.save : Icons.add),
                label: Text(isEdit ? "Update" : "Simpan"),
              ),
            ],
          ),
        );
      },
    );
  }

  Future deleteOrder(int id) async {
    await supabase.from('orders').delete().eq('id', id);

    await NotificationService.showNotification(
      title: "Coffee Order",
      body: "Pesanan berhasil dihapus",
    );

    showCustomSnackBar(
      message: "Order berhasil dihapus",
      icon: Icons.delete_forever,
      color: Colors.red,
    );

    loadData();
  }

  Future logout() async {
    await supabase.auth.signOut();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Daftar Pesanan Kopi"),
        actions: [
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        onPressed: () => _orderForm(),
        icon: const Icon(Icons.add),
        label: const Text("Tambah"),
      ),
      body: orders.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.local_cafe,
                      size: 70, color: Colors.red.shade200),
                  const SizedBox(height: 12),
                  const Text(
                    "Belum ada pesanan",
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final item = orders[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.red.shade700,
                                Colors.red.shade400,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.local_cafe,
                              color: Colors.white),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['coffee_name'] ?? '-',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 6,
                                children: [
                                  _chip("Size: ${item['size']}"),
                                  _chip("Qty: ${item['quantity']}"),
                                ],
                              ),
                            ],
                          ),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (v) {
                            if (v == 'edit') {
                              _orderForm(data: item);
                            } else {
                              deleteOrder(item['id']);
                            }
                          },
                          itemBuilder: (_) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, color: Colors.orange),
                                  SizedBox(width: 8),
                                  Text("Edit"),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text("Hapus"),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: Colors.red.shade700,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
