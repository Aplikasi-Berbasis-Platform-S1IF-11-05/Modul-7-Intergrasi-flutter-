//Willyan Hyuga Pratama 2211102129
import 'package:cloud_firestore/cloud_firestore.dart';

class SkillModel {
  final String? id;
  final String namaSkill;
  final String level; // Beginner, Intermediate, Advanced, Expert
  final String sertifikatUrl;
  final DateTime tanggalDiperoleh;
  final String userId;

  SkillModel({
    this.id,
    required this.namaSkill,
    required this.level,
    required this.sertifikatUrl,
    required this.tanggalDiperoleh,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'namaSkill': namaSkill,
      'level': level,
      'sertifikatUrl': sertifikatUrl,
      'tanggalDiperoleh': Timestamp.fromDate(tanggalDiperoleh),
      'userId': userId,
    };
  }

  factory SkillModel.fromMap(Map<String, dynamic> map, String docId) {
    return SkillModel(
      id: docId,
      namaSkill: map['namaSkill'] ?? '',
      level: map['level'] ?? 'Beginner',
      sertifikatUrl: map['sertifikatUrl'] ?? '',
      tanggalDiperoleh: (map['tanggalDiperoleh'] as Timestamp?)?.toDate() ??
          DateTime.now(),
      userId: map['userId'] ?? '',
    );
  }

  static int levelToIndex(String level) {
    switch (level) {
      case 'Beginner':
        return 1;
      case 'Intermediate':
        return 2;
      case 'Advanced':
        return 3;
      case 'Expert':
        return 4;
      default:
        return 1;
    }
  }

  static double levelToProgress(String level) {
    switch (level) {
      case 'Beginner':
        return 0.25;
      case 'Intermediate':
        return 0.50;
      case 'Advanced':
        return 0.75;
      case 'Expert':
        return 1.0;
      default:
        return 0.25;
    }
  }
}
