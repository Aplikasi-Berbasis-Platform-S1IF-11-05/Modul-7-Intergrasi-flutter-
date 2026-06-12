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