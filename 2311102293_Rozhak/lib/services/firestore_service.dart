import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/medicine_model.dart';
import 'notification_service.dart';

/// Menangani komunikasi data dengan Cloud Firestore.
///
/// Class ini mengelola seluruh operasi penambahan, pembacaan,
/// pembaruan, dan penghapusan jadwal obat pengguna.
class FirestoreService {
  final CollectionReference _medicinesCollection = FirebaseFirestore.instance.collection('medicines');

  /// Menyimpan jadwal obat baru ke dalam Firestore.
  ///
  /// Proses ini juga akan memicu kemunculan notifikasi
  /// sukses setelah data berhasil dimasukkan.
  Future<void> addMedicine(MedicineModel medicine) async {
    await _medicinesCollection.add(medicine.toMap());
    await NotificationService.showNotification(
      title: 'Jadwal Obat Ditambahkan!',
      body: 'Jangan lupa minum ${medicine.name} pada jam ${medicine.time}.',
    );
  }

  /// Memantau perubahan daftar obat secara langsung.
  ///
  /// Data akan terus diperbarui secara otomatis setiap kali
  /// terdapat perubahan di database Firebase.
  Stream<List<MedicineModel>> getMedicines(String userId) {
    return _medicinesCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MedicineModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .toList());
  }

  /// Mengubah status konsumsi obat.
  ///
  /// Menandai jadwal sebagai sudah diminum atau
  /// mengembalikannya ke status belum diminum.
  Future<void> toggleMedicineStatus(String id, bool currentStatus) async {
    await _medicinesCollection.doc(id).update({'isDone': !currentStatus});
  }

  /// Menghapus jadwal obat dari database.
  ///
  /// Data akan dihilangkan secara permanen dan
  /// jadwal notifikasi yang terkait akan dibatalkan.
  Future<void> deleteMedicine(String id) async {
    await _medicinesCollection.doc(id).delete();
  }
}