import 'package:flutter/material.dart';
import '../utils/formatters.dart';

class SummaryCard extends StatelessWidget {
  final double saldo;
  final double totalPemasukan;
  final double totalPengeluaran;

  const SummaryCard({
    super.key,
    required this.saldo,
    required this.totalPemasukan,
    required this.totalPengeluaran,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF388E3C)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Saldo',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              Formatters.formatCurrency(saldo),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  label: 'Pemasukan',
                  amount: totalPemasukan,
                  icon: Icons.arrow_downward_rounded,
                  color: const Color(0xFFA5D6A7),
                ),
              ),
              Container(
                height: 48,
                width: 1,
                color: Colors.white24,
              ),
              Expanded(
                child: _buildSummaryItem(
                  label: 'Pengeluaran',
                  amount: totalPengeluaran,
                  icon: Icons.arrow_upward_rounded,
                  color: const Color(0xFFEF9A9A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required String label,
    required double amount,
    required IconData icon,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    Formatters.formatCurrency(amount),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
