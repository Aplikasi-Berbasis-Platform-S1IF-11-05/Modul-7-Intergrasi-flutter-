import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NoteService {
  final CollectionReference notes = FirebaseFirestore.instance.collection(
    'notes',
  );

  final FirebaseAuth auth = FirebaseAuth.instance;

  String get currentUserId {
    final user = auth.currentUser;
    if (user == null) {
      throw Exception('User belum login');
    }
    return user.uid;
  }

  Stream<QuerySnapshot> getNotes() {
    return notes.where('userId', isEqualTo: currentUserId).snapshots();
  }

  Future<void> addNote({
    required String title,
    required String description,
  }) async {
    await notes.add({
      'title': title,
      'description': description,
      'userId': currentUserId,
      'createdAt': Timestamp.now(),
    });
  }

  Future<void> updateNote({
    required String id,
    required String title,
    required String description,
  }) async {
    await notes.doc(id).update({'title': title, 'description': description});
  }

  Future<void> deleteNote(String id) async {
    await notes.doc(id).delete();
  }
}
