# LAPORAN TUGAS PRAKTIKUM
## APLIKASI BERBASIS PLATFORM - MODUL 7 (AUTHENTICATION & CRUD ONLINE)

> [!NOTE]
> **WATERMARK IDENTITAS MAHASISWA**  
> **Nama Lengkap:** Muhammad Aulia Muzzaki Nugraha  
> **NIM:** 2311102051  
> **Kelas:** S1 Rekayasa Perangkat Lunak  

---

## 1. Pendahuluan & Tema Aplikasi

**FocusFlow** adalah sebuah aplikasi manajemen tugas (*Productivity & To-Do List*) yang dirancang dengan desain estetika *Dark Mode* premium menggunakan warna aksen Indigo dan Ungu. Aplikasi ini bertujuan membantu pengguna mengelola tugas harian mereka secara daring (*online*) dengan sinkronisasi waktu nyata (*real-time*). 

Aplikasi ini menerapkan pilar-pilar utama praktikum Modul 7, yaitu:
1. **Authentication:** Pendaftaran (Register) akun baru dan Masuk (Login) menggunakan Supabase Auth.
2. **CRUD Online:** Menyimpan, membaca, mengubah, dan menghapus data tugas dari database PostgreSQL Supabase secara online.
3. **Notifikasi CRUD:** Menampilkan notifikasi tingkat sistem (system-level local notifications) dan in-app Toast/Snackbar setiap kali operasi CRUD (tambah, ubah, ceklis, hapus) berhasil dilakukan.
4. **Watermark:** Mengandung watermark identitas mahasiswa pada *source code* (dalam komentar berkas) serta dokumen laporan ini.

---

## 2. Struktur Proyek & Source Code Watermark

Seluruh file Dart dalam proyek ini telah ditandai dengan watermark komentar header berisi Nama dan NIM:

```dart
/// NIM: 2311102051
/// Nama: Muhammad Aulia Muzzaki Nugraha
/// Kelas: Praktikum Aplikasi Berbasis Platform
```

### Berkas Utama Proyek:
- `lib/config.dart`: Menyimpan identitas mahasiswa dan konfigurasi kredensial Supabase.
- `lib/main.dart`: Titik masuk aplikasi, menginisialisasi modul Supabase & Notifikasi, serta mengelola gerbang autentikasi (`AuthGateway`).
- `lib/models/task_model.dart`: Representasi model data `Task` dengan serialisasi JSON.
- `lib/services/auth_service.dart`: Integrasi Supabase Auth untuk pendaftaran, masuk, dan keluar akun.
- `lib/services/database_service.dart`: Penanganan CRUD (Stream/Future) ke tabel `tasks` Supabase.
- `lib/services/notification_service.dart`: Konfigurasi `flutter_local_notifications` untuk memicu notifikasi sistem.
- `lib/screens/auth_screen.dart`: UI Halaman Login & Register berdesain *glow glassmorphism*.
- `lib/screens/home_screen.dart`: UI Dashboard Utama yang menampilkan statistik kemajuan tugas, pencarian, filter kategori, dan daftar tugas interaktif.
- `lib/widgets/task_modal.dart`: UI Lembar Input (Bottom Sheet) untuk menambah dan mengedit tugas.

---

## 3. Langkah Integrasi & Konfigurasi Backend (Supabase)

Aplikasi ini menggunakan **Supabase** sebagai backend karena proses instalasinya yang bersih dan tidak memerlukan modifikasi konfigurasi Gradle bawaan Android secara rumit.

### Langkah 1: Membuat Proyek Supabase
1. Masuk ke [Supabase Console](https://supabase.com/).
2. Buat proyek baru (*Create a new project*), tentukan nama proyek, kata sandi database, dan pilih region terdekat.
3. Tunggu hingga proyek selesai disiapkan.

### Langkah 2: Membuat Tabel Database (`tasks`)
1. Buka menu **SQL Editor** pada panel navigasi kiri di dashboard Supabase.
2. Klik **New Query** dan jalankan kode SQL berikut untuk membuat tabel `tasks` dan mengaktifkan Realtime sinkronisasi:

```sql
-- 1. Membuat tabel tasks
create table tasks (
  id uuid default gen_random_uuid() primary key,
  title text not null,
  description text default '',
  category text default 'General',
  priority text default 'Medium',
  due_date timestamp with time zone not null,
  is_completed boolean default false,
  user_id uuid references auth.users(id) on delete cascade not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 2. Mengaktifkan fitur Realtime Stream pada tabel tasks
alter publication supabase_realtime add table tasks;
```

3. Jalankan tombol **Run**. Tabel `tasks` kini telah berhasil dibuat dan terintegrasi dengan data otentikasi user.

### Langkah 3: Konfigurasi Kredensial di Kode Flutter
1. Buka dashboard proyek Supabase Anda, masuk ke **Project Settings** -> **API**.
2. Salin **Project URL** dan **anon (public) API Key**.
3. Buka file `lib/config.dart` dalam kode Flutter Anda, lalu gantikan placeholder dengan URL dan Anon Key Anda:

```dart
class Config {
  // Watermark info
  static const String studentName = "Muhammad Aulia Muzzaki Nugraha";
  static const String studentNim = "2311102051";

  // Ganti dengan kredensial Supabase Anda
  static const String supabaseUrl = "https://your-project-id.supabase.co";
  static const String supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.your-key-here";
}
```

---

## 4. Alur Kerja & Fitur Utama Aplikasi

### A. Autentikasi Pengguna
- **Registrasi Akun:** Pengguna memasukkan Nama Lengkap, Email, dan Password (min. 6 karakter). Akun baru akan terdaftar di database Supabase Auth.
- **Login Akun:** Sistem memvalidasi kredensial pengguna. Setelah sukses, token sesi disimpan dan pengguna secara otomatis diarahkan ke Dashboard utama melalui widget `AuthGateway`.
- **Session Persistence:** Pengguna yang sudah login sebelumnya tidak perlu login kembali saat membuka aplikasi karena status sesi dipantau langsung melalui Stream `onAuthStateChange`.

### B. Sinkronisasi CRUD Online
- **Create (Tambah Tugas):** Menekan tombol "+" akan menampilkan Bottom Sheet. Data dikirim ke tabel `tasks` secara online beserta ID pengguna saat ini.
- **Read (Membaca Tugas):** Tugas disajikan dalam bentuk daftar. Sistem menggunakan `StreamBuilder` untuk memantau perubahan data tabel secara *real-time*. Jika API realtime belum diaktifkan, aplikasi memiliki mekanisme *fallback* otomatis ke Future HTTP Polling biasa dengan fitur *Swipe to Refresh*.
- **Update (Ubah Tugas):** Pengguna dapat mengubah nama, kategori, prioritas, tanggal tenggat tugas, atau menandai tugas selesai (memicu pembaruan status `is_completed` melalui Checkbox).
- **Delete (Hapus Tugas):** Pengguna dapat menghapus tugas dengan menggeser kartu tugas ke arah kiri (*Swipe to Dismiss*) atau menekan tombol edit lalu menghapusnya.

### C. Notifikasi CRUD
Setiap kali tindakan CRUD dilakukan, notifikasi lokal tingkat sistem akan muncul di bilah notifikasi ponsel pengguna:
- **Tambah:** Notifikasi *"Tugas Dibuat! 📝"* dengan detail judul tugas.
- **Ubah/Edit:** Notifikasi *"Tugas Diperbarui! 🔄"*.
- **Selesai Tugas:** Notifikasi *"Tugas Selesai! 🎉"* untuk mengapresiasi pengguna.
- **Hapus:** Notifikasi *"Tugas Dihapus 🗑️"*.

---

## 5. Bukti Integrasi & Tangkapan Layar (Screenshots)

> [!IMPORTANT]
> **Petunjuk Pengumpulan:**  
> Untuk memenuhi syarat tugas, silakan ambil tangkapan layar (screenshot) berikut dari laptop Anda dan masukkan filenya ke dalam direktori proyek ini (misal dalam folder `assets/images/`), lalu perbarui link di bawah ini.

1. **Dashboard Supabase Auth (Daftar Pengguna / Users):**
   ![Supabase Auth Users](assets/images/supabase_auth_users.png)
   *(Menunjukkan email pengguna yang telah sukses mendaftar melalui aplikasi)*

2. **Supabase Table Editor (Isi Tabel `tasks`):**
   ![Supabase Table Tasks](assets/images/supabase_table_tasks.png)
   *(Menunjukkan data tugas yang telah disinkronkan ke database online)*

---

## 6. Cara Menjalankan Aplikasi Secara Lokal

Ikuti langkah-langkah berikut untuk menguji dan menjalankan aplikasi pada simulator atau perangkat fisik Anda:

1. Pastikan Flutter SDK telah terinstal (versi `>=3.11.0`).
2. Masuk ke direktori proyek:
   ```bash
   cd d:/CODING/modul7
   ```
3. Unduh seluruh dependensi yang diperlukan:
   ```bash
   flutter pub get
   ```
4. Hubungkan perangkat emulator Android/iOS Anda atau colokkan perangkat fisik Anda.
5. Jalankan aplikasi:
   ```bash
   flutter run
   ```

---

## 7. Penanganan Masalah (Troubleshooting)

### Error: `Dependency ':flutter_local_notifications' requires core library desugaring to be enabled`
Jika Anda menemui galat ini saat melakukan `flutter run` atau `flutter build apk`, itu disebabkan oleh modul notifikasi lokal yang memerlukan Java 8+ API desugaring agar dapat bekerja pada perangkat Android versi lama.

**Solusi yang telah diterapkan:**
Kami telah mengonfigurasi file `android/app/build.gradle.kts` dengan mengaktifkan flag `isCoreLibraryDesugaringEnabled` dan menambahkan dependensi desugaring berikut:
```kotlin
android {
    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        // ...
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
```

---
> **Laporan Modul 7 - Praktikum Aplikasi Berbasis Platform**  
> Disusun oleh: **Muhammad Aulia Muzzaki Nugraha (2311102051)**
