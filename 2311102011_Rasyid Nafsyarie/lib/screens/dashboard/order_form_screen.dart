import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderFormScreen extends StatefulWidget {
  final String? docId;
  final QueryDocumentSnapshot? currentData;

  OrderFormScreen({this.docId, this.currentData});

  @override
  _OrderFormScreenState createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends State<OrderFormScreen> {
  final _namaController = TextEditingController();
  final _jumlahController = TextEditingController();
  String _status = 'Menunggu Produksi';
  final CollectionReference orders = FirebaseFirestore.instance.collection('pesanan_lumubi');

  @override
  void initState() {
    super.initState();
    if (widget.currentData != null) {
      _namaController.text = widget.currentData!['nama'];
      _jumlahController.text = widget.currentData!['jumlah_box'].toString();
      _status = widget.currentData!['status'];
    }
  }

  Future<void> simpanData() async {
    if (widget.docId == null) {
      // CREATE
      await orders.add({
        'nama': _namaController.text,
        'jumlah_box': int.parse(_jumlahController.text),
        'status': _status,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } else {
      // UPDATE
      await orders.doc(widget.docId).update({
        'nama': _namaController.text,
        'jumlah_box': int.parse(_jumlahController.text),
        'status': _status,
      });
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.docId == null ? 'Tambah Pesanan' : 'Edit Pesanan')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _namaController,
              decoration: const InputDecoration(labelText: 'Nama Pelanggan'),
            ),
            TextField(
              controller: _jumlahController,
              decoration: const InputDecoration(labelText: 'Jumlah Box'),
              keyboardType: TextInputType.number,
            ),
            DropdownButtonFormField<String>(
              value: _status,
              items: ['Menunggu Produksi', 'Sedang Diproses', 'Selesai']
                  .map((label) => DropdownMenuItem(child: Text(label), value: label))
                  .toList(),
              onChanged: (val) {
                setState(() => _status = val!);
              },
              decoration: const InputDecoration(labelText: 'Status'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: simpanData,
              child: const Text('Simpan Pesanan'),
            ),
          ],
        ),
      ),
    );
  }
}