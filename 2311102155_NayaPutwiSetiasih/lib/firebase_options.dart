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
    apiKey: 'AIzaSyA_LH27YWjneGr2WwgfSprZzWOD3b215n4',
    appId: '1:190977128208:web:ee73d96cf59491c5271795',
    messagingSenderId: '190977128208',
    projectId: 'tugas7-naya',
    authDomain: 'tugas7-naya.firebaseapp.com',
    storageBucket: 'tugas7-naya.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBvwIVUBe42rAOF38ztROWVsATjWs63mDc',
    appId: '1:190977128208:android:baf28a108df423e6271795',
    messagingSenderId: '190977128208',
    projectId: 'tugas7-naya',
    storageBucket: 'tugas7-naya.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCoh6aG5BFwS5qDUGaHgnMfwnaW0sVQ1SI',
    appId: '1:190977128208:ios:53cb944b26b6cee5271795',
    messagingSenderId: '190977128208',
    projectId: 'tugas7-naya',
    storageBucket: 'tugas7-naya.firebasestorage.app',
    iosBundleId: 'com.example.firebase',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCoh6aG5BFwS5qDUGaHgnMfwnaW0sVQ1SI',
    appId: '1:190977128208:ios:53cb944b26b6cee5271795',
    messagingSenderId: '190977128208',
    projectId: 'tugas7-naya',
    storageBucket: 'tugas7-naya.firebasestorage.app',
    iosBundleId: 'com.example.firebase',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyA_LH27YWjneGr2WwgfSprZzWOD3b215n4',
    appId: '1:190977128208:web:9e902e0c3151b07b271795',
    messagingSenderId: '190977128208',
    projectId: 'tugas7-naya',
    authDomain: 'tugas7-naya.firebaseapp.com',
    storageBucket: 'tugas7-naya.firebasestorage.app',
  );
}
