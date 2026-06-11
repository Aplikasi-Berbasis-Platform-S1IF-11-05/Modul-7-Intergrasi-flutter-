// Arsya Fathiha Rahman 2311102152 IF-11-05
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../models/intern_model.dart';
import '../services/firestore_service.dart';
import '../notifications/notification_service.dart';

class AddInternScreen extends StatefulWidget {
  const AddInternScreen({super.key});

  @override
  State<AddInternScreen> createState() => _AddInternScreenState();
}

class _AddInternScreenState extends State<AddInternScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();

  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _teleponController = TextEditingController();
  final _sekolahController = TextEditingController();
  final _jurusanController = TextEditingController();
  final _posisiController = TextEditingController();
  final _alamatController = TextEditingController();
  final _tanggalMulaiController = TextEditingController();
  final _tanggalSelesaiController = TextEditingController();

  String _statusMagang = 'Aktif';
  bool _isLoading = false;

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _teleponController.dispose();
    _sekolahController.dispose();
    _jurusanController.dispose();
    _posisiController.dispose();
    _alamatController.dispose();
    _tanggalMulaiController.dispose();
    _tanggalSelesaiController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFEC4899),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      controller.text = DateFormat('dd/MM/yyyy').format(picked);
    }
  }

  Future<void> _saveIntern() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      final intern = InternModel(
        namaLengkap: _namaController.text.trim(),
        email: _emailController.text.trim(),
        nomorTelepon: _teleponController.text.trim(),
        asalSekolahKampus: _sekolahController.text.trim(),
        jurusan: _jurusanController.text.trim(),
        posisiMagang: _posisiController.text.trim(),
        tanggalMulai: _tanggalMulaiController.text.trim(),
        tanggalSelesai: _tanggalSelesaiController.text.trim(),
        statusMagang: _statusMagang,
        alamat: _alamatController.text.trim(),
        userId: userId,
      );

      await _firestoreService.addIntern(intern);

      // Kirim notifikasi
      await NotificationService.instance.showCrudNotification(
        'MagangHub',
        'Data peserta magang berhasil ditambahkan.',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data peserta berhasil ditambahkan!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menambahkan data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Peserta Magang'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Email tidak boleh kosong';
                  if (!v.contains('@')) return 'Format email tidak valid';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _teleponController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Nomor Telepon',
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (v) => v == null || v.isEmpty
                    ? 'Nomor telepon tidak boleh kosong'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _sekolahController,
                decoration: const InputDecoration(
                  labelText: 'Asal Sekolah/Kampus',
                  prefixIcon: Icon(Icons.school),
                ),
                validator: (v) => v == null || v.isEmpty
                    ? 'Asal sekolah/kampus tidak boleh kosong'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _jurusanController,
                decoration: const InputDecoration(
                  labelText: 'Jurusan',
                  prefixIcon: Icon(Icons.book),
                ),
                validator: (v) => v == null || v.isEmpty
                    ? 'Jurusan tidak boleh kosong'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _posisiController,
                decoration: const InputDecoration(
                  labelText: 'Posisi Magang',
                  prefixIcon: Icon(Icons.work),
                ),
                validator: (v) => v == null || v.isEmpty
                    ? 'Posisi magang tidak boleh kosong'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _tanggalMulaiController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Tanggal Mulai',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () => _selectDate(_tanggalMulaiController),
                validator: (v) => v == null || v.isEmpty
                    ? 'Tanggal mulai tidak boleh kosong'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _tanggalSelesaiController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Tanggal Selesai',
                  prefixIcon: Icon(Icons.calendar_month),
                ),
                onTap: () => _selectDate(_tanggalSelesaiController),
                validator: (v) => v == null || v.isEmpty
                    ? 'Tanggal selesai tidak boleh kosong'
                    : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _statusMagang,
                decoration: const InputDecoration(
                  labelText: 'Status Magang',
                  prefixIcon: Icon(Icons.info_outline),
                ),
                items: const [
                  DropdownMenuItem(value: 'Aktif', child: Text('Aktif')),
                  DropdownMenuItem(value: 'Selesai', child: Text('Selesai')),
                ],
                onChanged: (value) {
                  setState(() => _statusMagang = value ?? 'Aktif');
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _alamatController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Alamat',
                  prefixIcon: Icon(Icons.location_on),
                  alignLabelWithHint: true,
                ),
                validator: (v) => v == null || v.isEmpty
                    ? 'Alamat tidak boleh kosong'
                    : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveIntern,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Simpan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
