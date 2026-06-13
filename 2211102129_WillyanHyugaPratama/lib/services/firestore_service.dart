//Willyan Hyuga Pratama 2211102129
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/skill_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'skills';

  // Get skills stream for a specific user
  Stream<List<SkillModel>> getSkills(String userId) {
    return _db
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final skills = snapshot.docs
          .map((doc) => SkillModel.fromMap(doc.data(), doc.id))
          .toList();
      // Sort di client side agar tidak perlu composite index
      skills.sort((a, b) => b.tanggalDiperoleh.compareTo(a.tanggalDiperoleh));
      return skills;
    });
  }

  // Add a new skill
  Future<void> addSkill(SkillModel skill) async {
    await _db.collection(_collection).add(skill.toMap());
  }

  // Update an existing skill
  Future<void> updateSkill(String id, SkillModel skill) async {
    await _db.collection(_collection).doc(id).update(skill.toMap());
  }

  // Delete a skill
  Future<void> deleteSkill(String id) async {
    await _db.collection(_collection).doc(id).delete();
  }

  // Get skill statistics for dashboard
  Future<Map<String, int>> getSkillStats(String userId) async {
    final snapshot = await _db
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .get();

    Map<String, int> stats = {
      'Beginner': 0,
      'Intermediate': 0,
      'Advanced': 0,
      'Expert': 0,
    };

    for (var doc in snapshot.docs) {
      final level = doc.data()['level'] as String? ?? 'Beginner';
      stats[level] = (stats[level] ?? 0) + 1;
    }

    return stats;
  }
}
