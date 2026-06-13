// File ini di-generate oleh FlutterFire CLI.
// Jalankan: flutterfire configure
// Lalu ganti isi file ini dengan hasil generate dari perintah tersebut.
//
// CATATAN: Ganti nilai placeholder di bawah dengan konfigurasi Firebase
// proyek Anda yang sebenarnya dari Firebase Console.

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

  // ========================================================
  // GANTI NILAI DI BAWAH DENGAN KONFIGURASI FIREBASE ANDA
  // Dapatkan dari: Firebase Console > Project Settings > Your Apps
  // ========================================================

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDHu1xbuX5dC4ikmadFosveCpDGoTt_yQs',
    appId: '1:333063576817:web:b3b872c8d907c4010ddd50',
    messagingSenderId: '333063576817',
    projectId: 'wildanfachri-a3b62',
    authDomain: 'wildanfachri-a3b62.firebaseapp.com',
    storageBucket: 'wildanfachri-a3b62.firebasestorage.app',
    measurementId: 'G-HJ4HQBSJWJ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAzF4xcri-7k3XB9bvXrVTEOVJ4Y22J8XM',
    appId: '1:333063576817:android:763c4abd1163540f0ddd50',
    messagingSenderId: '333063576817',
    projectId: 'wildanfachri-a3b62',
    storageBucket: 'wildanfachri-a3b62.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBN5aOQwi4L93unnNhxB5KKb7fhJyi-9hA',
    appId: '1:333063576817:ios:bccdbafeca83e09a0ddd50',
    messagingSenderId: '333063576817',
    projectId: 'wildanfachri-a3b62',
    storageBucket: 'wildanfachri-a3b62.firebasestorage.app',
    iosBundleId: 'com.example.modul7',
  );
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBN5aOQwi4L93unnNhxB5KKb7fhJyi-9hA',
    appId: '1:333063576817:ios:bccdbafeca83e09a0ddd50',
    messagingSenderId: '333063576817',
    projectId: 'wildanfachri-a3b62',
    storageBucket: 'wildanfachri-a3b62.firebasestorage.app',
    iosBundleId: 'com.example.modul7',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDHu1xbuX5dC4ikmadFosveCpDGoTt_yQs',
    appId: '1:333063576817:web:f91e7ef73039a85d0ddd50',
    messagingSenderId: '333063576817',
    projectId: 'wildanfachri-a3b62',
    authDomain: 'wildanfachri-a3b62.firebaseapp.com',
    storageBucket: 'wildanfachri-a3b62.firebasestorage.app',
    measurementId: 'G-VXWMRHK42L',
  );
}
