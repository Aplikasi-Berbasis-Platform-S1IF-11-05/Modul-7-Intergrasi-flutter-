//Willyan Hyuga Pratama 2211102129
import 'package:flutter/material.dart';
import '../models/skill_model.dart';
import '../services/firestore_service.dart';

class DashboardScreen extends StatelessWidget {
  final String userId;
  final FirestoreService _firestoreService = FirestoreService();

  DashboardScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 120,
          floating: false,
          pinned: true,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.cyan.shade600,
          flexibleSpace: FlexibleSpaceBar(
            title: const Text(
              'Dashboard',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.cyan.shade700,
                    Colors.cyan.shade400,
                  ],
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: StreamBuilder<List<SkillModel>>(
            stream: _firestoreService.getSkills(userId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final skills = snapshot.data ?? [];

              if (skills.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.bar_chart,
                            size: 80, color: Colors.cyan.shade200),
                        const SizedBox(height: 16),
                        Text(
                          'Belum ada data untuk ditampilkan',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Calculate stats
              final totalSkills = skills.length;
              final beginnerCount =
                  skills.where((s) => s.level == 'Beginner').length;
              final intermediateCount =
                  skills.where((s) => s.level == 'Intermediate').length;
              final advancedCount =
                  skills.where((s) => s.level == 'Advanced').length;
              final expertCount =
                  skills.where((s) => s.level == 'Expert').length;
              final certifiedCount =
                  skills.where((s) => s.sertifikatUrl.isNotEmpty).length;

              // Calculate average progress
              double avgProgress = skills.fold(0.0, (sum, skill) {
                    return sum + SkillModel.levelToProgress(skill.level);
                  }) /
                  totalSkills;

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Cards Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Total Skill',
                            totalSkills.toString(),
                            Icons.code,
                            Colors.cyan,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Tersertifikasi',
                            certifiedCount.toString(),
                            Icons.verified,
                            Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Average Progress Card
                    _buildProgressCard(avgProgress),
                    const SizedBox(height: 24),

                    // Level Distribution
                    const Text(
                      'Distribusi Level',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildLevelBar(
                        'Beginner', beginnerCount, totalSkills, Colors.green),
                    _buildLevelBar('Intermediate', intermediateCount,
                        totalSkills, Colors.orange),
                    _buildLevelBar(
                        'Advanced', advancedCount, totalSkills, Colors.blue),
                    _buildLevelBar(
                        'Expert', expertCount, totalSkills, Colors.purple),
                    const SizedBox(height: 24),

                    // Skill Progress List
                    const Text(
                      'Progress Skill',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...skills.map((skill) => _buildSkillProgressTile(skill)),
                    const SizedBox(height: 80),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, MaterialColor color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color.shade600, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color.shade700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(double avgProgress) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Rata-rata Progress',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${(avgProgress * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.cyan.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: avgProgress,
                minHeight: 12,
                backgroundColor: Colors.grey.shade200,
                valueColor:
                    AlwaysStoppedAnimation<Color>(Colors.cyan.shade500),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getProgressMessage(avgProgress),
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getProgressMessage(double progress) {
    if (progress >= 0.75) {
      return '🎉 Luar biasa! Anda sudah sangat mahir!';
    } else if (progress >= 0.5) {
      return '💪 Bagus! Terus tingkatkan kemampuan Anda!';
    } else if (progress >= 0.25) {
      return '📚 Terus belajar, Anda di jalur yang tepat!';
    } else {
      return '🚀 Awal yang baik! Semangat belajar!';
    }
  }

  Widget _buildLevelBar(
      String level, int count, int total, MaterialColor color) {
    final percentage = total > 0 ? count / total : 0.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              level,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: percentage,
                minHeight: 20,
                backgroundColor: Colors.grey.shade100,
                valueColor: AlwaysStoppedAnimation<Color>(color.shade400),
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 30,
            child: Text(
              '$count',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color.shade700,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillProgressTile(SkillModel skill) {
    final progress = SkillModel.levelToProgress(skill.level);
    final color = _getLevelColor(skill.level);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(Icons.code, color: color, size: 20),
        ),
        title: Text(
          skill.namaSkill,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${skill.level} • ${(progress * 100).toInt()}%',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
        trailing: skill.sertifikatUrl.isNotEmpty
            ? Icon(Icons.verified, color: Colors.cyan.shade600, size: 20)
            : null,
      ),
    );
  }

  Color _getLevelColor(String level) {
    switch (level) {
      case 'Beginner':
        return Colors.green;
      case 'Intermediate':
        return Colors.orange;
      case 'Advanced':
        return Colors.blue;
      case 'Expert':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
