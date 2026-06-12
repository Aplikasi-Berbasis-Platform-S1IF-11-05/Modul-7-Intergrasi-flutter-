import 'package:cloud_firestore/cloud_firestore.dart';

enum TaskStatus { belumSelesai, selesai }

class TaskModel {
  final String id;
  final String judul;
  final String deskripsi;
  final DateTime deadline;
  final TaskStatus status;
  final DateTime createdAt;
  final String userId;

  TaskModel({
    required this.id,
    required this.judul,
    required this.deskripsi,
    required this.deadline,
    required this.status,
    required this.createdAt,
    required this.userId,
  });

  bool get isSelesai => status == TaskStatus.selesai;

  String get statusLabel =>
      status == TaskStatus.selesai ? 'Selesai' : 'Belum Selesai';

  factory TaskModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TaskModel(
      id: doc.id,
      judul: data['judul'] ?? '',
      deskripsi: data['deskripsi'] ?? '',
      deadline: (data['deadline'] as Timestamp).toDate(),
      status: data['status'] == 'Selesai'
          ? TaskStatus.selesai
          : TaskStatus.belumSelesai,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      userId: data['userId'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'judul': judul,
      'deskripsi': deskripsi,
      'deadline': Timestamp.fromDate(deadline),
      'status': statusLabel,
      'createdAt': Timestamp.fromDate(createdAt),
      'userId': userId,
    };
  }

  TaskModel copyWith({
    String? id,
    String? judul,
    String? deskripsi,
    DateTime? deadline,
    TaskStatus? status,
    DateTime? createdAt,
    String? userId,
  }) {
    return TaskModel(
      id: id ?? this.id,
      judul: judul ?? this.judul,
      deskripsi: deskripsi ?? this.deskripsi,
      deadline: deadline ?? this.deadline,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
    );
  }
}
