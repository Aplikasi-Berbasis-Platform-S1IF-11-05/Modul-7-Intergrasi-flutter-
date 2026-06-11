import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/mood_model.dart';
import '../services/auth_service.dart';
import '../services/mood_service.dart';
import '../services/notification_service.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _moodService = MoodService();
  final _authService = AuthService();
  List<MoodModel> _moods = [];
  bool _loading = true;

  final List<Map<String, String>> _moodOptions = [
    {'emoji': '😄', 'label': 'Senang'},
    {'emoji': '😐', 'label': 'Biasa'},
    {'emoji': '😢', 'label': 'Sedih'},
    {'emoji': '😡', 'label': 'Marah'},
    {'emoji': '😴', 'label': 'Lelah'},
    {'emoji': '😰', 'label': 'Cemas'},
  ];

  @override
  void initState() {
    super.initState();
    _loadMoods();
  }

  Future<void> _loadMoods() async {
    setState(() => _loading = true);
    final moods = await _moodService.getMoods();
    setState(() {
      _moods = moods;
      _loading = false;
    });
  }

  void _showAddMoodDialog() {
    String selectedEmoji = '😄';
    String selectedLabel = 'Senang';
    final noteCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bagaimana mood kamu?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                children: _moodOptions.map((m) {
                  final selected = m['emoji'] == selectedEmoji;
                  return GestureDetector(
                    onTap: () => setModal(() {
                      selectedEmoji = m['emoji']!;
                      selectedLabel = m['label']!;
                    }),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFF7C5CBF)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            m['emoji']!,
                            style: const TextStyle(fontSize: 28),
                          ),
                          Text(
                            m['label']!,
                            style: TextStyle(
                              color: selected ? Colors.white : Colors.black,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: noteCtrl,
                decoration: const InputDecoration(
                  labelText: 'Catatan (opsional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final mood = MoodModel(
                      id: '',
                      userId: _authService.currentUserId!,
                      moodEmoji: selectedEmoji,
                      moodLabel: selectedLabel,
                      note: noteCtrl.text.isEmpty ? null : noteCtrl.text,
                      createdAt: DateTime.now(),
                    );
                    await _moodService.addMood(mood);
                    await NotificationService.show(
                      '✅ Mood Ditambahkan',
                      '$selectedEmoji $selectedLabel berhasil dicatat!',
                    );
                    Navigator.pop(ctx);
                    _loadMoods();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C5CBF),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog(MoodModel mood) {
    final noteCtrl = TextEditingController(text: mood.note);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit Catatan ${mood.moodEmoji}'),
        content: TextField(
          controller: noteCtrl,
          decoration: const InputDecoration(
            labelText: 'Catatan',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _moodService.updateMood(mood.id, noteCtrl.text);
              await NotificationService.show(
                '✏️ Mood Diperbarui',
                '${mood.moodEmoji} ${mood.moodLabel} berhasil diedit.',
              );
              Navigator.pop(ctx);
              _loadMoods();
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(MoodModel mood) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Mood?'),
        content: Text(
          'Yakin ingin menghapus ${mood.moodEmoji} ${mood.moodLabel}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              await _moodService.deleteMood(mood.id);
              await NotificationService.show(
                '🗑️ Mood Dihapus',
                '${mood.moodEmoji} ${mood.moodLabel} telah dihapus.',
              );
              Navigator.pop(ctx);
              _loadMoods();
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3EEFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7C5CBF),
        foregroundColor: Colors.white,
        title: const Text('MoodTrack 🎭'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.logout();
              if (mounted)
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _moods.isEmpty
          ? const Center(
              child: Text(
                'Belum ada catatan mood.\nTambahkan sekarang! 😊',
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _moods.length,
              itemBuilder: (ctx, i) {
                final mood = _moods[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    leading: Text(
                      mood.moodEmoji,
                      style: const TextStyle(fontSize: 36),
                    ),
                    title: Text(
                      mood.moodLabel,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (mood.note != null && mood.note!.isNotEmpty)
                          Text(mood.note!),
                        Text(
                          DateFormat(
                            'dd MMM yyyy, HH:mm',
                          ).format(mood.createdAt.toLocal()),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: Color(0xFF7C5CBF),
                          ),
                          onPressed: () => _showEditDialog(mood),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDelete(mood),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddMoodDialog,
        backgroundColor: const Color(0xFF7C5CBF),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Mood'),
      ),
    );
  }
}
