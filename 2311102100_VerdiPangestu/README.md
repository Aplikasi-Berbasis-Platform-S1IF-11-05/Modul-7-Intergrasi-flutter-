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
        <strong>Verdi Pangestu</strong>
        <br>
        <strong>2311102100</strong>
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

Pengembangan aplikasi berbasis platform modern saat ini sangat bergantung pada integrasi layanan berbasis awan (cloud services) untuk mempercepat proses pembangunan dan meningkatkan skalabilitas. Salah satu pendekatan yang paling populer adalah Backend-as-a-Service (BaaS), di mana pengembang tidak perlu membangun infrastruktur server dari awal, melainkan memanfaatkan layanan siap pakai yang mencakup autentikasi, basis data, hingga penyimpanan berkas. Firebase dan Supabase merupakan dua platform BaaS terkemuka yang sering diintegrasikan dengan framework lintas platform seperti Flutter. Firebase, yang dikembangkan oleh Google, menggunakan pendekatan basis data NoSQL (seperti Cloud Firestore), sedangkan Supabase hadir sebagai alternatif open-source yang berbasis pada keandalan Relational Database Management System (RDBMS) menggunakan PostgreSQL.

Dalam arsitektur aplikasi Flutter yang terhubung dengan Firebase atau Supabase, sistem autentikasi bertindak sebagai gerbang utama untuk mengamankan data pengguna. Layanan autentikasi ini menyediakan metode verifikasi identitas yang aman, mulai dari login berbasis email dan kata sandi tradisional hingga penyedia pihak ketiga (OAuth) seperti Google atau GitHub. Melalui pustaka resmi (SDK) yang disediakan oleh masing-masing platform, Flutter dapat dengan mudah mengelola sesi pengguna, mendeteksi status perubahan auth state secara real-time, serta menerapkan enkripsi standar industri untuk melindungi kredensial mahasiswa, sehingga setiap pengguna hanya dapat mengakses data yang menjadi haknya.

Selain autentikasi, komponen krusial dalam integrasi ini adalah sinkronisasi data secara real-time antara aplikasi client dan basis data awan. Cloud Firestore pada Firebase maupun fitur Realtime pada Supabase memungkinkan aplikasi Flutter memanfaatkan mekanisme Stream atau Subscription. Mekanisme ini memastikan bahwa setiap perubahan data yang terjadi di server—seperti penambahan, pembaruan, atau penghapusan tugas kuliah—akan langsung direfleksikan ke antarmuka aplikasi (User Interface) pengguna secara instan tanpa perlu memuat ulang (refresh) halaman secara manual. Hal ini sangat mendukung terciptanya pengalaman pengguna (user experience) yang responsif, dinamis, dan interaktif dalam manajemen tugas sehari-hari.

## Tugas Modul 7 

### 1. Source Code

```dart
//Verdi Pangestu
//2311102100
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _tugasList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTugas(); // Ambil data saat halaman pertama kali dibuka
  }

  // === FITUR NOTIFIKASI CRUD ===
  void _showNotification(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blueAccent,
        duration: const Duration(seconds: 2),
      ),
    );
  }

```

**Kode Lengkap:** [lib/home_page.dart]

```dart
//Wildan Fachri Dzulfikar
//2311102107
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/task_model.dart';
import '../../services/auth_service.dart';
import '../../services/task_service.dart';
import '../../widgets/app_notification.dart';
import '../../widgets/task_card.dart';
import '../task/task_form_screen.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
```

**Kode Lengkap:** [lib/screens/home/home_screen.dart](lib/screens/home/home_screen.dart)

```dart
//Verdi Pangestu
//2311102100
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_page.dart'; // Import halaman utama

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final supabase = Supabase.instance.client;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  // Fitur Notifikasi Snackbar Auth
  void _showNotification(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

```

**Kode Lengkap:** [lib/login_page.dart]

```dart
//Verdi Pangestu
//2311102100
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Supabase
  await Supabase.initialize(
    url: 'https://dhqsarcwkkencqubvbyc.supabase.co',
    anonKey: 'sb_publishable_Ox9Pjn1aDGjEm-4bvtPr6w_ZdEQFVW-',
  );

  runApp(const MyApp());
}

```

**Kode Lengkap:** [lib/main.dart]

### 2. Penjelasan

TaskMaster adalah aplikasi manajemen tugas mahasiswa yang dikembangkan menggunakan framework Flutter untuk memenuhi kebutuhan produktivitas akademik. Aplikasi ini dirancang sebagai solusi backend-as-a-service dengan mengintegrasikan Supabase sebagai fondasi utama. Melalui layanan Supabase Auth, aplikasi ini menjamin sistem registrasi dan login yang aman bagi mahasiswa, di mana setiap pengguna memiliki isolasi data tugas yang personal.

Dalam operasionalnya, TaskMaster memanfaatkan basis data relasional PostgreSQL dari Supabase untuk mengelola siklus hidup data tugas secara penuh—mulai dari proses Create (tambah tugas), Read (tampilan daftar tugas real-time), Update (mengelola status penyelesaian tugas), hingga Delete (penghapusan data). Setiap interaksi pengguna terhadap data akan mendapatkan umpan balik instan melalui notifikasi in-app berupa Snackbar yang informatif, memastikan pengguna selalu mendapatkan konfirmasi atas setiap perubahan status tugas. Dengan arsitektur yang ringan dan sinkronisasi berbasis cloud, TaskMaster menjadi alat bantu yang andal bagi mahasiswa dalam mengorganisir beban kerja akademik secara efisien dan terstruktur.
### 3. Output

![alt text](<Registrasi Berhasil-1.png>)
![alt text](<Login Berhasil-1.png>)
![alt text](<Tambah Tugas-1.png>)
![alt text](<Tugas Berhasil Ditambah-1.png>)
![alt text](<Tugas Selesai-1.png>)
![alt text](<Tugas Dihapus-1.png>)