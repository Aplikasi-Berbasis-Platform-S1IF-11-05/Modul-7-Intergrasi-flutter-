// File ini di-generate oleh FlutterFire CLI.
// Jalankan: flutterfire configure
// untuk men-generate file ini dengan konfigurasi Firebase project Anda.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Konfigurasi Firebase default untuk tiap platform.
/// GANTI nilai-nilai di bawah ini dengan konfigurasi Firebase project Anda.
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

  // ============================================================
  // GANTI NILAI DI BAWAH INI DENGAN KONFIGURASI FIREBASE ANDA
  // Dapatkan dari: Firebase Console > Project Settings > Your apps
  // ============================================================

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyD5v4zJoY7U-IUIbiR4iplcT1zHpw6Q40w',
    appId: '1:1064382105666:web:b13704fe1f162506e945db',
    messagingSenderId: '1064382105666',
    projectId: 'benwaiz',
    authDomain: 'benwaiz.firebaseapp.com',
    storageBucket: 'benwaiz.firebasestorage.app',
    measurementId: 'G-Z7BFTN68EP',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB431knPFBQpfZrsi-OJYcQRVPvan4m3uo',
    appId: '1:1064382105666:android:2138a78b349af87fe945db',
    messagingSenderId: '1064382105666',
    projectId: 'benwaiz',
    storageBucket: 'benwaiz.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAmicOFN2YFNEZ9GUYRDXzVzGqbGCkAUxg',
    appId: '1:1064382105666:ios:a89a9fbb9a5b1d38e945db',
    messagingSenderId: '1064382105666',
    projectId: 'benwaiz',
    storageBucket: 'benwaiz.firebasestorage.app',
    iosBundleId: 'com.example.modul7',
  );
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAmicOFN2YFNEZ9GUYRDXzVzGqbGCkAUxg',
    appId: '1:1064382105666:ios:a89a9fbb9a5b1d38e945db',
    messagingSenderId: '1064382105666',
    projectId: 'benwaiz',
    storageBucket: 'benwaiz.firebasestorage.app',
    iosBundleId: 'com.example.modul7',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyD5v4zJoY7U-IUIbiR4iplcT1zHpw6Q40w',
    appId: '1:1064382105666:web:7c42b724ae1c9238e945db',
    messagingSenderId: '1064382105666',
    projectId: 'benwaiz',
    authDomain: 'benwaiz.firebaseapp.com',
    storageBucket: 'benwaiz.firebasestorage.app',
    measurementId: 'G-8G3KQDZECE',
  );
}
