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
  final _priceController = TextEditingController();
  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _nameController.text = widget.item!['item_name'];
      _priceController.text = widget.item!['price'];
    }
  }

  Future<void> _saveData() async {
    final userId = _supabase.auth.currentUser!.id;
    final name = _nameController.text;
    final price = _priceController.text;

    if (widget.item == null) {
      await _supabase.from('wishlist').insert({
        'user_id': userId,
        'item_name': name,
        'price': price,
      });
      NotificationService.showNotification(
        title: 'Target Baru!', 
        body: '$name telah ditambahkan ke target belanjamu.'
      );
    } else {
      await _supabase.from('wishlist').update({
        'item_name': name,
        'price': price,
      }).eq('id', widget.item!['id']);
      NotificationService.showNotification(
        title: 'Target Diperbarui', 
        body: 'Detail barang $name berhasil disimpan ulang.'
      );
    }
    
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(widget.item == null ? 'Tambah Wishlist' : 'Edit Wishlist', style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Detail Barang', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController, 
              decoration: InputDecoration(
                labelText: 'Nama Barang',
                hintText: 'Cth: Keyboard Mechanical, Headphone...',
                filled: true,
                fillColor: const Color(0xFFF4F7FE),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                prefixIcon: const Icon(Icons.card_giftcard, color: Colors.blueAccent),
              )
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _priceController, 
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Perkiraan Harga (Rp)',
                hintText: 'Cth: 1500000',
                filled: true,
                fillColor: const Color(0xFFF4F7FE),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                prefixIcon: const Icon(Icons.attach_money, color: Colors.blueAccent),
              )
            ),
            const SizedBox(height: 40),
            SizedBox(
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                onPressed: _saveData, 
                child: const Text('Simpan Target', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}