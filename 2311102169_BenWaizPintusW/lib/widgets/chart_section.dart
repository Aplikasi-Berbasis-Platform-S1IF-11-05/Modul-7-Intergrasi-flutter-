import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/transaction_model.dart';
import '../utils/formatters.dart';

class ChartSection extends StatefulWidget {
  final List<TransactionModel> transactions;
  final double totalPemasukan;
  final double totalPengeluaran;

  const ChartSection({
    super.key,
    required this.transactions,
    required this.totalPemasukan,
    required this.totalPengeluaran,
  });

  @override
  State<ChartSection> createState() => _ChartSectionState();
}

class _ChartSectionState extends State<ChartSection> {
  int _touchedIndex = -1;

  // Cache kalkulasi supaya tidak dihitung ulang tiap rebuild (misal saat touch pie)
  late Map<String, Map<String, double>> _monthlyData;
  late Map<String, double> _pengeluaranByKategori;

  @override
  void initState() {
    super.initState();
    _computeData();
  }

  @override
  void didUpdateWidget(ChartSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Hanya hitung ulang jika data transaksi berubah
    if (oldWidget.transactions != widget.transactions) {
      _computeData();
    }
  }

  void _computeData() {
    _monthlyData = _getMonthlyData();
    _pengeluaranByKategori = _getKategoriData(TransactionType.pengeluaran);
  }

  /// Hitung data bar chart: pemasukan & pengeluaran per bulan (6 bulan terakhir)
  Map<String, Map<String, double>> _getMonthlyData() {
    final now = DateTime.now();
    final months = <String, Map<String, double>>{};

    for (int i = 5; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      final key = Formatters.formatMonthYear(date);
      months[key] = {'pemasukan': 0, 'pengeluaran': 0};
    }

    for (final t in widget.transactions) {
      final key = Formatters.formatMonthYear(t.tanggal);
      if (months.containsKey(key)) {
        if (t.tipe == TransactionType.pemasukan) {
          months[key]!['pemasukan'] = (months[key]!['pemasukan'] ?? 0) + t.nominal;
        } else {
          months[key]!['pengeluaran'] =
              (months[key]!['pengeluaran'] ?? 0) + t.nominal;
        }
      }
    }
    return months;
  }

  /// Hitung data per kategori untuk pie chart
  Map<String, double> _getKategoriData(TransactionType tipe) {
    final data = <String, double>{};
    for (final t in widget.transactions.where((t) => t.tipe == tipe)) {
      data[t.kategori] = (data[t.kategori] ?? 0) + t.nominal;
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    final keys = _monthlyData.keys.toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overview Cards
          Row(
            children: [
              Expanded(
                child: _buildMiniCard(
                  'Total Pemasukan',
                  widget.totalPemasukan,
                  const Color(0xFF2E7D32),
                  Icons.arrow_downward_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMiniCard(
                  'Total Pengeluaran',
                  widget.totalPengeluaran,
                  const Color(0xFFD32F2F),
                  Icons.arrow_upward_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Bar Chart
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pemasukan & Pengeluaran (6 Bulan)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B5E20),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildLegend('Pemasukan', const Color(0xFF2E7D32)),
                      const SizedBox(width: 16),
                      _buildLegend('Pengeluaran', const Color(0xFFD32F2F)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: _monthlyData.values
                            .every((v) => v['pemasukan'] == 0 && v['pengeluaran'] == 0)
                        ? const Center(
                            child: Text(
                              'Belum ada data',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : BarChart(
                            BarChartData(
                              maxY: _getMaxY(_monthlyData) * 1.2,
                              barGroups: List.generate(keys.length, (i) {
                                final v = _monthlyData[keys[i]]!;
                                return BarChartGroupData(
                                  x: i,
                                  barRods: [
                                    BarChartRodData(
                                      toY: v['pemasukan']!,
                                      color: const Color(0xFF2E7D32),
                                      width: 10,
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(4)),
                                    ),
                                    BarChartRodData(
                                      toY: v['pengeluaran']!,
                                      color: const Color(0xFFD32F2F),
                                      width: 10,
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(4)),
                                    ),
                                  ],
                                );
                              }),
                              titlesData: FlTitlesData(
                                leftTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (v, _) {
                                      final idx = v.toInt();
                                      if (idx < 0 || idx >= keys.length) {
                                        return const SizedBox.shrink();
                                      }
                                      final parts = keys[idx].split(' ');
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          parts[0],
                                          style: const TextStyle(fontSize: 10),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              gridData: FlGridData(
                                show: true,
                                getDrawingHorizontalLine: (v) => FlLine(
                                  color: Colors.grey.withValues(alpha: 0.2),
                                  strokeWidth: 1,
                                ),
                                drawVerticalLine: false,
                              ),
                              borderData: FlBorderData(show: false),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Pie Chart - Pengeluaran per Kategori
          if (_pengeluaranByKategori.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pengeluaran per Kategori',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        SizedBox(
                          height: 160,
                          width: 160,
                          child: PieChart(
                            PieChartData(
                              pieTouchData: PieTouchData(
                                touchCallback: (event, response) {
                                  setState(() {
                                    _touchedIndex = response?.touchedSection
                                            ?.touchedSectionIndex ??
                                        -1;
                                  });
                                },
                              ),
                              sections: _buildPieSections(
                                  _pengeluaranByKategori),
                              centerSpaceRadius: 40,
                              sectionsSpace: 2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            children: _buildPieLegend(_pengeluaranByKategori),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieSections(Map<String, double> data) {
    final colors = [
      const Color(0xFF2E7D32),
      const Color(0xFFD32F2F),
      const Color(0xFF1565C0),
      const Color(0xFFF57F17),
      const Color(0xFF6A1B9A),
      const Color(0xFF00838F),
      const Color(0xFF558B2F),
      const Color(0xFF4E342E),
    ];
    final total = data.values.fold(0.0, (a, b) => a + b);
    final keys = data.keys.toList();

    return List.generate(keys.length, (i) {
      final isTouched = i == _touchedIndex;
      return PieChartSectionData(
        value: data[keys[i]]!,
        title: '${((data[keys[i]]! / total) * 100).toStringAsFixed(1)}%',
        radius: isTouched ? 55 : 45,
        color: colors[i % colors.length],
        titleStyle: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      );
    });
  }

  List<Widget> _buildPieLegend(Map<String, double> data) {
    final colors = [
      const Color(0xFF2E7D32),
      const Color(0xFFD32F2F),
      const Color(0xFF1565C0),
      const Color(0xFFF57F17),
      const Color(0xFF6A1B9A),
      const Color(0xFF00838F),
      const Color(0xFF558B2F),
      const Color(0xFF4E342E),
    ];
    return data.entries.toList().asMap().entries.map((entry) {
      final i = entry.key;
      final k = entry.value;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: colors[i % colors.length],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                k.key,
                style: const TextStyle(fontSize: 11),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildMiniCard(
      String title, double amount, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(title,
                  style: TextStyle(
                      color: color, fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              Formatters.formatCurrency(amount),
              style: TextStyle(
                  color: color, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  double _getMaxY(Map<String, Map<String, double>> data) {
    double max = 0;
    for (final v in data.values) {
      if ((v['pemasukan'] ?? 0) > max) max = v['pemasukan']!;
      if ((v['pengeluaran'] ?? 0) > max) max = v['pengeluaran']!;
    }
    return max == 0 ? 100 : max;
  }
}
