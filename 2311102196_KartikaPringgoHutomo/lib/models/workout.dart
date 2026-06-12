//Kartika Pringgo Hutomo
//2311102196
//IF-11-05
class Workout {
  final String id;
  final String namaAktivitas;
  final int durasi; // dalam menit
  final int kalori;
  final DateTime tanggal;
  final String catatan;
  final String userId;

  Workout({
    required this.id,
    required this.namaAktivitas,
    required this.durasi,
    required this.kalori,
    required this.tanggal,
    required this.catatan,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'namaAktivitas': namaAktivitas,
      'durasi': durasi,
      'kalori': kalori,
      'tanggal': tanggal.toIso8601String(),
      'catatan': catatan,
      'userId': userId,
    };
  }

  factory Workout.fromMap(Map<String, dynamic> map, String documentId) {
    return Workout(
      id: documentId,
      namaAktivitas: map['namaAktivitas'] ?? '',
      durasi: map['durasi']?.toInt() ?? 0,
      kalori: map['kalori']?.toInt() ?? 0,
      tanggal: map['tanggal'] != null ? DateTime.parse(map['tanggal']) : DateTime.now(),
      catatan: map['catatan'] ?? '',
      userId: map['userId'] ?? '',
    );
  }
}
