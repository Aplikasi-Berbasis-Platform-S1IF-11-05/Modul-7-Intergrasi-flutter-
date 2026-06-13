//Galih Crismaningtyas 2311102085
import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  String id;
  String namaEvent;
  String lokasi;
  DateTime tanggal;
  String deskripsi;
  String kategori;
  String userId;

  EventModel({
    required this.id,
    required this.namaEvent,
    required this.lokasi,
    required this.tanggal,
    required this.deskripsi,
    required this.kategori,
    required this.userId,
  });

  factory EventModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return EventModel(
      id: doc.id,
      namaEvent: data['namaEvent'] ?? '',
      lokasi: data['lokasi'] ?? '',
      tanggal: (data['tanggal'] as Timestamp).toDate(),
      deskripsi: data['deskripsi'] ?? '',
      kategori: data['kategori'] ?? '',
      userId: data['userId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'namaEvent': namaEvent,
      'lokasi': lokasi,
      'tanggal': Timestamp.fromDate(tanggal),
      'deskripsi': deskripsi,
      'kategori': kategori,
      'userId': userId,
    };
  }
}
