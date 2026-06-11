// Arsya Fathiha Rahman 2311102152 IF-11-05
import 'package:cloud_firestore/cloud_firestore.dart';

class InternModel {
  final String? id;
  final String namaLengkap;
  final String email;
  final String nomorTelepon;
  final String asalSekolahKampus;
  final String jurusan;
  final String posisiMagang;
  final String tanggalMulai;
  final String tanggalSelesai;
  final String statusMagang;
  final String alamat;
  final String userId;
  final Timestamp? createdAt;

  InternModel({
    this.id,
    required this.namaLengkap,
    required this.email,
    required this.nomorTelepon,
    required this.asalSekolahKampus,
    required this.jurusan,
    required this.posisiMagang,
    required this.tanggalMulai,
    required this.tanggalSelesai,
    required this.statusMagang,
    required this.alamat,
    required this.userId,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'namaLengkap': namaLengkap,
      'email': email,
      'nomorTelepon': nomorTelepon,
      'asalSekolahKampus': asalSekolahKampus,
      'jurusan': jurusan,
      'posisiMagang': posisiMagang,
      'tanggalMulai': tanggalMulai,
      'tanggalSelesai': tanggalSelesai,
      'statusMagang': statusMagang,
      'alamat': alamat,
      'userId': userId,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  factory InternModel.fromMap(Map<String, dynamic> map, String documentId) {
    return InternModel(
      id: documentId,
      namaLengkap: map['namaLengkap'] ?? '',
      email: map['email'] ?? '',
      nomorTelepon: map['nomorTelepon'] ?? '',
      asalSekolahKampus: map['asalSekolahKampus'] ?? '',
      jurusan: map['jurusan'] ?? '',
      posisiMagang: map['posisiMagang'] ?? '',
      tanggalMulai: map['tanggalMulai'] ?? '',
      tanggalSelesai: map['tanggalSelesai'] ?? '',
      statusMagang: map['statusMagang'] ?? 'Aktif',
      alamat: map['alamat'] ?? '',
      userId: map['userId'] ?? '',
      createdAt: map['createdAt'] as Timestamp?,
    );
  }

  InternModel copyWith({
    String? id,
    String? namaLengkap,
    String? email,
    String? nomorTelepon,
    String? asalSekolahKampus,
    String? jurusan,
    String? posisiMagang,
    String? tanggalMulai,
    String? tanggalSelesai,
    String? statusMagang,
    String? alamat,
    String? userId,
    Timestamp? createdAt,
  }) {
    return InternModel(
      id: id ?? this.id,
      namaLengkap: namaLengkap ?? this.namaLengkap,
      email: email ?? this.email,
      nomorTelepon: nomorTelepon ?? this.nomorTelepon,
      asalSekolahKampus: asalSekolahKampus ?? this.asalSekolahKampus,
      jurusan: jurusan ?? this.jurusan,
      posisiMagang: posisiMagang ?? this.posisiMagang,
      tanggalMulai: tanggalMulai ?? this.tanggalMulai,
      tanggalSelesai: tanggalSelesai ?? this.tanggalSelesai,
      statusMagang: statusMagang ?? this.statusMagang,
      alamat: alamat ?? this.alamat,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
