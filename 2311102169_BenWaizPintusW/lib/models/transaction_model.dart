import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType { pemasukan, pengeluaran }

class TransactionModel {
  final String id;
  final String kategori;
  final double nominal;
  final String keterangan;
  final DateTime tanggal;
  final TransactionType tipe;
  final String userId;

  TransactionModel({
    required this.id,
    required this.kategori,
    required this.nominal,
    required this.keterangan,
    required this.tanggal,
    required this.tipe,
    required this.userId,
  });

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id: doc.id,
      kategori: data['kategori'] ?? '',
      nominal: (data['nominal'] as num).toDouble(),
      keterangan: data['keterangan'] ?? '',
      tanggal: (data['tanggal'] as Timestamp).toDate(),
      tipe: data['tipe'] == 'Pemasukan'
          ? TransactionType.pemasukan
          : TransactionType.pengeluaran,
      userId: data['userId'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'kategori': kategori,
      'nominal': nominal,
      'keterangan': keterangan,
      'tanggal': Timestamp.fromDate(tanggal),
      'tipe': tipe == TransactionType.pemasukan ? 'Pemasukan' : 'Pengeluaran',
      'userId': userId,
    };
  }

  TransactionModel copyWith({
    String? id,
    String? kategori,
    double? nominal,
    String? keterangan,
    DateTime? tanggal,
    TransactionType? tipe,
    String? userId,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      kategori: kategori ?? this.kategori,
      nominal: nominal ?? this.nominal,
      keterangan: keterangan ?? this.keterangan,
      tanggal: tanggal ?? this.tanggal,
      tipe: tipe ?? this.tipe,
      userId: userId ?? this.userId,
    );
  }
}
