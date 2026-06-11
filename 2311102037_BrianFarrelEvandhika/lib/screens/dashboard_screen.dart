import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
import '../theme/app_theme.dart';
import 'auth_screen.dart';
import 'task_list_screen.dart';
import 'notifications_screen.dart';
import '../widgets/task_form_dialog.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.userId != null) {
        Provider.of<TaskProvider>(context, listen: false).fetchTasks(auth.userId!);
      }
    });
  }

  Future<void> _signOut() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AuthScreen()),
      );
    }
  }

  void _showAddTaskDialog() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (_) => TaskFormDialog(userId: auth.userId!),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final tasksData = Provider.of<TaskProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'TaskFlow',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                foreground: Paint()
                  ..shader = const LinearGradient(
                    colors: [AppTheme.accentCyan, AppTheme.accentPurple],
                  ).createShader(const Rect.fromLTWH(0.0, 0.0, 150.0, 50.0)),
              ),
        ),
        actions: [
          // Connection status icon
          Tooltip(
            message: auth.isOnlineMode ? 'Online Mode (Supabase)' : 'Offline Fallback Mode',
            child: Icon(
              auth.isOnlineMode ? Icons.wifi_rounded : Icons.wifi_off_rounded,
              color: auth.isOnlineMode ? AppTheme.accentCyan : AppTheme.priorityMedium,
            ),
          ),
          const SizedBox(width: 8),
          // Logout button
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppTheme.priorityHigh),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Keluar'),
                  content: const Text('Apakah Anda yakin ingin keluar dari akun Anda?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Batal', style: TextStyle(color: AppTheme.textSecondary)),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        _signOut();
                      },
                      child: const Text('Keluar', style: TextStyle(color: AppTheme.priorityHigh)),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: tasksData.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.accentCyan),
            )
          : RefreshIndicator(
              onRefresh: () => tasksData.fetchTasks(auth.userId!),
              color: AppTheme.accentCyan,
              backgroundColor: AppTheme.cardColor,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Welcome Profile Banner
                    _buildProfileBanner(auth.userEmail ?? 'User'),
                    const SizedBox(height: 24),

                    // Stats Dashboard Grid
                    _buildStatsGrid(tasksData),
                    const SizedBox(height: 24),

                    // Navigation Buttons for Main App screens
                    Row(
                      children: [
                        Expanded(
                          child: _buildNavCard(
                            title: 'Daftar Tugas',
                            subtitle: '${tasksData.pendingTasksCount} Tertunda',
                            icon: Icons.assignment_outlined,
                            gradientColors: [AppTheme.accentCyan, AppTheme.accentPurple.withOpacity(0.5)],
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const TaskListScreen()),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildNavCard(
                            title: 'Notifikasi',
                            subtitle: 'Log Aktivitas CRUD',
                            icon: Icons.notifications_active_outlined,
                            gradientColors: [AppTheme.accentPurple, AppTheme.accentPink.withOpacity(0.5)],
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Task breakdown by Priority
                    _buildSectionHeader('Prioritas Tugas'),
                    const SizedBox(height: 12),
                    _buildPriorityStats(tasksData),
                    const SizedBox(height: 24),

                    // Task breakdown by Category
                    _buildSectionHeader('Distribusi Kategori'),
                    const SizedBox(height: 12),
                    _buildCategoryStats(tasksData),
                    const SizedBox(height: 80), // spacer for FAB
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTaskDialog,
        backgroundColor: AppTheme.accentCyan,
        foregroundColor: AppTheme.backgroundColor,
        icon: const Icon(Icons.add_rounded, size: 24, fontWeight: FontWeight.bold),
        label: const Text('Tugas Baru', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildProfileBanner(String email) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderLight),
        gradient: LinearGradient(
          colors: [AppTheme.cardColor, AppTheme.cardColor.withOpacity(0.5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppTheme.accentCyan.withOpacity(0.1),
            child: const Icon(Icons.person_rounded, color: AppTheme.accentCyan, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selamat Datang kembali,',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  email.split('@')[0],
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(TaskProvider provider) {
    final completionPercentage = (provider.completionRate * 100).toStringAsFixed(0);

    return Column(
      children: [
        // Completed Progress Bar card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tingkat Penyelesaian',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      '$completionPercentage%',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.accentCyan,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: provider.completionRate,
                    minHeight: 12,
                    backgroundColor: AppTheme.borderLight,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accentCyan),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${provider.completedTasksCount} dari ${provider.totalTasksCount} tugas selesai',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Task Count Grid details
        Row(
          children: [
            Expanded(
              child: _buildStatTile(
                title: 'Tugas Aktif',
                value: provider.pendingTasksCount.toString(),
                icon: Icons.pending_actions_rounded,
                iconColor: AppTheme.accentPurple,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatTile(
                title: 'Selesai',
                value: provider.completedTasksCount.toString(),
                icon: Icons.task_alt_rounded,
                iconColor: AppTheme.accentCyan,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatTile({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: iconColor.withOpacity(0.1),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildNavCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.borderLight),
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: gradientColors[0].withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppTheme.backgroundColor, size: 28),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.backgroundColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.backgroundColor.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppTheme.textPrimary,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildPriorityStats(TaskProvider provider) {
    final highCount = provider.getPriorityCount('high');
    final mediumCount = provider.getPriorityCount('medium');
    final lowCount = provider.getPriorityCount('low');

    return Row(
      children: [
        Expanded(
          child: _buildPriorityMiniCard(
            label: 'Tinggi',
            count: highCount,
            color: AppTheme.priorityHigh,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildPriorityMiniCard(
            label: 'Sedang',
            count: mediumCount,
            color: AppTheme.priorityMedium,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildPriorityMiniCard(
            label: 'Rendah',
            count: lowCount,
            color: AppTheme.priorityLow,
          ),
        ),
      ],
    );
  }

  Widget _buildPriorityMiniCard({
    required String label,
    required int count,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Column(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            count.toString(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryStats(TaskProvider provider) {
    final categories = ['Work', 'Personal', 'Shopping', 'Health'];

    return Column(
      children: categories.map((cat) {
        final count = provider.getCategoryCount(cat);
        final color = AppTheme.getCategoryColor(cat);
        final icon = AppTheme.getCategoryIcon(cat);
        final total = provider.totalTasksCount;
        final percent = total == 0 ? 0.0 : count / total;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.borderLight),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: color.withOpacity(0.1),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            cat == 'Work'
                                ? 'Pekerjaan'
                                : cat == 'Personal'
                                    ? 'Pribadi'
                                    : cat == 'Shopping'
                                        ? 'Belanja'
                                        : 'Kesehatan',
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '$count Tugas',
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: percent,
                          minHeight: 6,
                          backgroundColor: AppTheme.borderLight,
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
