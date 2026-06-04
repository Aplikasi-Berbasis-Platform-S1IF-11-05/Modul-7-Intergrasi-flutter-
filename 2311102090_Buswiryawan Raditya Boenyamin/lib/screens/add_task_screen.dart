// 2311102090-Buswiryawan Raditya Boenyamin
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/task_service.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _taskService = TaskService();
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createTask() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final task = await _taskService.createTask(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
        );
        if (task != null && mounted) Navigator.of(context).pop();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('ERR::INSERT_FAILED', style: GoogleFonts.jetBrainsMono(fontSize: 12)),
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
        title: const Text('NEW_ENTRY'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close_rounded),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel('ENTRY_TITLE_STRING'),
                TextFormField(
                  controller: _titleController,
                  maxLength: 100,
                  style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 18),
                  decoration: const InputDecoration(hintText: 'OBJECTIVE_NAME'),
                  validator: (v) => (v == null || v.length < 3) ? 'ERR_STRING_TOO_SHORT' : null,
                ),
                const SizedBox(height: 32),
                _buildLabel('DESCRIPTION_DATA_BLOB'),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 8,
                  maxLength: 500,
                  style: GoogleFonts.jetBrainsMono(fontSize: 14),
                  decoration: const InputDecoration(hintText: 'ADDITIONAL_CONTEXT_REQUIRED'),
                  validator: (v) => (v == null || v.length < 5) ? 'ERR_DATA_INSUFFICIENT' : null,
                ),
                const SizedBox(height: 60),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _createTask,
                    child: _isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('COMMIT_CHANGES'),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'ABORT_OPERATION',
                      style: GoogleFonts.jetBrainsMono(fontSize: 11, color: theme.colorScheme.primary, decoration: TextDecoration.underline),
                    ),
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
}
