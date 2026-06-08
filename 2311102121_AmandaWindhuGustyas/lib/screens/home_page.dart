// NIM: 2311102121
// Nama: Amanda Windhu Gustyas
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../services/notification_service.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AppFirebaseService _firebaseService = AppFirebaseService();
  final NotificationService _notificationService = NotificationService();

  Widget _buildDialogTextField(String label, TextEditingController controller, IconData icon, {TextInputType type = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 14)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: type,
          decoration: InputDecoration(
            hintText: "Masukkan $label",
            prefixIcon: Icon(icon),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  void _showMahasiswaDialog({String? docId, String? initialNama, String? initialNim, String? initialJurusan}) {
    final namaController = TextEditingController(text: initialNama);
    final nimController = TextEditingController(text: initialNim);
    final jurusanController = TextEditingController(text: initialJurusan);
    final isEdit = docId != null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40, height: 4,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C63FF).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isEdit ? Icons.edit_rounded : Icons.person_add_rounded,
                        color: const Color(0xFF6C63FF),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEdit ? "Edit Data Mahasiswa" : "Tambah Mahasiswa Baru",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          isEdit ? "Ubah data yang diperlukan" : "Isi data mahasiswa dengan lengkap",
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Nama
                _buildModernField(label: "Nama Lengkap", controller: namaController, icon: Icons.person_rounded, hint: "Contoh: Budi Santoso"),
                const SizedBox(height: 16),

                // NIM
                _buildModernField(label: "NIM", controller: nimController, icon: Icons.badge_rounded, hint: "Contoh: 2311102121", type: TextInputType.number),
                const SizedBox(height: 16),

                // Jurusan
                _buildModernField(label: "Program Studi", controller: jurusanController, icon: Icons.school_rounded, hint: "Contoh: Informatika"),
                const SizedBox(height: 28),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text("Batal", style: TextStyle(color: Colors.grey)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (namaController.text.trim().isEmpty || nimController.text.trim().isEmpty || jurusanController.text.trim().isEmpty) return;
                          try {
                            if (!isEdit) {
                              await _firebaseService.addMahasiswa(
                                namaController.text.trim(),
                                nimController.text.trim(),
                                jurusanController.text.trim(),
                              );
                              _notificationService.showNotification(id: 1, title: "Berhasil!", body: "Data mahasiswa berhasil ditambahkan.");
                            } else {
                              await _firebaseService.updateMahasiswa(
                                docId,
                                namaController.text.trim(),
                                nimController.text.trim(),
                                jurusanController.text.trim(),
                              );
                              _notificationService.showNotification(id: 2, title: "Berhasil!", body: "Data mahasiswa berhasil diupdate.");
                            }
                            if (!context.mounted) return;
                            Navigator.pop(context);
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString()), backgroundColor: Colors.redAccent),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text(isEdit ? "Simpan Perubahan" : "Tambah Data", style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModernField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    TextInputType type = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: type,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon),
          ),
        ),
      ],
    );
  }


  void _deleteMahasiswa(String docId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Konfirmasi Hapus"),
        content: const Text("Apakah Anda yakin ingin menghapus data mahasiswa ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _firebaseService.deleteMahasiswa(docId);
                _notificationService.showNotification(
                  id: 3,
                  title: "Dihapus!",
                  body: "Data mahasiswa berhasil dihapus.",
                );
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString()), backgroundColor: Colors.redAccent),
                  );
                }
              }
            },
            child: const Text("Hapus"),
          ),
        ],
      )
    );
  }

  void _logout() async {
    await _firebaseService.logout();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Data Mahasiswa",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
            ),
            Text(
              "Amanda Windhu Gustyas - 2311102121",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            alignment: Alignment.centerLeft,
            child: const Text(
              "Daftar Mahasiswa Terdaftar",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firebaseService.getMahasiswaStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.group_off_rounded, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          "Belum ada data mahasiswa.\nTekan + untuk menambah data.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[500], fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var doc = snapshot.data!.docs[index];
                    var data = doc.data() as Map<String, dynamic>;
                    String initial = (data['nama'] ?? '?').toString().isNotEmpty 
                        ? (data['nama'] as String)[0].toUpperCase() 
                        : '?';

                    return Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        leading: CircleAvatar(
                          radius: 24,
                          backgroundColor: const Color(0xFF6C63FF).withOpacity(0.2),
                          child: Text(
                            initial,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6C63FF),
                              fontSize: 20,
                            ),
                          ),
                        ),
                        title: Text(
                          data['nama'] ?? 'Tanpa Nama',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("NIM: ${data['nim'] ?? '-'}"),
                              Text("Prodi: ${data['jurusan'] ?? '-'}"),
                            ],
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.edit_rounded, color: Colors.blue, size: 20),
                                onPressed: () => _showMahasiswaDialog(
                                  docId: doc.id,
                                  initialNama: data['nama'],
                                  initialNim: data['nim'],
                                  initialJurusan: data['jurusan'],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.delete_rounded, color: Colors.red, size: 20),
                                onPressed: () => _deleteMahasiswa(doc.id),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showMahasiswaDialog(),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add_rounded),
        label: const Text("Tambah Data", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
