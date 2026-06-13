import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/notification_service.dart';
import '../models/notification_model.dart';
import '../theme/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Log Aktivitas CRUD', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          // Clear History button
          Consumer<NotificationService>(
            builder: (context, notifService, _) {
              if (notifService.logs.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.delete_sweep_rounded, color: AppTheme.priorityHigh),
                tooltip: 'Bersihkan Log',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Bersihkan Log'),
                      content: const Text('Apakah Anda yakin ingin menghapus semua log riwayat aktivitas ini?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('Batal', style: TextStyle(color: AppTheme.textSecondary)),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            notifService.clearLogs();
                          },
                          child: const Text('Hapus Semua', style: TextStyle(color: AppTheme.priorityHigh)),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<NotificationService>(
        builder: (context, notifService, _) {
          final logs = notifService.logs;

          if (logs.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: logs.length,
            itemBuilder: (ctx, index) {
              final log = logs[index];
              return _buildNotificationCard(log);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              size: 72,
              color: AppTheme.textSecondary.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            const Text(
              'Belum ada aktivitas',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 8),
            const Text(
              'Aktivitas seperti membuat, mengedit, atau menghapus tugas akan dicatat di sini.',
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(NotificationLog log) {
    Color typeColor;
    IconData typeIcon;
    String badgeText;

    switch (log.type.toLowerCase()) {
      case 'create':
        typeColor = AppTheme.priorityLow;
        typeIcon = Icons.add_circle_outline_rounded;
        badgeText = 'CREATE';
        break;
      case 'update':
        typeColor = AppTheme.priorityMedium;
        typeIcon = Icons.edit_note_rounded;
        badgeText = 'UPDATE';
        break;
      case 'delete':
        typeColor = AppTheme.priorityHigh;
        typeIcon = Icons.delete_forever_rounded;
        badgeText = 'DELETE';
        break;
      case 'complete':
        typeColor = AppTheme.accentCyan;
        typeIcon = Icons.check_circle_outline_rounded;
        badgeText = 'COMPLETE';
        break;
      default:
        typeColor = AppTheme.accentPurple;
        typeIcon = Icons.info_outline_rounded;
        badgeText = 'INFO';
    }

    final formattedTime = DateFormat('dd MMM yyyy, HH:mm:ss').format(log.timestamp);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon representing CRUD action
            CircleAvatar(
              radius: 20,
              backgroundColor: typeColor.withOpacity(0.12),
              child: Icon(typeIcon, color: typeColor, size: 20),
            ),
            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Badge Tag
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: typeColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badgeText,
                          style: TextStyle(
                            color: typeColor,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      // Time indicator
                      Text(
                        formattedTime,
                        style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Notification Title
                  Text(
                    log.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Notification Message details
                  Text(
                    log.message,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
