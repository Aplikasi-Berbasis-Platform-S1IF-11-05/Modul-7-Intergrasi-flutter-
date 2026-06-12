// File ini di-generate oleh FlutterFire CLI.
// Jalankan: flutterfire configure
// Dokumentasi: https://firebase.flutter.dev/docs/cli
//
// PENTING: Ganti nilai-nilai di bawah ini dengan konfigurasi Firebase project kamu.
// Dapatkan nilai dari: Firebase Console > Project Settings > General > Your apps

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

  // ============================================================
  // GANTI SEMUA NILAI DI BAWAH INI DENGAN KONFIGURASI FIREBASE MU
  // Cara: Firebase Console > Project Settings > Add App > Android
  // Atau gunakan: flutterfire configure (lebih mudah)
  // ============================================================

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCqK0ezWQpHeQ2K1SZl2hvZ3_lOvuqxPY0',
    appId: '1:930960565436:android:6f6cb07deaee57c9681cb9',
    messagingSenderId: '930960565436',
    projectId: 'jeje-739d0',
    storageBucket: 'jeje-739d0.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAoBiFkt3Yv3LzlRd7HLHKzROumP0fO2_w',
    appId: '1:930960565436:ios:f4785bc6817f123d681cb9',
    messagingSenderId: '930960565436',
    projectId: 'jeje-739d0',
    storageBucket: 'jeje-739d0.firebasestorage.app',
    iosBundleId: 'com.example.modul7',
  );
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCFgA8EB3JZSc_qttbGN9jJfOZUdwtjpgs',
    appId: '1:930960565436:web:b86beb762d67d80e681cb9',
    messagingSenderId: '930960565436',
    projectId: 'jeje-739d0',
    authDomain: 'jeje-739d0.firebaseapp.com',
    storageBucket: 'jeje-739d0.firebasestorage.app',
    measurementId: 'G-YXGS1TSC97',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAoBiFkt3Yv3LzlRd7HLHKzROumP0fO2_w',
    appId: '1:930960565436:ios:f4785bc6817f123d681cb9',
    messagingSenderId: '930960565436',
    projectId: 'jeje-739d0',
    storageBucket: 'jeje-739d0.firebasestorage.app',
    iosBundleId: 'com.example.modul7',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCFgA8EB3JZSc_qttbGN9jJfOZUdwtjpgs',
    appId: '1:930960565436:web:110aecacb3cf5e17681cb9',
    messagingSenderId: '930960565436',
    projectId: 'jeje-739d0',
    authDomain: 'jeje-739d0.firebaseapp.com',
    storageBucket: 'jeje-739d0.firebasestorage.app',
    measurementId: 'G-CD3W80Z16L',
  );
}
