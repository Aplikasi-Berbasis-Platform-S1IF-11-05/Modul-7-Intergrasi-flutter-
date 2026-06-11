# Developer Guide: Rawat.in

Dokumentasi teknis ini memuat standar instalasi, resolusi dependensi, dan panduan arsitektur untuk pengembangan aplikasi **Rawat.in**.

Pedoman ini ditujukan sebagai referensi utama *software engineer* guna memastikan konsistensi kode dan efisiensi *development lifecycle* sesuai standar industri.

## 1. Persyaratan Sistem

Pastikan perangkat Anda telah memenuhi persyaratan berikut sebelum menjalankan proyek:

- Flutter SDK (Channel Stable)
- Dart SDK
- Android SDK (untuk kompilasi Android)
- Code Editor (VS Code atau Android Studio)

## 2. Instalasi Dependensi

Unduh seluruh dependensi yang dibutuhkan oleh proyek dengan menjalankan perintah berikut di terminal:

```bash
flutter pub get
```

## 3. Menjalankan Aplikasi

Untuk menjalankan aplikasi pada *emulator* atau perangkat fisik:

```bash
flutter run
```

Untuk melakukan *build* ke format APK (*Release*):

```bash
flutter build apk --release
```

*(File APK akan tersimpan di direktori `build/app/outputs/flutter-apk/`)*

## 4. Arsitektur Proyek

Pengembangan proyek ini menggunakan pemisahan *layer* fungsional standar untuk menjaga kerapian kode:

- **Pages & Widgets**: Mengatur antarmuka pengguna (UI). Folder `pages` menampung layar utama, sedangkan `widgets` menampung komponen UI yang dapat digunakan berulang.
- **Services**: Mengelola logika eksternal dan integrasi pihak ketiga, seperti Firebase Authentication, Cloud Firestore, dan Flutter Local Notifications.
- **Models**: Merepresentasikan struktur data (seperti jadwal obat) untuk mempermudah konversi dan pengelolaan data dari/ke database.

## 5. Troubleshooting

- Jika terdapat *error* pada dependensi atau saat proses *build*, jalankan perintah `flutter clean` lalu `flutter pub get` kembali.
- Pastikan file konfigurasi Firebase (`google-services.json`) sudah terdapat di dalam folder `android/app/`.