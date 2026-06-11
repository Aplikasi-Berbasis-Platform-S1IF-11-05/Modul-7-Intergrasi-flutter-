import 'package:flutter/material.dart';
import '../models/medicine_model.dart';

/// Menampilkan komponen kartu informasi obat.
///
/// Widget ini memuat nama, dosis, waktu minum,
/// serta tombol untuk mengubah status dan menghapus jadwal.
class MedicineCard extends StatelessWidget {
  final MedicineModel medicine;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const MedicineCard({
    super.key,
    required this.medicine,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.zero,
        border: Border.all(color: const Color(0xFFEBEBEB), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onToggle,
            child: Container(
              margin: const EdgeInsets.only(top: 2, right: 16),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: medicine.isDone ? Colors.black : Colors.transparent,
                borderRadius: BorderRadius.zero,
                border: Border.all(
                  color: medicine.isDone ? Colors.black : const Color(0xFFD4D4D4),
                  width: 1.5,
                ),
              ),
              child: medicine.isDone
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medicine.name,
                  style: TextStyle(
                    color: medicine.isDone ? const Color(0xFFA3A3A3) : Colors.black,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                    decoration: medicine.isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4.0),
                Row(
                  children: [
                    Text(
                      medicine.dose,
                      style: const TextStyle(color: Color(0xFF737373), fontSize: 13.0, fontWeight: FontWeight.w500),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6.0),
                      child: Text('•', style: TextStyle(color: Color(0xFFD4D4D4))),
                    ),
                    Text(
                      medicine.time,
                      style: const TextStyle(color: Color(0xFF737373), fontSize: 13.0, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                if (medicine.notes.isNotEmpty) ...[
                  const SizedBox(height: 8.0),
                  Text(
                    medicine.notes,
                    style: const TextStyle(
                      color: Color(0xFFA3A3A3),
                      fontSize: 12.0,
                    ),
                  ),
                ]
              ],
            ),
          ),
          GestureDetector(
            onTap: onDelete,
            child: const Padding(
              padding: EdgeInsets.only(left: 12.0),
              child: Icon(Icons.close, color: Color(0xFFA3A3A3), size: 20),
            ),
          ),
        ],
      ),
    );
  }
}