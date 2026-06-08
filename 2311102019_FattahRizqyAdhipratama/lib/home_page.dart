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

    final response = await supabase
        .from('orders')
        .select()
        .order('id');

    setState(() {
      orders = response;
    });
  }

  Future addOrder() async {

    final coffee = TextEditingController();
    final size = TextEditingController();
    final qty = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Tambah Order"),
          content: SingleChildScrollView(
            child: Column(
              children: [

                TextField(
                  controller: coffee,
                  decoration: const InputDecoration(
                    labelText: "Nama Kopi",
                  ),
                ),

                TextField(
                  controller: size,
                  decoration: const InputDecoration(
                    labelText: "Size",
                  ),
                ),

                TextField(
                  controller: qty,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Jumlah",
                  ),
                ),
              ],
            ),
          ),
          actions: [

            ElevatedButton(
              onPressed: () async {

                await supabase.from('orders').insert({
                  'coffee_name': coffee.text,
                  'size': size.text,
                  'quantity': int.parse(qty.text),
                  'user_id': supabase.auth.currentUser!.id,
                });

                Navigator.pop(context);

                await NotificationService.showNotification(
                  title: "Coffee Order",
                  body: "${coffee.text} berhasil ditambahkan",
                );

                showCustomSnackBar(
                  message: "Order berhasil ditambahkan",
                  icon: Icons.coffee,
                  color: Colors.green,
                );

                loadData();
              },
              child: const Text("Simpan"),
            )
          ],
        );
      },
    );
  }

  Future editOrder(Map data) async {

    final coffee =
        TextEditingController(text: data['coffee_name']);

    final size =
        TextEditingController(text: data['size']);

    final qty =
        TextEditingController(
            text: data['quantity'].toString());

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Edit Order"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              TextField(
                controller: coffee,
              ),

              TextField(
                controller: size,
              ),

              TextField(
                controller: qty,
              ),
            ],
          ),
          actions: [

            ElevatedButton(
              onPressed: () async {

                await supabase
                    .from('orders')
                    .update({
                  'coffee_name': coffee.text,
                  'size': size.text,
                  'quantity':
                      int.parse(qty.text),
                })
                    .eq('id', data['id']);

                Navigator.pop(context);

                await NotificationService.showNotification(
                  title: "Coffee Order",
                  body: "${coffee.text} berhasil diperbarui",
                );

                showCustomSnackBar(
                  message: "Order berhasil diperbarui",
                  icon: Icons.edit,
                  color: Colors.orange,
                );

                loadData();
              },
              child: const Text("Update"),
            )
          ],
        );
      },
    );
  }

  Future deleteOrder(int id) async {

    await supabase
        .from('orders')
        .delete()
        .eq('id', id);

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

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginPage(),
      ),
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
        title: const Text("Coffee Orders"),
        actions: [
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout),
          )
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
        onPressed: addOrder,
        icon: const Icon(Icons.coffee),
        label: const Text("Tambah"),
      ),

      body: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {

          final item = orders[index];

          return Card(
          elevation: 5,
          margin: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: const CircleAvatar(
              radius: 24,
              backgroundColor: Colors.brown,
              child: Icon(
                Icons.coffee,
                color: Colors.white,
              ),
            ),
            title: Text(
              item['coffee_name'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                "Ukuran: ${item['size']}\nJumlah: ${item['quantity']}",
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.edit,
                      color: Colors.orange,
                    ),
                    onPressed: () => editOrder(item),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    onPressed: () => deleteOrder(item['id']),
                  ),
                ),
              ],
            ),
          ),
        );
        },
      ),
    );
  }
}