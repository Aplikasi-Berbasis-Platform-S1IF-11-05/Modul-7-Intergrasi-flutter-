// 2311102090-Buswiryawan Raditya Boenyamin
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../services/task_service.dart';
import '../services/auth_service.dart';
import '../services/theme_provider.dart';
import 'add_task_screen.dart';
import 'edit_task_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final _taskService = TaskService();
  final _authService = AuthService();
  late Stream<List<Task>> _taskStream;

  @override
  void initState() {
    super.initState();
    _taskStream = _taskService.getTasksStream();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('INDEX::TASKS'),
        actions: [
          _buildUserAvatar(context),
          const SizedBox(width: 12),
          _buildMoreActions(),
          const SizedBox(width: 12),
        ],
      ),
      body: StreamBuilder<List<Task>>(
        stream: _taskStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _buildErrorState(isDark);
          }

          final tasks = snapshot.data ?? [];
          if (tasks.isEmpty) return _buildEmptyState(isDark);

          // Get the most recent pending task as the "Hero"
          final pendingTasks = tasks.where((t) => !t.isCompleted).toList();
          final completedTasks = tasks.where((t) => t.isCompleted).toList();
          final heroTask = pendingTasks.isNotEmpty ? pendingTasks.first : null;
          final remainingPending = pendingTasks.isNotEmpty ? pendingTasks.sublist(1) : [];

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _taskStream = _taskService.getTasksStream();
              });
            },
            child: ListView(
              padding: const EdgeInsets.all(24),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                if (heroTask != null) ...[
                  _buildMonoLabel('ACTIVE_FOCUS'),
                  _buildHeroCard(heroTask, isDark),
                  const SizedBox(height: 48),
                ],
                
                if (remainingPending.isNotEmpty) ...[
                  _buildMonoLabel('UP_NEXT'),
                  ...remainingPending.map((task) => _buildMinimalItem(task, isDark)),
                  const SizedBox(height: 48),
                ],

                if (completedTasks.isNotEmpty) ...[
                  _buildMonoLabel('COMPLETED_INDEX'),
                  ...completedTasks.map((task) => _buildMinimalItem(task, isDark, isDone: true)),
                ],
                
                const SizedBox(height: 48),
                _buildWatermark(isDark),
                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AddTaskScreen()));
          setState(() {
            _taskStream = _taskService.getTasksStream();
          });
        },
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        child: const Icon(Icons.add, size: 32),
      ),
    );
  }

  Widget _buildMonoLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        text,
        style: GoogleFonts.jetBrainsMono(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
          color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildHeroCard(Task task, bool isDark) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () async {
        await Navigator.of(context).push(MaterialPageRoute(builder: (context) => EditTaskScreen(task: task)));
        setState(() {
          _taskStream = _taskService.getTasksStream();
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        color: theme.colorScheme.primary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.title.toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: theme.colorScheme.onPrimary,
                height: 1,
                letterSpacing: -1,
              ),
            ),
            if (task.description.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                task.description,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 13,
                  color: theme.colorScheme.onPrimary.withOpacity(0.7),
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 32),
            _buildStatusTag('PRIORITY_HIGH'),
          ],
        ),
      ),
    );
  }

  Widget _buildMinimalItem(Task task, bool isDark, {bool isDone = false}) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () async {
        await Navigator.of(context).push(MaterialPageRoute(builder: (context) => EditTaskScreen(task: task)));
        setState(() {
          _taskStream = _taskService.getTasksStream();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: isDark ? Colors.white10 : Colors.black12)),
        ),
        child: Row(
          children: [
            _buildCheckbox(task),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      decoration: isDone ? TextDecoration.lineThrough : null,
                      color: isDone ? theme.colorScheme.primary.withOpacity(0.3) : theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${task.createdAt.hour}:${task.createdAt.minute.toString().padLeft(2, '0')} • SYSTEM_LOG_${task.id.substring(0, 4).toUpperCase()}',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      color: theme.colorScheme.primary.withOpacity(0.4),
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

  Widget _buildStatusTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(border: Border.all(color: Colors.white24)),
      child: Text(
        label,
        style: GoogleFonts.jetBrainsMono(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  Widget _buildCheckbox(Task task) {
    final isDone = task.isCompleted;
    return GestureDetector(
      onTap: () => _taskService.toggleTaskCompletion(
        taskId: task.id,
        currentStatus: task.isCompleted,
        taskTitle: task.title,
      ),
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2),
          color: isDone ? Theme.of(context).colorScheme.primary : Colors.transparent,
        ),
        child: isDone ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
      ),
    );
  }

  Widget _buildUserAvatar(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => _showUserProfile(context),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(border: Border.all(color: theme.colorScheme.primary)),
        child: Center(
          child: Text(
            _authService.getUserFullName().isNotEmpty ? _authService.getUserFullName().substring(0, 1).toUpperCase() : 'U',
            style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
      ),
    );
  }

  void _showUserProfile(BuildContext context) {
    final theme = Theme.of(context);
    final nameController = TextEditingController(text: _authService.getUserFullName());
    bool isEditing = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(border: Border.all(color: theme.colorScheme.primary)),
                child: Icon(Icons.person_rounded, size: 48, color: theme.colorScheme.primary),
              ),
              const SizedBox(height: 24),
              if (!isEditing) ...[
                Text(
                  _authService.getUserFullName(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: theme.colorScheme.primary),
                ),
                TextButton.icon(
                  onPressed: () => setDialogState(() => isEditing = true),
                  icon: const Icon(Icons.edit_rounded, size: 16),
                  label: Text('EDIT_NAME', style: GoogleFonts.jetBrainsMono(fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ] else ...[
                TextField(
                  controller: nameController,
                  autofocus: true,
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(hintText: 'NEW_NAME_STRING'),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => setDialogState(() => isEditing = false),
                      child: Text('CANCEL', style: GoogleFonts.jetBrainsMono(fontSize: 10, color: Colors.grey)),
                    ),
                    TextButton(
                      onPressed: () async {
                        final success = await _authService.updateFullName(nameController.text.trim());
                        if (success) {
                          setState(() {}); // Refresh list screen
                          if (context.mounted) Navigator.pop(context);
                        }
                      },
                      child: Text('SAVE_CHANGES', style: GoogleFonts.jetBrainsMono(fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              Text(
                _authService.getUserEmail(),
                textAlign: TextAlign.center,
                style: GoogleFonts.jetBrainsMono(fontSize: 11, color: theme.colorScheme.primary.withOpacity(0.5)),
              ),
              const SizedBox(height: 32),
              TextButton(
                onPressed: () => _confirmAccountDeletion(context),
                child: Text(
                  'PURGE_ACCOUNT_INDEX',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmAccountDeletion(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: Text('CRITICAL::ACCOUNT_PURGE_CONFIRMATION', 
          style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold, fontSize: 14)),
        content: Text('THIS_ACTION_WILL_PERMANENTLY_DELETE_YOUR_IDENTITY_AND_ALL_TASKS. CONTINUE?', 
          style: GoogleFonts.jetBrainsMono(fontSize: 11)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('ABORT_SEQUENCE', style: GoogleFonts.jetBrainsMono(color: Colors.grey, fontSize: 12)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('CONFIRM_PURGE', 
              style: GoogleFonts.jetBrainsMono(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _authService.deleteAccount();
      if (success && mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  Widget _buildMoreActions() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.themeMode == ThemeMode.dark;

    return PopupMenuButton<String>(
      onSelected: (v) {
        if (v == 'logout') {
          _logout();
        } else if (v == 'theme') themeProvider.toggleTheme(!isDark);
      },
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'theme',
          child: Text('TOGGLE_VISUAL_MODE::${isDark ? 'LIGHT' : 'DARK'}', style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.bold)),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'logout',
          child: Text('TERMINATE_SESSION', style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.redAccent)),
        ),
      ],
      child: const Icon(Icons.menu_rounded),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'NULL_DATA_DETECTED',
            style: GoogleFonts.jetBrainsMono(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'INITIALIZE_FIRST_TASK_ENTRY',
            style: GoogleFonts.jetBrainsMono(fontSize: 11, color: isDark ? Colors.white38 : Colors.black38),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.terminal_rounded, size: 48),
            const SizedBox(height: 24),
            Text(
              'CRITICAL_SYSTEM_ERROR',
              style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold, color: Colors.redAccent),
            ),
            const SizedBox(height: 8),
            Text(
              'VERIFY_DATABASE_REALTIME_STATUS',
              textAlign: TextAlign.center,
              style: GoogleFonts.jetBrainsMono(fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWatermark(bool isDark) {
    return Center(
      child: Text(
        'DEV_NODE::2311102090_RADITYA_BOENYAMIN',
        style: GoogleFonts.jetBrainsMono(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white10 : Colors.black12,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (mounted) Navigator.of(context).pushReplacementNamed('/login');
  }
}
