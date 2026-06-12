//Kartika Pringgo Hutomo
//2311102196
//IF-11-05
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/workout.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final workouts = Provider.of<List<Workout>?>(context) ?? [];
    
    int totalDurasi = 0;
    int totalKalori = 0;
    
    // Data untuk fl_chart (misal 7 hari terakhir kalori)
    Map<int, double> kaloriPerHari = {1:0, 2:0, 3:0, 4:0, 5:0, 6:0, 7:0};
    
    for (var workout in workouts) {
      totalDurasi += workout.durasi;
      totalKalori += workout.kalori;
      
      int dayDiff = DateTime.now().difference(workout.tanggal).inDays;
      if (dayDiff >= 0 && dayDiff < 7) {
        int dayIndex = 7 - dayDiff; 
        kaloriPerHari[dayIndex] = (kaloriPerHari[dayIndex] ?? 0) + workout.kalori;
      }
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Statistik Aktivitas', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildStatCard('Total Durasi', '$totalDurasi min', Icons.timer, Colors.orange)),
              SizedBox(width: 16),
              Expanded(child: _buildStatCard('Total Kalori', '$totalKalori kcal', Icons.local_fire_department, Colors.orange)),
            ],
          ),
          SizedBox(height: 40),
          Text('Progress Mingguan (Kalori)', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          Container(
            height: 300,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(16)
            ),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (kaloriPerHari.values.reduce((a, b) => a > b ? a : b) + 100).toDouble(),
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text('H-${7 - value.toInt()}', style: TextStyle(color: Colors.grey, fontSize: 10)),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                barGroups: kaloriPerHari.entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value,
                        color: Colors.orange,
                        width: 16,
                        borderRadius: BorderRadius.circular(4),
                      )
                    ],
                  );
                }).toList(),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 30),
          SizedBox(height: 10),
          Text(value, style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 5),
          Text(title, style: TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }
}
