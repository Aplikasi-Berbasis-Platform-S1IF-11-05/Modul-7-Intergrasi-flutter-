// Arsya Fathiha Rahman 2311102152 IF-11-05
import 'package:flutter/material.dart';
import '../models/intern_model.dart';
import '../services/firestore_service.dart';
import '../notifications/notification_service.dart';
import 'edit_intern_screen.dart';

class InternDetailScreen extends StatelessWidget {
  final InternModel intern;

  const InternDetailScreen({super.key, required this.intern});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Peserta'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditInternScreen(intern: intern),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Hapus Data'),
                  content: Text(
                    'Yakin ingin menghapus data ${intern.namaLengkap}?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text(
                        'Hapus',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
              if (confirm == true && intern.id != null) {
                await FirestoreService().deleteIntern(intern.id!);
                await NotificationService.instance.showCrudNotification(
                  'MagangHub',
                  'Data peserta magang berhasil dihapus.',
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Data berhasil dihapus'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: const Color(0xFFEC4899).withValues(alpha: 0.1),
                      child: Text(
                        intern.namaLengkap.isNotEmpty
                            ? intern.namaLengkap[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFEC4899),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      intern.namaLengkap,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      intern.posisiMagang,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: intern.statusMagang == 'Aktif'
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        intern.statusMagang,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: intern.statusMagang == 'Aktif'
                              ? Colors.green
                              : Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Detail Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informasi Peserta',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(Icons.email, 'Email', intern.email),
                    _buildDetailRow(
                        Icons.phone, 'Telepon', intern.nomorTelepon),
                    _buildDetailRow(
                        Icons.school, 'Asal', intern.asalSekolahKampus),
                    _buildDetailRow(Icons.book, 'Jurusan', intern.jurusan),
                    _buildDetailRow(
                        Icons.work, 'Posisi', intern.posisiMagang),
                    _buildDetailRow(Icons.calendar_today, 'Mulai',
                        intern.tanggalMulai),
                    _buildDetailRow(Icons.calendar_month, 'Selesai',
                        intern.tanggalSelesai),
                    _buildDetailRow(
                        Icons.location_on, 'Alamat', intern.alamat),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFFEC4899)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value.isNotEmpty ? value : '-',
                  style: const TextStyle(fontSize: 15),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
