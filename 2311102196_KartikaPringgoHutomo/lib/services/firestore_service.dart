//Kartika Pringgo Hutomo
//2311102196
//IF-11-05
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/workout.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String userId;

  FirestoreService({required this.userId});

  // Reference ke collection workouts milik user tertentu
  CollectionReference get _workoutsCollection => 
      _db.collection('users').doc(userId).collection('workouts');

  // Create Workout
  Future<void> addWorkout(Workout workout) async {
    try {
      await _workoutsCollection.add(workout.toMap());
    } catch (e) {
      rethrow;
    }
  }

  // Read Workouts Stream
  Stream<List<Workout>> getWorkouts() {
    return _workoutsCollection
        .orderBy('tanggal', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Workout.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  // Update Workout
  Future<void> updateWorkout(Workout workout) async {
    try {
      await _workoutsCollection.doc(workout.id).update(workout.toMap());
    } catch (e) {
      rethrow;
    }
  }

  // Delete Workout
  Future<void> deleteWorkout(String workoutId) async {
    try {
      await _workoutsCollection.doc(workoutId).delete();
    } catch (e) {
      rethrow;
    }
  }
}
