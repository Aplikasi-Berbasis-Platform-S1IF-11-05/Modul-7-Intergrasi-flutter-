import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference pins =
      FirebaseFirestore.instance.collection(
    'pins',
  );

  Future<void> addPin({
    required String title,
    required String imageUrl,
    required String description,
  }) async {
    await pins.add({
      'title': title,
      'imageUrl': imageUrl,
      'description': description,
      'createdAt': Timestamp.now(),
    });
  }

  Future<void> updatePin({
    required String id,
    required String title,
    required String imageUrl,
    required String description,
  }) async {
    await pins.doc(id).update({
      'title': title,
      'imageUrl': imageUrl,
      'description': description,
    });
  }

  Future<void> deletePin(String id) async {
    await pins.doc(id).delete();
  }

  Stream<QuerySnapshot> getPins() {
    return FirebaseFirestore.instance
        .collection('pins')
        .snapshots();
  }
}