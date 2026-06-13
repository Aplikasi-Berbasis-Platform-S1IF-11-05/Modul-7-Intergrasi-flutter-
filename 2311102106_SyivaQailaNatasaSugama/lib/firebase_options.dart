// File ini harus di-generate menggunakan FlutterFire CLI:
//   flutterfire configure
//
// Untuk sementara, isi nilai di bawah ini dengan konfigurasi Firebase project Anda.
// Buka Firebase Console -> Project Settings -> Your Apps -> Web App Config
// lalu salin nilai-nilai tersebut ke sini.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
        return windows;
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCTgZmiHDc0Tq7yCj_QKTWrvy3keormADQ',
    appId: '1:367006821907:android:8b2a52506d1749026d19e6',
    messagingSenderId: '367006821907',
    projectId: 'praktikum-flutter-6b973',
    storageBucket: 'praktikum-flutter-6b973.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBe1cf3LKpsFScWoWhSscRsoJYHw7QgW_8',
    appId: '1:367006821907:ios:710ca49248a02b866d19e6',
    messagingSenderId: '367006821907',
    projectId: 'praktikum-flutter-6b973',
    storageBucket: 'praktikum-flutter-6b973.firebasestorage.app',
    iosBundleId: 'com.example.modul7',
  );
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDoZnJq91P0sXUtWoonRPHl-KEOKGxnY7w',
    appId: '1:367006821907:web:ef29c34fce0f73ad6d19e6',
    messagingSenderId: '367006821907',
    projectId: 'praktikum-flutter-6b973',
    authDomain: 'praktikum-flutter-6b973.firebaseapp.com',
    storageBucket: 'praktikum-flutter-6b973.firebasestorage.app',
    measurementId: 'G-9PVM6V063H',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBe1cf3LKpsFScWoWhSscRsoJYHw7QgW_8',
    appId: '1:367006821907:ios:710ca49248a02b866d19e6',
    messagingSenderId: '367006821907',
    projectId: 'praktikum-flutter-6b973',
    storageBucket: 'praktikum-flutter-6b973.firebasestorage.app',
    iosBundleId: 'com.example.modul7',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDoZnJq91P0sXUtWoonRPHl-KEOKGxnY7w',
    appId: '1:367006821907:web:e75d9131b25791a06d19e6',
    messagingSenderId: '367006821907',
    projectId: 'praktikum-flutter-6b973',
    authDomain: 'praktikum-flutter-6b973.firebaseapp.com',
    storageBucket: 'praktikum-flutter-6b973.firebasestorage.app',
    measurementId: 'G-YVPJZ2P2Z8',
  );
}
