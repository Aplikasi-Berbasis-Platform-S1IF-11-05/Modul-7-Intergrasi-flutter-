// Reza Alvonzo - 2311102026 
import 'package:cloud_firestore/cloud_firestore.dart';

class Recipe {
  final String? id;
  final String namaMasakan;
  final String bahan;
  final String langkah;
  final String kategori;
  final String waktuMemasak;
  final String userId;
  final Timestamp? createdAt;

  Recipe({
    this.id,
    required this.namaMasakan,
    required this.bahan,
    required this.langkah,
    required this.kategori,
    required this.waktuMemasak,
    required this.userId,
    this.createdAt,
  });

  factory Recipe.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Recipe(
      id: doc.id,
      namaMasakan: data['namaMasakan'] ?? '',
      bahan: data['bahan'] ?? '',
      langkah: data['langkah'] ?? '',
      kategori: data['kategori'] ?? '',
      waktuMemasak: data['waktuMemasak'] ?? '',
      userId: data['userId'] ?? '',
      createdAt: data['createdAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'namaMasakan': namaMasakan,
      'bahan': bahan,
      'langkah': langkah,
      'kategori': kategori,
      'waktuMemasak': waktuMemasak,
      'userId': userId,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }
}
