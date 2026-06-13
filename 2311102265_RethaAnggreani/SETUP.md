# BookShelf - Setup Firebase

## Langkah-langkah Konfigurasi Firebase

### 1. Buat Project Firebase
1. Buka [Firebase Console](https://console.firebase.google.com)
2. Klik **Add project** → beri nama `bookshelf-app`
3. Aktifkan Google Analytics (opsional)

### 2. Tambahkan Aplikasi Android
1. Di Firebase Console, klik ikon Android
2. Package name: `com.example.modul_7`
3. Download file `google-services.json`
4. **Letakkan file `google-services.json` di folder `android/app/`**

### 3. Aktifkan Firebase Services
Di Firebase Console:
- **Authentication** → Sign-in method → Enable **Email/Password**
- **Firestore Database** → Create database → Start in **test mode**
- **Cloud Messaging** → Otomatis aktif saat ada google-services.json

### 4. Firestore Rules (Penting!)
Di Firestore → Rules, ganti dengan:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /books/{bookId} {
      allow read, write: if request.auth != null 
        && request.auth.uid == resource.data.userId;
      allow create: if request.auth != null 
        && request.auth.uid == request.resource.data.userId;
    }
  }
}
```

### 5. Update `lib/firebase_options.dart`
**Cara termudah** - gunakan FlutterFire CLI:
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Generate konfigurasi otomatis
flutterfire configure
```

Atau isi manual dengan nilai dari Firebase Console > Project Settings.

### 6. Jalankan Aplikasi
```bash
flutter pub get
flutter run
```

## Struktur Folder
```
lib/
├── main.dart                 # Entry point + tema
├── firebase_options.dart     # Konfigurasi Firebase
├── models/
│   └── book_model.dart       # Model data buku
├── services/
│   ├── auth_service.dart     # Firebase Auth
│   ├── book_service.dart     # Firestore CRUD
│   └── notification_service.dart  # FCM + Local Notif
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── home/
│   │   └── home_screen.dart
│   └── book/
│       ├── book_form_screen.dart
│       └── book_detail_screen.dart
└── widgets/
    ├── book_card.dart
    └── stats_bar.dart
```

## Fitur Aplikasi
- ✅ Login / Register / Logout (Firebase Auth)
- ✅ CRUD Buku (Firestore)
- ✅ Search buku (judul, penulis, kategori)
- ✅ Filter by status baca
- ✅ Push Notification (FCM + Local Notifications)
- ✅ Tema Coklat & Cream
- ✅ Card view daftar buku
- ✅ Stats bar (total, belum, dibaca, selesai)
