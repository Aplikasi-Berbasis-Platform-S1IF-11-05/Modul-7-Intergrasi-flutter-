// Arsya Fathiha Rahman 2311102152 IF-11-05
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/intern_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _internsCollection => _db.collection('interns');

  // Tambah peserta magang
  Future<void> addIntern(InternModel intern) async {
    await _internsCollection.add(intern.toMap());
  }

  // Ambil daftar peserta magang berdasarkan userId
  Stream<List<InternModel>> getInterns(String userId) {
    return _internsCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) =>
              InternModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
      // Sort by createdAt descending di client side
      list.sort((a, b) {
        final aTime = a.createdAt?.millisecondsSinceEpoch ?? 0;
        final bTime = b.createdAt?.millisecondsSinceEpoch ?? 0;
        return bTime.compareTo(aTime);
      });
      return list;
    });
  }

  // Ambil detail peserta magang
  Future<InternModel?> getInternById(String id) async {
    final doc = await _internsCollection.doc(id).get();
    if (doc.exists) {
      return InternModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  // Update data peserta magang
  Future<void> updateIntern(String id, InternModel intern) async {
    await _internsCollection.doc(id).update(intern.toMap());
  }

  // Hapus data peserta magang
  Future<void> deleteIntern(String id) async {
    await _internsCollection.doc(id).delete();
  }

  // Statistik: hitung total peserta
  Stream<int> getTotalInterns(String userId) {
    return _internsCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Statistik: hitung peserta aktif
  Stream<int> getActiveInterns(String userId) {
    return _internsCollection
        .where('userId', isEqualTo: userId)
        .where('statusMagang', isEqualTo: 'Aktif')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Statistik: hitung peserta selesai
  Stream<int> getCompletedInterns(String userId) {
    return _internsCollection
        .where('userId', isEqualTo: userId)
        .where('statusMagang', isEqualTo: 'Selesai')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Statistik: berdasarkan posisi magang
  Stream<Map<String, int>> getInternsByPosition(String userId) {
    return _internsCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final Map<String, int> positionCount = {};
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final posisi = data['posisiMagang'] as String? ?? 'Lainnya';
        positionCount[posisi] = (positionCount[posisi] ?? 0) + 1;
      }
      return positionCount;
    });
  }

  // Simpan FCM Token
  Future<void> saveFcmToken(String userId, String token) async {
    await _db.collection('users').doc(userId).set({
      'fcmToken': token,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
