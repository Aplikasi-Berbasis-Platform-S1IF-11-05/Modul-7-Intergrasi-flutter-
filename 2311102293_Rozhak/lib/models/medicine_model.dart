/// Mendefinisikan struktur data untuk jadwal obat.
///
/// Class ini memuat semua atribut yang dibutuhkan seperti
/// dosis, waktu, serta status penyelesaian.
class MedicineModel {
  final String id;
  final String name;
  final String dose;
  final String time;
  final String notes;
  final bool isDone;
  final String userId;

  MedicineModel({
    required this.id,
    required this.name,
    required this.dose,
    required this.time,
    required this.notes,
    this.isDone = false,
    required this.userId,
  });

  /// Mengonversi objek menjadi format Map.
  ///
  /// Format ini diperlukan agar data dapat disimpan
  /// dengan aman ke dalam struktur NoSQL milik Firestore.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'dose': dose,
      'time': time,
      'notes': notes,
      'isDone': isDone,
      'userId': userId,
    };
  }

  /// Menciptakan objek dari data mentah Firestore.
  ///
  /// Mengambil data Map yang dikembalikan oleh database
  /// dan merakitnya menjadi entitas yang utuh.
  factory MedicineModel.fromMap(String id, Map<String, dynamic> map) {
    return MedicineModel(
      id: id,
      name: map['name'] ?? '',
      dose: map['dose'] ?? '',
      time: map['time'] ?? '',
      notes: map['notes'] ?? '',
      isDone: map['isDone'] ?? false,
      userId: map['userId'] ?? '',
    );
  }
}