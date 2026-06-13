import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'tasks';

  /// Stream daftar tugas milik user tertentu, diurutkan dari terbaru
  Stream<List<TaskModel>> getTasksStream(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final tasks =
          snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList();
      // Sort di sisi client agar tidak butuh composite index
      tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return tasks;
    });
  }

  /// Tambah tugas baru
  Future<void> addTask(TaskModel task) async {
    await _firestore.collection(_collection).add(task.toFirestore());
  }

  /// Update tugas yang ada
  Future<void> updateTask(TaskModel task) async {
    await _firestore
        .collection(_collection)
        .doc(task.id)
        .update(task.toFirestore());
  }

  /// Hapus tugas berdasarkan id
  Future<void> deleteTask(String taskId) async {
    await _firestore.collection(_collection).doc(taskId).delete();
  }

  /// Toggle status tugas (Selesai <-> Belum Selesai)
  Future<void> toggleStatus(TaskModel task) async {
    final newStatus = task.isSelesai
        ? TaskStatus.belumSelesai
        : TaskStatus.selesai;
    await _firestore.collection(_collection).doc(task.id).update({
      'status': newStatus == TaskStatus.selesai ? 'Selesai' : 'Belum Selesai',
    });
  }
}
