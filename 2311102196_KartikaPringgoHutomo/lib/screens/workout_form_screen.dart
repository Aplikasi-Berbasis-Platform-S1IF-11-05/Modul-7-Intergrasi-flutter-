//Kartika Pringgo Hutomo
//2311102196
//IF-11-05
import 'package:flutter/material.dart';
import '../models/workout.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';

class WorkoutFormScreen extends StatefulWidget {
  final Workout? workout;

  WorkoutFormScreen({this.workout});

  @override
  _WorkoutFormScreenState createState() => _WorkoutFormScreenState();
}

class _WorkoutFormScreenState extends State<WorkoutFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  String _namaAktivitas = '';
  int _durasi = 0;
  int _kalori = 0;
  String _catatan = '';
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.workout != null) {
      _namaAktivitas = widget.workout!.namaAktivitas;
      _durasi = widget.workout!.durasi;
      _kalori = widget.workout!.kalori;
      _catatan = widget.workout!.catatan;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.workout != null;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Aktivitas' : 'Tambah Aktivitas', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.orange),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.orange))
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      initialValue: _namaAktivitas,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Nama Aktivitas',
                        labelStyle: TextStyle(color: Colors.orange),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
                      ),
                      validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
                      onSaved: (val) => _namaAktivitas = val!,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      initialValue: _durasi > 0 ? _durasi.toString() : '',
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Durasi (menit)',
                        labelStyle: TextStyle(color: Colors.orange),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
                      onSaved: (val) => _durasi = int.parse(val!),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      initialValue: _kalori > 0 ? _kalori.toString() : '',
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Kalori',
                        labelStyle: TextStyle(color: Colors.orange),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
                      onSaved: (val) => _kalori = int.parse(val!),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      initialValue: _catatan,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Catatan',
                        labelStyle: TextStyle(color: Colors.orange),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
                      ),
                      maxLines: 3,
                      onSaved: (val) => _catatan = val ?? '',
                    ),
                    SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.black,
                        ),
                        child: Text('Simpan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            setState(() => _isLoading = true);
                            
                            final user = AuthService().currentUser;
                            if (user != null) {
                              final firestoreService = FirestoreService(userId: user.uid);
                              final workout = Workout(
                                id: isEdit ? widget.workout!.id : '',
                                namaAktivitas: _namaAktivitas,
                                durasi: _durasi,
                                kalori: _kalori,
                                tanggal: isEdit ? widget.workout!.tanggal : DateTime.now(),
                                catatan: _catatan,
                                userId: user.uid,
                              );

                              try {
                                if (isEdit) {
                                  await firestoreService.updateWorkout(workout);
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Berhasil memperbarui aktivitas!'), backgroundColor: Colors.green));
                                } else {
                                  await firestoreService.addWorkout(workout);
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Berhasil menambahkan aktivitas!'), backgroundColor: Colors.green));
                                }
                                Navigator.pop(context);
                              } catch (e) {
                                setState(() => _isLoading = false);
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                              }
                            }
                          }
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
