// Retha Anggreani 2311102265 IF-11-05
import 'package:cloud_firestore/cloud_firestore.dart';

enum StatusBaca { belumDibaca, sedangDibaca, sudahDibaca }

extension StatusBacaExtension on StatusBaca {
  String get label {
    switch (this) {
      case StatusBaca.belumDibaca:
        return 'Belum Dibaca';
      case StatusBaca.sedangDibaca:
        return 'Sedang Dibaca';
      case StatusBaca.sudahDibaca:
        return 'Sudah Dibaca';
    }
  }

  static StatusBaca fromString(String value) {
    switch (value) {
      case 'Sedang Dibaca':
        return StatusBaca.sedangDibaca;
      case 'Sudah Dibaca':
        return StatusBaca.sudahDibaca;
      default:
        return StatusBaca.belumDibaca;
    }
  }
}

class Book {
  final String id;
  final String judul;
  final String penulis;
  final String kategori;
  final int tahunTerbit;
  final StatusBaca statusBaca;
  final String userId;
  final DateTime? createdAt;

  Book({
    required this.id,
    required this.judul,
    required this.penulis,
    required this.kategori,
    required this.tahunTerbit,
    required this.statusBaca,
    required this.userId,
    this.createdAt,
  });

  factory Book.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Book(
      id: doc.id,
      judul: data['judul'] ?? '',
      penulis: data['penulis'] ?? '',
      kategori: data['kategori'] ?? '',
      tahunTerbit: data['tahunTerbit'] ?? 0,
      statusBaca: StatusBacaExtension.fromString(data['statusBaca'] ?? ''),
      userId: data['userId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'judul': judul,
      'penulis': penulis,
      'kategori': kategori,
      'tahunTerbit': tahunTerbit,
      'statusBaca': statusBaca.label,
      'userId': userId,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  Book copyWith({
    String? id,
    String? judul,
    String? penulis,
    String? kategori,
    int? tahunTerbit,
    StatusBaca? statusBaca,
    String? userId,
    DateTime? createdAt,
  }) {
    return Book(
      id: id ?? this.id,
      judul: judul ?? this.judul,
      penulis: penulis ?? this.penulis,
      kategori: kategori ?? this.kategori,
      tahunTerbit: tahunTerbit ?? this.tahunTerbit,
      statusBaca: statusBaca ?? this.statusBaca,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
