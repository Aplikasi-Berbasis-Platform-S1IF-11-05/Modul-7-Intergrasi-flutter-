// 2311102090-Buswiryawan Raditya Boenyamin
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/task.dart';
import '../services/task_service.dart';

class EditTaskScreen extends StatefulWidget {
  final Task task;

  const EditTaskScreen({super.key, required this.task});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late bool _isCompleted;
  final _taskService = TaskService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(text: widget.task.description);
    _isCompleted = widget.task.isCompleted;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _updateTask() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final updatedTask = await _taskService.updateTask(
          taskId: widget.task.id,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          isCompleted: _isCompleted,
        );
        if (updatedTask != null && mounted) Navigator.of(context).pop();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('ERR::UPDATE_FAILED', style: GoogleFonts.jetBrainsMono(fontSize: 12)),
              backgroundColor: Colors.redAccent,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('EDIT_ENTRY'),
        actions: [
          IconButton(
            onPressed: () => _confirmDelete(),
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel('ENTRY_ID_HEX'),
                Text(
                  widget.task.id.toUpperCase(),
                  style: GoogleFonts.jetBrainsMono(fontSize: 10, color: theme.colorScheme.primary.withOpacity(0.3)),
                ),
                const SizedBox(height: 32),
                _buildLabel('OBJECTIVE_STRING'),
                TextFormField(
                  controller: _titleController,
                  maxLength: 100,
                  style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 18),
                  decoration: const InputDecoration(hintText: 'TITLE'),
                  validator: (v) => (v == null || v.length < 3) ? 'ERR_STRING_TOO_SHORT' : null,
                ),
                const SizedBox(height: 32),
                _buildLabel('CONTEXT_DATA'),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 6,
                  maxLength: 500,
                  style: GoogleFonts.jetBrainsMono(fontSize: 14),
                  decoration: const InputDecoration(hintText: 'DESCRIPTION'),
                  validator: (v) => (v == null || v.length < 5) ? 'ERR_DATA_INSUFFICIENT' : null,
                ),
                const SizedBox(height: 32),
                _buildStatusToggle(),
                const SizedBox(height: 60),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _updateTask,
                    child: _isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('UPDATE_DATABASE_NODE'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 2),
      child: Text(
        text,
        style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
      ),
    );
  }

  Widget _buildStatusToggle() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'TOGGLE_COMPLETION_STATE',
              style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          Switch(
            value: _isCompleted,
            activeThumbColor: Colors.black,
            onChanged: (v) => setState(() => _isCompleted = v),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: Text('CRITICAL::DELETE_CONFIRMATION', style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold, fontSize: 14)),
        content: Text('THIS_ACTION_IS_IRREVERSIBLE. CONTINUE?', style: GoogleFonts.jetBrainsMono(fontSize: 12)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('ABORT', style: GoogleFonts.jetBrainsMono(color: Colors.grey, fontSize: 12))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('CONFIRM_DELETE', style: GoogleFonts.jetBrainsMono(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 12))),
        ],
      ),
    );
    if (confirmed == true) {
      await _taskService.deleteTask(taskId: widget.task.id, taskTitle: widget.task.title);
      if (mounted) Navigator.pop(context);
    }
  }
}
