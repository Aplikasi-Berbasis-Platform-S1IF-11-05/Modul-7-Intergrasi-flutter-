// NIM: 2311102155
// Nama: Naya Putwi Setiasih
// Modul 7 - Integrasi Flutter Firebase/Supabase (Notes App CRUD)
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDHbj5y-XFuwJQBZq3KYbKKLEZ7LCM08SM',
    appId: '1:590413954620:web:f2d0d723b9e02d7a3a4d39',
    messagingSenderId: '590413954620',
    projectId: 'modul-7-amanda',
    authDomain: 'modul-7-amanda.firebaseapp.com',
    storageBucket: 'modul-7-amanda.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDvWK9BmI48lPXHPS2yTkXoW248hR-5Fc0',
    appId: '1:590413954620:android:0c749e7af87069983a4d39',
    messagingSenderId: '590413954620',
    projectId: 'modul-7-amanda',
    storageBucket: 'modul-7-amanda.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCtBSJyLYLi69fW-uLKFeFbdUSB5lgkr-M',
    appId: '1:590413954620:ios:0e2dcee9fa8bcc4f3a4d39',
    messagingSenderId: '590413954620',
    projectId: 'modul-7-amanda',
    storageBucket: 'modul-7-amanda.firebasestorage.app',
    iosBundleId: 'com.example.firebase',
  );
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCtBSJyLYLi69fW-uLKFeFbdUSB5lgkr-M',
    appId: '1:590413954620:ios:0e2dcee9fa8bcc4f3a4d39',
    messagingSenderId: '590413954620',
    projectId: 'modul-7-amanda',
    storageBucket: 'modul-7-amanda.firebasestorage.app',
    iosBundleId: 'com.example.firebase',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDHbj5y-XFuwJQBZq3KYbKKLEZ7LCM08SM',
    appId: '1:590413954620:web:f5c72fa9a02420f33a4d39',
    messagingSenderId: '590413954620',
    projectId: 'modul-7-amanda',
    authDomain: 'modul-7-amanda.firebaseapp.com',
    storageBucket: 'modul-7-amanda.firebasestorage.app',
  );
}
