<div align="center">
    <br />
    <h1>LAPORAN PRAKTIKUM <br> APLIKASI BERBASIS PLATFORM </h1>
    <br />
    <h3>MODUL 7 <br> Integrasi Flutter Firebase/Supabase </h3>
    <br />
    <img width="512" height="512" alt="telyu" src="https://github.com/user-attachments/assets/724a3291-bcf9-448d-a395-3886a8659d79" />
    <br />
    <br />
    <br />
    <h3>Disusun Oleh :</h3>
    <p>
        <strong>Rasyid Nafsyarie</strong>
        <br>
        <strong>2311102011</strong>
        <br>
        <strong>S1 IF-11-REG05</strong>
    </p>
    <br />
    <h3>Dosen Pengampu :</h3>
    <p>
        <strong>Dedi Agung Prabowo, S.Kom., M.Kom</strong>
    </p>
    <br />
    <br />
    <h4>Asisten Praktikum :</h4>
    <strong>Apri Pandu Wicaksono </strong>
    <br>
    <strong>Hamka Zaenul Ardi</strong>
    <br />
    <h3>LABORATORIUM HIGH PERFORMANCE <br>FAKULTAS INFORMATIKA <br>UNIVERSITAS TELKOM PURWOKERTO <br>2026 </h3>
</div>
<hr>

## Dasar Teori

Firebase adalah platform BaaS komprehensif yang dikelola oleh Google. Platform ini menyediakan berbagai alat terintegrasi untuk mempercepat pengembangan aplikasi. Beberapa komponen inti Firebase yang sering diintegrasikan dengan aplikasi seluler meliputi:

Firebase Authentication: Layanan identitas untuk mengenali pengguna, mendukung proses login menggunakan email dan kata sandi, serta penyedia identitas pihak ketiga.

Cloud Firestore: Basis data dokumen NoSQL yang fleksibel dan terukur. Firestore menyimpan data dalam format koleksi dan dokumen, serta memungkinkan sinkronisasi data secara real-time di seluruh perangkat klien.

Firebase Cloud Messaging (FCM) & Push Notifications: Infrastruktur untuk mengirim pesan dan notifikasi yang andal tanpa biaya ke perangkat lintas platform.

Supabase adalah platform BaaS sumber terbuka yang dirancang sebagai alternatif dari Firebase. Berbeda dengan pendekatan NoSQL milik Firebase, Supabase dibangun di atas basis data relasional PostgreSQL. Fitur utama Supabase mencakup:

PostgreSQL Database: Menyediakan fungsionalitas basis data tingkat perusahaan dengan skema yang ketat dan dukungan kueri kompleks.

Realtime Subscriptions: Menggunakan WebSockets untuk mendengarkan perubahan data secara langsung dari basis data dan memperbarui antarmuka aplikasi klien seketika.

RESTful API Otomatis: Secara dinamis menghasilkan API dari skema basis data, mempermudah interaksi operasi CRUD (Create, Read, Update, Delete) tanpa perlu menulis lapisan perantara backend.

## Tugas Modul 7 - Lumubi - Authentication

### 1. Source Code

```dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'register_screen.dart';
import '../dashboard/dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login Gagal: ${e.toString()}')),
      );
    }
  }
```

**Kode Lengkap:** [lib/screens/auth/login_screen.dart](lib/screens/auth/login_screen.dart)

```dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../dashboard/dashboard_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> register() async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      // Jika sukses, langsung arahkan ke Dashboard
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => DashboardScreen()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Register Gagal: ${e.toString()}')),
      );
    }
  }
```

**Kode Lengkap:** [lib/screens/auth/register_screen.dart](lib/screens/auth/register_screen.dart)

```dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'order_form_screen.dart';
import '../profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final CollectionReference orders = FirebaseFirestore.instance.collection(
    'pesanan_lumubi',
  );
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool _isInit = true;

  @override
  void initState() {
    super.initState();
    _initNotifikasi();
    _dengarkanPerubahanCRUD();
  }

  void _initNotifikasi() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }
```

**Kode Lengkap:** [lib/screens/dashboard/dashboard_screen.dart](lib/screens/dashboard/dashboard_screen.dart)

```dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderFormScreen extends StatefulWidget {
  final String? docId;
  final QueryDocumentSnapshot? currentData;

  OrderFormScreen({this.docId, this.currentData});

  @override
  _OrderFormScreenState createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends State<OrderFormScreen> {
  final _namaController = TextEditingController();
  final _jumlahController = TextEditingController();
  String _status = 'Menunggu Produksi';
  final CollectionReference orders = FirebaseFirestore.instance.collection('pesanan_lumubi');

  @override
  void initState() {
    super.initState();
    if (widget.currentData != null) {
      _namaController.text = widget.currentData!['nama'];
      _jumlahController.text = widget.currentData!['jumlah_box'].toString();
      _status = widget.currentData!['status'];
    }
  }
```

**Kode Lengkap:** [lib/screens/dashboard/order_form_screen.dart](lib/screens/dashboard/order_form_screen.dart)

```dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

```

**Kode Lengkap:** [lib/screens/profile_screen.dart](lib/screens/profile_screen.dart)

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lumubi App',
      home: LoginScreen(),
    );
  }
}
```

**Kode Lengkap:** [lib/main.dart](lib/main.dart)

### 2. Penjelasan

Aplikasi ini adalah sistem manajemen pesanan untuk produk Lumubi yang dibangun menggunakan Flutter dan terintegrasi dengan ekosistem Firebase untuk keperluan autentikasi pengguna dan pengelolaan basis data real-time. Sistem ini memfasilitasi operasi manajemen data (CRUD) yang terhubung langsung dengan sistem ponsel, sehingga mampu memicu notifikasi lokal secara otomatis setiap kali ada pesanan masuk atau perubahan status produksi.

### 3. Output

<img alt="Screenshot Tampilan LMS App" src="Screenshot (1419).png" />
<img alt="Screenshot Tampilan LMS App" src="Screenshot (1420).png" />
<img alt="Screenshot Tampilan LMS App" src="Screenshot (1421).png" />
<img alt="Screenshot Tampilan LMS App" src="Screenshot (1422).png" />
<img alt="Screenshot Tampilan LMS App" src="Screenshot (1423).png" />
<img alt="Screenshot Tampilan LMS App" src="Screenshot (1424).png" />
