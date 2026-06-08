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
    <strong>Zahra Tsuroyya Poetri</strong>
    <br>
    <strong>2311102127</strong>
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
  <h3>LABORATORIUM HIGH PERFORMANCE <br>FAKULTAS INFORMATIKA <br>UNIVERSITAS TELKOM PURWOKERTO <br>2026</h3>
</div>

<hr>

## Dasar Teori

#### 2.1 Firebase

Firebase merupakan platform Backend-as-a-Service (BaaS) yang dikembangkan oleh Google untuk mendukung pengembangan aplikasi web dan mobile. Firebase menyediakan berbagai layanan backend yang dapat digunakan secara terintegrasi, seperti Authentication, Cloud Firestore, Realtime Database, Cloud Storage, dan Hosting. Dengan memanfaatkan Firebase, pengembang dapat membangun aplikasi tanpa perlu mengelola infrastruktur server secara langsung.

Firebase dirancang untuk mendukung pengembangan aplikasi yang cepat, aman, dan skalabel. Integrasinya yang baik dengan berbagai platform menjadikan Firebase sebagai salah satu layanan backend yang banyak digunakan dalam pengembangan aplikasi modern.

#### 2.2 Supabase

Supabase merupakan platform Backend-as-a-Service (BaaS) open-source yang menyediakan berbagai layanan backend untuk pengembangan aplikasi. Supabase dibangun di atas PostgreSQL dan menawarkan fitur-fitur seperti Authentication, Database, Storage, Realtime, serta API yang dapat digunakan untuk mengelola data aplikasi.

Salah satu keunggulan Supabase adalah penggunaan PostgreSQL sebagai basis data relasional yang mendukung pengelolaan data secara terstruktur. Selain itu, Supabase menyediakan API secara otomatis sehingga memudahkan pengembang dalam mengakses dan memanipulasi data tanpa perlu membangun backend dari awal.

#### 2.3 Firebase Authentication

Firebase Authentication merupakan layanan autentikasi yang disediakan oleh Firebase untuk mengelola identitas pengguna secara aman. Layanan ini mendukung berbagai metode autentikasi, seperti Email dan Password, Google, Facebook, GitHub, serta penyedia autentikasi lainnya.

Firebase Authentication memungkinkan proses registrasi, login, logout, serta pengelolaan sesi pengguna dilakukan dengan lebih mudah. Layanan ini juga menyediakan mekanisme keamanan yang membantu melindungi data dan identitas pengguna.

#### 2.4 Cloud Firestore

Cloud Firestore merupakan layanan basis data NoSQL berbasis cloud yang disediakan oleh Firebase. Data pada Firestore disimpan dalam bentuk collection dan document sehingga memberikan fleksibilitas dalam penyimpanan dan pengelolaan data.

Cloud Firestore mendukung sinkronisasi data secara real-time, akses offline, serta skalabilitas yang tinggi. Struktur data yang fleksibel dan kemampuan integrasi yang baik menjadikan Firestore banyak digunakan dalam pengembangan aplikasi modern yang memerlukan pengelolaan data secara dinamis.

#### 2.5 CRUD (Create, Read, Update, Delete)

CRUD merupakan sekumpulan operasi dasar yang digunakan dalam pengelolaan data pada sistem informasi maupun aplikasi. CRUD terdiri dari empat operasi utama, yaitu Create untuk menambahkan data baru, Read untuk menampilkan atau membaca data, Update untuk mengubah data yang telah ada, dan Delete untuk menghapus data.

Konsep CRUD menjadi dasar dalam pengelolaan data karena memungkinkan pengguna melakukan interaksi secara langsung terhadap data yang tersimpan dalam basis data.

#### 2.6 Flutter

Flutter merupakan framework open-source yang dikembangkan oleh Google untuk membangun aplikasi lintas platform menggunakan satu basis kode (single codebase). Flutter menggunakan bahasa pemrograman Dart dan menyediakan berbagai widget yang dapat digunakan untuk membangun antarmuka pengguna yang responsif dan interaktif.

Dengan pendekatan widget-based, Flutter memungkinkan pengembang menciptakan tampilan aplikasi yang konsisten pada berbagai platform, seperti Android, iOS, Web, dan Desktop. Selain itu, Flutter mendukung fitur hot reload yang mempermudah proses pengembangan dan pengujian aplikasi secara cepat.


## Tugas 7 - Pinspiration 

### Source Code - main.dart

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'pages/login_page.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await NotificationService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const Color pinterestRed =
      Color(0xffE60023);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pinspiration',
      theme: ThemeData(
        useMaterial3: true,

        scaffoldBackgroundColor:
            const Color(0xffFAFAFA),

        colorScheme: ColorScheme.fromSeed(
          seedColor: pinterestRed,
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          foregroundColor: pinterestRed,
        ),

        floatingActionButtonTheme:
            const FloatingActionButtonThemeData(
          backgroundColor: pinterestRed,
          foregroundColor: Colors.white,
        ),

        snackBarTheme: const SnackBarThemeData(
          backgroundColor: pinterestRed,
          contentTextStyle: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      home: const LoginPage(),
    );
  }
}
```

### Source Code - firebase_options.dart

```dart
// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAKfkEzDVsjPABCxm6wKso3Bmj_P3gLOAA',
    appId: '1:362779336588:web:e509244e5f0fb0ea48c0a9',
    messagingSenderId: '362779336588',
    projectId: 'pinspiration-app',
    authDomain: 'pinspiration-app.firebaseapp.com',
    storageBucket: 'pinspiration-app.firebasestorage.app',
    measurementId: 'G-LWJY3TT08D',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBsLx6vtv770fWvgKsWJLWHMqL4xFp749g',
    appId: '1:362779336588:android:deb9a21caac74cc148c0a9',
    messagingSenderId: '362779336588',
    projectId: 'pinspiration-app',
    storageBucket: 'pinspiration-app.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDMxBEKV_rOKoZcQuWcE0odbzyJpk1L914',
    appId: '1:362779336588:ios:18faae4ba9e656fe48c0a9',
    messagingSenderId: '362779336588',
    projectId: 'pinspiration-app',
    storageBucket: 'pinspiration-app.firebasestorage.app',
    iosBundleId: 'com.example.pinspiration',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDMxBEKV_rOKoZcQuWcE0odbzyJpk1L914',
    appId: '1:362779336588:ios:18faae4ba9e656fe48c0a9',
    messagingSenderId: '362779336588',
    projectId: 'pinspiration-app',
    storageBucket: 'pinspiration-app.firebasestorage.app',
    iosBundleId: 'com.example.pinspiration',
  );
}
```

### Source Code - add_edit_pin_page.dart

```dart
import 'package:flutter/material.dart';

import '../services/firestore_service.dart';
import '../services/notification_service.dart';

class AddEditPinPage extends StatefulWidget {
  final String? docId;
  final String? title;
  final String? imageUrl;
  final String? description;

  const AddEditPinPage({
    super.key,
    this.docId,
    this.title,
    this.imageUrl,
    this.description,
  });

  @override
  State<AddEditPinPage> createState() =>
      _AddEditPinPageState();
}

class _AddEditPinPageState
    extends State<AddEditPinPage> {
  final titleController =
      TextEditingController();

  final imageController =
      TextEditingController();

  final descriptionController =
      TextEditingController();

  final firestore =
      FirestoreService();

  bool isLoading = false;

  bool get isEdit =>
      widget.docId != null;

  @override
  void initState() {
    super.initState();

    if (isEdit) {
      titleController.text =
          widget.title ?? '';

      imageController.text =
          widget.imageUrl ?? '';

      descriptionController.text =
          widget.description ?? '';
    }

    imageController.addListener(() {
      setState(() {});
    });
  }

  Future<void> savePin() async {
    if (titleController.text
            .trim()
            .isEmpty ||
        imageController.text
            .trim()
            .isEmpty ||
        descriptionController.text
            .trim()
            .isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
              Text("Semua field wajib diisi"),
        ),
      );
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      if (isEdit) {
        await firestore.updatePin(
          id: widget.docId!,
          title:
              titleController.text.trim(),
          imageUrl:
              imageController.text.trim(),
          description:
              descriptionController.text
                  .trim(),
        );

        await NotificationService
            .showNotification(
          title: "Pinspiration",
          body:
              "Inspirasi berhasil diperbarui",
        );

        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              "Inspirasi berhasil diperbarui",
            ),
          ),
        );
      } else {
        await firestore.addPin(
          title:
              titleController.text.trim(),
          imageUrl:
              imageController.text.trim(),
          description:
              descriptionController.text
                  .trim(),
        );

        await NotificationService
            .showNotification(
          title: "Pinspiration",
          body:
              "Inspirasi berhasil ditambahkan",
        );

        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              "Inspirasi berhasil ditambahkan",
            ),
          ),
        );
      }

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content:
              Text("Terjadi error\n$e"),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget imagePreview() {
    if (imageController.text.isEmpty) {
      return Container(
        height: 220,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius:
              BorderRadius.circular(20),
        ),
        child: const Center(
          child: Icon(
            Icons.image,
            size: 60,
            color: Colors.grey,
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius:
          BorderRadius.circular(20),
      child: Image.network(
        imageController.text,
        height: 220,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder:
            (_, __, ___) =>
                Container(
          height: 220,
          color: Colors.grey.shade200,
          child: const Center(
            child: Text(
              "URL gambar tidak valid",
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xffFAFAFA),

      appBar: AppBar(
        backgroundColor: Colors.white,

        title: Text(
          isEdit
              ? "Edit Inspirasi"
              : "Tambah Inspirasi",
        ),
      ),

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(16),
        child: Column(
          children: [
            imagePreview(),

            const SizedBox(height: 20),

            TextField(
              controller:
                  titleController,
              decoration:
                  InputDecoration(
                labelText:
                    "Judul Inspirasi",
                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius
                          .circular(
                              15),
                ),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller:
                  imageController,
              decoration:
                  InputDecoration(
                labelText:
                    "URL Gambar",
                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius
                          .circular(
                              15),
                ),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller:
                  descriptionController,
              maxLines: 5,
              decoration:
                  InputDecoration(
                labelText:
                    "Deskripsi",
                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius
                          .circular(
                              15),
                ),
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style:
                    ElevatedButton
                        .styleFrom(
                  backgroundColor:
                      const Color(
                          0xffE60023),

                  foregroundColor:
                      Colors.white,

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius
                            .circular(
                                15),
                  ),
                ),

                onPressed:
                    isLoading
                        ? null
                        : savePin,

                child:
                    isLoading
                        ? const CircularProgressIndicator(
                            color:
                                Colors
                                    .white,
                          )
                        : Text(
                            isEdit
                                ? "UPDATE"
                                : "SIMPAN",
                          ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
```

### SOurce Code - edit.blade.php

```php
@extends('template')

@section('title', 'Edit Produk')

@section('content')

<div class="main-container">

    <div class="box">

        <div class="title-box">
            <h2>Edit Produk</h2>
        </div>

        @include('products.form', [
            'route' => route('products.update', $product->id),
            'method' => 'PUT',
            'product' => $product
        ])

    </div>

</div>

@endsection
```

### Source Code - home_page.dart

```dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';
import 'add_edit_pin_page.dart';
import 'login_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();
    final auth = AuthService();

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          "Pinspiration",
          style: TextStyle(
            color: Color(0xffE60023),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Color(0xffE60023),
            ),
            onPressed: () async {
              await auth.logout();

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const LoginPage(),
                ),
                (_) => false,
              );
            },
          )
        ],
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: firestore.getPins(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                "Belum ada inspirasi",
              ),
            );
          }

          return MasonryGridView.count(
            padding: const EdgeInsets.all(12),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final pin = docs[index];

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey
                          .withOpacity(0.15),
                      blurRadius: 10,
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: pin['imageUrl'],
                        fit: BoxFit.cover,
                        placeholder: (_, __) =>
                            Container(
                          height: 200,
                          alignment:
                              Alignment.center,
                          child:
                              const CircularProgressIndicator(),
                        ),
                        errorWidget:
                            (_, __, ___) =>
                                Container(
                          height: 200,
                          color:
                              Colors.grey.shade200,
                          child: const Icon(
                            Icons.image,
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding:
                          const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            pin['title'],
                            style:
                                const TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),

                          const SizedBox(
                            height: 5,
                          ),

                          Text(
                            pin['description'],
                            maxLines: 3,
                            overflow:
                                TextOverflow.ellipsis,
                          ),

                          const SizedBox(
                            height: 10,
                          ),

                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color:
                                      Colors.orange,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          AddEditPinPage(
                                        docId:
                                            pin.id,
                                        title:
                                            pin['title'],
                                        imageUrl:
                                            pin['imageUrl'],
                                        description:
                                            pin['description'],
                                      ),
                                    ),
                                  );
                                },
                              ),

                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () async {
                                  final confirm =
                                      await showDialog(
                                    context:
                                        context,
                                    builder:
                                        (_) =>
                                            AlertDialog(
                                      title:
                                          const Text(
                                        "Hapus Inspirasi",
                                      ),
                                      content:
                                          const Text(
                                        "Yakin ingin menghapus inspirasi ini?",
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () {
                                            Navigator.pop(
                                              context,
                                              false,
                                            );
                                          },
                                          child:
                                              const Text(
                                            "Batal",
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed:
                                              () {
                                            Navigator.pop(
                                              context,
                                              true,
                                            );
                                          },
                                          child:
                                              const Text(
                                            "Hapus",
                                          ),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm !=
                                      true) {
                                    return;
                                  }

                                  await firestore
                                      .deletePin(
                                    pin.id,
                                  );

                                  await NotificationService
                                      .showNotification(
                                    title:
                                        "Pinspiration",
                                    body:
                                        "Inspirasi berhasil dihapus",
                                  );

                                  ScaffoldMessenger.of(
                                          context)
                                      .showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Inspirasi berhasil dihapus",
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),

      floatingActionButton:
          FloatingActionButton(
        backgroundColor:
            const Color(0xffE60023),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const AddEditPinPage(),
            ),
          );
        },
      ),
    );
  }
}
```
### Source Code - login_page.dart

```dart
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'home_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() =>
      _LoginPageState();
}

class _LoginPageState
    extends State<LoginPage> {
  final emailController =
      TextEditingController();

  final passwordController =
      TextEditingController();

  final AuthService authService =
      AuthService();

  bool isLoading = false;

  Future<void> login() async {
    try {
      setState(() {
        isLoading = true;
      });

      await authService.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const HomePage(),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            "Login gagal\n$e",
          ),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xffFAFAFA),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: const BoxDecoration(
                    color: Color(0xffE60023),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.push_pin,
                    color: Colors.white,
                    size: 50,
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Pinspiration",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight:
                        FontWeight.bold,
                    color: Color(
                        0xffE60023),
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  "Temukan dan simpan inspirasi terbaikmu",
                  textAlign:
                      TextAlign.center,
                ),

                const SizedBox(height: 40),

                Card(
                  elevation: 4,
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                            20),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.all(
                            20),
                    child: Column(
                      children: [
                        TextField(
                          controller:
                              emailController,
                          decoration:
                              InputDecoration(
                            labelText:
                                "Email",
                            prefixIcon:
                                const Icon(
                              Icons.email,
                            ),
                            border:
                                OutlineInputBorder(
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                          12),
                            ),
                          ),
                        ),

                        const SizedBox(
                            height: 15),

                        TextField(
                          controller:
                              passwordController,
                          obscureText:
                              true,
                          decoration:
                              InputDecoration(
                            labelText:
                                "Password",
                            prefixIcon:
                                const Icon(
                              Icons.lock,
                            ),
                            border:
                                OutlineInputBorder(
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                          12),
                            ),
                          ),
                        ),

                        const SizedBox(
                            height: 20),

                        SizedBox(
                          width:
                              double.infinity,
                          height: 55,
                          child:
                              ElevatedButton(
                            style:
                                ElevatedButton
                                    .styleFrom(
                              backgroundColor:
                                  const Color(
                                      0xffE60023),
                              foregroundColor:
                                  Colors.white,
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                            15),
                              ),
                            ),
                            onPressed:
                                isLoading
                                    ? null
                                    : login,
                            child:
                                isLoading
                                    ? const CircularProgressIndicator(
                                        color:
                                            Colors
                                                .white,
                                      )
                                    : const Text(
                                        "LOGIN",
                                      ),
                          ),
                        ),

                        const SizedBox(
                            height: 10),

                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const RegisterPage(),
                              ),
                            );
                          },
                          child: const Text(
                            "Belum punya akun? Register",
                            style:
                                TextStyle(
                              color: Color(
                                  0xffE60023),
                            ),
                          ),
                        ),
                      ],
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
}
```

### Source Code - register_page.dart

```dart
import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() =>
      _RegisterPageState();
}

class _RegisterPageState
    extends State<RegisterPage> {
  final emailController =
      TextEditingController();

  final passwordController =
      TextEditingController();

  final AuthService authService =
      AuthService();

  bool isLoading = false;

  Future<void> register() async {
    try {
      setState(() {
        isLoading = true;
      });

      await authService.register(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Registrasi berhasil!",
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content:
              Text("Registrasi gagal\n$e"),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xffFAFAFA),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: const BoxDecoration(
                    color: Color(0xffE60023),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_add,
                    color: Colors.white,
                    size: 45,
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Buat Akun",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight:
                        FontWeight.bold,
                    color:
                        Color(0xffE60023),
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Simpan inspirasi favoritmu",
                  textAlign:
                      TextAlign.center,
                ),

                const SizedBox(height: 35),

                Card(
                  elevation: 4,
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                            20),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.all(
                            20),
                    child: Column(
                      children: [
                        TextField(
                          controller:
                              emailController,
                          decoration:
                              InputDecoration(
                            labelText:
                                "Email",
                            prefixIcon:
                                const Icon(
                              Icons.email,
                            ),
                            border:
                                OutlineInputBorder(
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                          12),
                            ),
                          ),
                        ),

                        const SizedBox(
                            height: 15),

                        TextField(
                          controller:
                              passwordController,
                          obscureText:
                              true,
                          decoration:
                              InputDecoration(
                            labelText:
                                "Password",
                            prefixIcon:
                                const Icon(
                              Icons.lock,
                            ),
                            border:
                                OutlineInputBorder(
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                          12),
                            ),
                          ),
                        ),

                        const SizedBox(
                            height: 20),

                        SizedBox(
                          width:
                              double.infinity,
                          height: 55,
                          child:
                              ElevatedButton(
                            style:
                                ElevatedButton
                                    .styleFrom(
                              backgroundColor:
                                  const Color(
                                      0xffE60023),
                              foregroundColor:
                                  Colors.white,
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                            15),
                              ),
                            ),
                            onPressed:
                                isLoading
                                    ? null
                                    : register,
                            child:
                                isLoading
                                    ? const CircularProgressIndicator(
                                        color:
                                            Colors
                                                .white,
                                      )
                                    : const Text(
                                        "REGISTER",
                                      ),
                          ),
                        ),
                      ],
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
}
```

### Source Code - auth_service.dart

```dart
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential> register(
      String email,
      String password,
      ) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> login(
      String email,
      String password,
      ) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
```

### Source Code - firestore_service.dart

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference pins =
      FirebaseFirestore.instance.collection(
    'pins',
  );

  Future<void> addPin({
    required String title,
    required String imageUrl,
    required String description,
  }) async {
    await pins.add({
      'title': title,
      'imageUrl': imageUrl,
      'description': description,
      'createdAt': Timestamp.now(),
    });
  }

  Future<void> updatePin({
    required String id,
    required String title,
    required String imageUrl,
    required String description,
  }) async {
    await pins.doc(id).update({
      'title': title,
      'imageUrl': imageUrl,
      'description': description,
    });
  }

  Future<void> deletePin(String id) async {
    await pins.doc(id).delete();
  }

  Stream<QuerySnapshot> getPins() {
    return FirebaseFirestore.instance
        .collection('pins')
        .snapshots();
  }
}
```

### Source Code - notification_service.dart

```dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const InitializationSettings settings =
        InitializationSettings(
      android: androidSettings,
    );

    await notifications.initialize(settings);

    await notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'pinspiration_channel',
      'Pinspiration Notification',
      channelDescription:
          'Notification for CRUD activities',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      enableVibration: true,
    );

    const NotificationDetails details =
        NotificationDetails(
      android: androidDetails,
    );

    await notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );
  }
}
```

## Hasil Output

### 1. Resgitrasi

<div>
  <img src="assets/image1.png" width="300" />

  <img src="assets/image2.png" width="300" />
</div>

<br>

### 2. Login

<div>
  <img src="assets/image15.png" width="300" />
</div>

<br>

### 3. Halaman Beranda

<div>
  <img src="assets/image3.png" width="300" />
</div>

<br>

### 4. Tambah Inspirasi

<div>
  <img src="assets/image4.png" width="300" />

  <img src="assets/image5.png" width="300" />

  <img src="assets/image6.png" width="300" />
</div>

<br>

### 5. Edit Inspirasi

<div>
  <img src="assets/image7.png" width="300" />

  <img src="assets/image8.png" width="300" />
</div>

<br>

### 6. Hapus Inspirasi

<div>
  <img src="assets/image9.png" width="300" />

  <img src="assets/image10.png" width="300" />
</div>

<br>

### 7. Notifikasi

<div>
  <img src="assets/image11.png" width="300" />
</div>

<br>

### 8. Logout

<div>
  <img src="assets/image12.png" width="300" />
</div>

<br>

### 9. Authentication

![Hasil Output](assets/image13.png)

### 10. Database

![Hasil Output](assets/image14.png)

## Deskripsi Kode

Kode tersebut merupakan aplikasi mobile berbasis Flutter yang mengimplementasikan layanan Firebase Authentication dan Cloud Firestore untuk membuat aplikasi berbagi inspirasi bernama Pinspiration. Aplikasi ini berfungsi sebagai sistem CRUD (Create, Read, Update, Delete) yang memungkinkan pengguna melakukan registrasi, login, menambahkan inspirasi berupa gambar dan deskripsi, mengubah data, serta menghapus data yang tersimpan pada database Firebase.

Cara kerjanya dimulai dari proses autentikasi pengguna menggunakan Firebase Authentication. Setelah berhasil login, pengguna akan diarahkan ke halaman utama yang menampilkan daftar inspirasi yang diambil secara real-time dari Cloud Firestore. Data dikelola melalui FirestoreService yang menangani proses penyimpanan, pembaruan, penghapusan, dan pengambilan data. Selain itu, aplikasi juga memanfaatkan Local Notification untuk menampilkan notifikasi sistem serta SnackBar sebagai umpan balik langsung kepada pengguna setiap kali operasi CRUD berhasil dilakukan.

Hasil output berupa aplikasi mobile dengan tampilan yang terinspirasi dari Pinterest menggunakan tata letak grid dua kolom. Setiap inspirasi ditampilkan dalam bentuk kartu yang berisi gambar, judul, dan deskripsi. Pengguna dapat menambahkan inspirasi baru melalui form input, mengedit data yang sudah ada, menghapus data melalui tombol aksi, serta menerima notifikasi keberhasilan setiap kali melakukan penambahan, perubahan, atau penghapusan data.
