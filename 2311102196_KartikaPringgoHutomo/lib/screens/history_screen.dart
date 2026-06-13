//Kartika Pringgo Hutomo
//2311102196
//IF-11-05
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/workout.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import 'workout_form_screen.dart';

class HistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final workouts = Provider.of<List<Workout>?>(context);
    final user = AuthService().currentUser;

    if (workouts == null) {
      return Center(child: CircularProgressIndicator(color: Colors.orange));
    }

    if (workouts.isEmpty) {
      return Center(
        child: Text('Belum ada riwayat aktivitas.', style: TextStyle(color: Colors.grey, fontSize: 16)),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.0),
      itemCount: workouts.length,
      itemBuilder: (context, index) {
        final workout = workouts[index];
        return Card(
          color: Colors.grey[900],
          margin: EdgeInsets.only(bottom: 16.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: Colors.orange.withOpacity(0.2),
              child: Icon(Icons.directions_run, color: Colors.orange),
            ),
            title: Text(workout.namaAktivitas, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8),
                Text('Durasi: ${workout.durasi} menit | Kalori: ${workout.kalori} kcal', style: TextStyle(color: Colors.grey[400])),
                SizedBox(height: 4),
                Text(DateFormat('dd MMM yyyy, HH:mm').format(workout.tanggal), style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => WorkoutFormScreen(workout: workout))
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    if (user != null) {
                      await FirestoreService(userId: user.uid).deleteWorkout(workout.id);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Aktivitas dihapus!'), backgroundColor: Colors.red));
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
