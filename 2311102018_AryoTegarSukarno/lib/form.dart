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
  final _companyController = TextEditingController();
  final _positionController = TextEditingController();
  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _companyController.text = widget.item!['company_name'];
      _positionController.text = widget.item!['position'];
    }
  }

  Future<void> _saveData() async {
    final userId = _supabase.auth.currentUser!.id;
    final company = _companyController.text;
    final position = _positionController.text;

    if (widget.item == null) {
      await _supabase.from('job_applications').insert({
        'user_id': userId,
        'company_name': company,
        'position': position,
      });
      NotificationService.showNotification(
        title: 'Lamaran Disimpan', 
        body: 'Semoga sukses dengan lamaran $position di $company!'
      );
    } else {
      await _supabase.from('job_applications').update({
        'company_name': company,
        'position': position,
      }).eq('id', widget.item!['id']);
      NotificationService.showNotification(
        title: 'Data Diperbarui', 
        body: 'Data lamaran di $company berhasil diubah.'
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
        backgroundColor: const Color(0xFF0A2647),
        title: Text(widget.item == null ? 'Input Lamaran' : 'Edit Lamaran', style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _companyController, 
              decoration: const InputDecoration(
                labelText: 'Nama Perusahaan',
                hintText: 'Masukkan nama perusahaan...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business),
              )
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _positionController, 
              decoration: const InputDecoration(
                labelText: 'Posisi yang Dilamar',
                hintText: 'Cth: Software Engineer Intern, Data Analyst...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.badge),
              )
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: const Color(0xFF0A2647),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _saveData, 
                child: const Text('Simpan Data', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}