//Galih Crismaningtyas 2311102085
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_model.dart';

class FirestoreService {
  final CollectionReference _eventsCollection =
      FirebaseFirestore.instance.collection('events');

  // Create
  Future<void> createEvent(EventModel event) async {
    try {
      await _eventsCollection.add(event.toMap());
    } catch (e) {
      throw e;
    }
  }

  // Read (Stream)
  Stream<List<EventModel>> getEvents() {
    return _eventsCollection
        .orderBy('tanggal', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => EventModel.fromFirestore(doc)).toList();
    });
  }

  // Read by User (Stream)
  Stream<List<EventModel>> getUserEvents(String userId) {
    return _eventsCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => EventModel.fromFirestore(doc)).toList();
    });
  }

  // Update
  Future<void> updateEvent(String id, EventModel event) async {
    try {
      await _eventsCollection.doc(id).update(event.toMap());
    } catch (e) {
      throw e;
    }
  }

  // Delete
  Future<void> deleteEvent(String id) async {
    try {
      await _eventsCollection.doc(id).delete();
    } catch (e) {
      throw e;
    }
  }
}
