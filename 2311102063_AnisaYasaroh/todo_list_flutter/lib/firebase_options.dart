import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: 'AIzaSyCtlqL8Nkh94ETlNZqnxjhTKrNSSTxxv0s',
      appId: '1:542494036455:android:3ec91a76c3b2c932c4ed42',
      messagingSenderId: '542494036455',
      projectId: 'todo-list-flutter-11aaa',
      storageBucket: 'todo-list-flutter-11aaa.firebasestorage.app',
    );
  }
}