import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firestore_service.dart';
import '../../services/notification_service.dart';
import '../../models/medicine_model.dart';
import '../../widgets/medicine_card.dart';

/// Menyajikan daftar jadwal minum obat harian.
///
/// Halaman ini menampilkan data obat secara real-time
/// dan menyediakan akses untuk menambah jadwal baru.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreService _firestoreService = FirestoreService();
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _doseController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    NotificationService.requestPermission();
  }

  void _showAddBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: const Color(0xFFEBEBEB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text('Tambah Jadwal Baru', style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
            const SizedBox(height: 8),
            const Text('Silakan masukkan detail jadwal obat di bawah ini.', style: TextStyle(color: Colors.black54, fontSize: 14)),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.black, fontSize: 16),
              decoration: InputDecoration(
                labelText: 'Nama Obat',
                labelStyle: const TextStyle(color: Colors.black54),
                hintText: 'Contoh: Paracetamol',
                hintStyle: const TextStyle(color: Color(0xFFD4D4D4)),
                filled: true,
                fillColor: const Color(0xFFF9F9F9),
                border: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide.none),
                focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: Colors.black)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _doseController,
              style: const TextStyle(color: Colors.black, fontSize: 16),
              decoration: InputDecoration(
                labelText: 'Dosis',
                labelStyle: const TextStyle(color: Colors.black54),
                hintText: 'Contoh: 1 Tablet',
                hintStyle: const TextStyle(color: Color(0xFFD4D4D4)),
                filled: true,
                fillColor: const Color(0xFFF9F9F9),
                border: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide.none),
                focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: Colors.black)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _timeController,
              style: const TextStyle(color: Colors.black, fontSize: 16),
              decoration: const InputDecoration(
                labelText: 'Jam Minum (HH:mm)',
                labelStyle: TextStyle(color: Colors.black54),
                hintText: 'Contoh: 08:00',
                hintStyle: TextStyle(color: Color(0xFFD4D4D4)),
                filled: true,
                fillColor: Color(0xFFF9F9F9),
                border: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: Colors.black)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              style: const TextStyle(color: Colors.black, fontSize: 16),
              decoration: const InputDecoration(
                labelText: 'Catatan Khusus (Opsional)',
                labelStyle: TextStyle(color: Colors.black54),
                hintText: 'Contoh: Sesudah makan',
                hintStyle: TextStyle(color: Color(0xFFD4D4D4)),
                filled: true,
                fillColor: Color(0xFFF9F9F9),
                border: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: Colors.black)),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                ),
                onPressed: () async {
                  if (_nameController.text.isNotEmpty) {
                    final medName = _nameController.text;
                    final med = MedicineModel(
                      id: '',
                      name: medName,
                      dose: _doseController.text,
                      time: _timeController.text,
                      notes: _notesController.text,
                      userId: userId,
                    );
                    await _firestoreService.addMedicine(med);
                    NotificationService.showNotification(
                      title: 'Berhasil Disimpan',
                      body: 'Jadwal minum $medName berhasil ditambahkan.',
                    );
                    _nameController.clear(); _doseController.clear(); _timeController.clear(); _notesController.clear();
                    Navigator.pop(context);
                  }
                },
                child: const Text('Simpan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0, 
        centerTitle: false,
        title: const Text('Jadwal Rawat.in', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: -0.3)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: const Color(0xFFEBEBEB),
            height: 1.0,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black, size: 22),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<List<MedicineModel>>(
          stream: _firestoreService.getMedicines(userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.black));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text('Belum ada jadwal obat.', style: TextStyle(color: Colors.black54, fontSize: 15)),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.only(top: 12, left: 16, right: 16, bottom: 20),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final medicine = snapshot.data![index];
                
                if (!medicine.isDone && medicine.id.isNotEmpty) {
                  NotificationService.scheduleMedicineNotification(medicine);
                } else if (medicine.id.isNotEmpty) {
                  NotificationService.cancelNotification(medicine.id);
                }

                return MedicineCard(
                  medicine: medicine,
                  onToggle: () {
                    _firestoreService.toggleMedicineStatus(medicine.id, medicine.isDone);
                    if (!medicine.isDone) {
                      NotificationService.showNotification(
                        title: 'Status Diperbarui',
                        body: '${medicine.name} telah diminum.',
                      );
                    } else {
                      NotificationService.showNotification(
                        title: 'Status Diperbarui',
                        body: '${medicine.name} ditandai belum diminum.',
                      );
                    }
                  },
                  onDelete: () {
                    _firestoreService.deleteMedicine(medicine.id);
                    NotificationService.cancelNotification(medicine.id);
                    NotificationService.showNotification(
                      title: 'Berhasil Dihapus',
                      body: 'Jadwal ${medicine.name} telah dihapus.',
                    );
                  },
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          color: Colors.white,
          child: const Text(
            'NIM: 2311102293 - Nama: Rozhak',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black38),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        onPressed: _showAddBottomSheet,
        elevation: 4,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        child: const Icon(Icons.add, size: 26),
      ),
    );
  }
}