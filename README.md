# MicinProject (micin-mobile)

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Architecture](https://img.shields.io/badge/Architecture-MVVM-green)]()
[![Theme](https://img.shields.io/badge/Theme-Always_Dark_Mode-121212)]()
[![License](https://img.shields.io/badge/License-Proprietary-blue)]()

**MicinProject** adalah aplikasi mobile streaming dan agregator konten siaran berbasis Flutter. Aplikasi ini dirancang dengan performa tinggi, tampilan modern Always Dark Mode, arsitektur MVVM (*Model-View-ViewModel*), pemutar video mutakhir (DASH/HLS & DRM), serta integrasi pemeriksaan pembaruan cerdas.

---

## 📑 Daftar Isi
- [Ikhtisar Arsitektur](#-ikhtisar-arsitektur)
- [Hasil Penting & Fitur Utama](#-hasil-penting--fitur-utama)
- [Struktur Direktori](#-struktur-direktori)
- [Spesifikasi API & Kontrak Data](#-spesifikasi-api--kontrak-data)
- [Mekanisme Pembaruan Otomatis & ABI Dynamic Link](#-mekanisme-pembaruan-otomatis--abi-dynamic-link)
- [Panduan Pengembangan & Menjalankan Aplikasi](#-panduan-pengembangan--menjalankan-aplikasi)
- [Panduan Build & Distribusi APK](#-panduan-build--distribusi-apk)
- [Kebijakan Git & Workflow](#-kebijakan-git--workflow)

---

## 🏛️ Ikhtisar Arsitektur

Aplikasi dibangun mengikuti standar **MVVM (Model - View - ViewModel)** untuk memastikan keterpisahan tanggung jawab (*separation of concerns*), kemudahan pengujian (*testability*), dan skalabilitas kode:

- **Model (`lib/models/`):** Representasi entitas data yang bersih dan immutabel, dilengkapi metode serialisasi/deserialisasi JSON yang aman terhadap nilai `null`.
- **View (`lib/views/`):** Komponen UI deklaratif Flutter yang terbebas dari *business logic* kompleks, berfokus murni pada pengalaman pengguna dan rendering visual.
- **ViewModel (`lib/viewmodels/`):** Berbasis `ChangeNotifier` untuk mengelola state halaman, memicu pemanggilan *service*, memproses event player/jaringan, serta memberitahu View saat terjadi pembaruan status.
- **Service (`lib/services/`):** Lapisan komunikasi jaringan HTTP yang mengisolasi pemanggilan endpoint REST API, penegakan timeout, dan pemformatan error.
- **Core (`lib/core/`):** Konfigurasi global (`AppConfig`), tema aplikasi (`AppTheme`), palet warna (`AppColors`), konstanta (`AppConstants`), serta utilitas perangkat (`AbiHelper`).

---

## 🚀 Hasil Penting & Fitur Utama

Berdasarkan eksplorasi riwayat pengembangan dan seluruh GitHub Issues (`#1` s.d. `#12`), berikut adalah kapabilitas utama aplikasi:

### 1. Fondasi Aplikasi & Always Dark Mode (Issue #1, #2)
- Konfigurasi tema global gelap permanen (*Always Dark Mode*) dengan kontras tinggi dan estetika modern (`#121212` background, `#1E1E1E` surface, dan aksen ungu/primer yang nyaman di mata).
- Pengaturan tooling dasar dan pengujian unit otomatis (*unit & widget tests*).

### 2. Branding Aplikasi & Konfigurasi Terpusat (Issue #3, #4)
- Penamaan aplikasi tersentralisasi sebagai **MicinProject** di seluruh level: Flutter `MaterialApp.title`, Android `AndroidManifest.xml` (`android:label`), dan iOS `Info.plist`.
- Konfigurasi tersentralisasi pada `AppConfig` (`baseUrl`, `checkUpdateUrl`, `defaultHeaders`, dan custom User-Agent).

### 3. Pemeriksaan Pembaruan Cerdas & Version Guard (Issue #5, #6)
- **Automatic Update Check:** Memeriksa ketersediaan versi baru secara otomatis setiap kali aplikasi dibuka.
- **Force Update Dialog:** Modal peringatan non-dismissible saat `is_force_update == true`, memblokir interaksi hingga pengguna memperbarui aplikasi.
- **Version Guard:** Perlindungan akses konten provider menggunakan `min_required_build`. Jika versi build aplikasi di bawah batas minimum yang diminta provider, sistem secara otomatis mengunci akses dan menampilkan notifikasi instruksi pembaruan.
- **Filter Publikasi:** Secara otomatis menyaring hanya konten penyedia yang berstatus `is_publish: true`.

### 4. Footer Dinamis & Konten Provider Adaptif (Issue #7, #8)
- **Footer Status Versi:** Membandingkan versi build lokal dengan versi server secara langsung. Menampilkan tombol pembaruan jika versi tertinggal, atau lencana status **Latest** jika aplikasi up-to-date.
- **Dynamic Copyright Notice:** Menampilkan hak cipta dinamis berbasis tahun berjalan (`Copyright © {tahun} - Micin Project`) secara eksklusif pada halaman beranda.
- **Adaptive Content Card:** Menampilkan konten dari endpoint `BASE_URL/{slug}` secara cerdas: otomatis merender kartu gambar thumbnail jika `has_image == true`, atau kartu kompak berbasis teks jika `has_image == false`.

### 5. Pemutar Video DASH/HLS, ClearKey DRM & PiP (Issue #9, #10)
- **Multi-protocol Streaming:** Mendukung format streaming modern DASH (`.mpd`) dan HLS (`.m3u8`).
- **ClearKey DRM Decryption:** Mendukung dekripsi stream berenkripsi secara otomatis menggunakan pasangan nilai `kid` dan `key` dari server.
- **Preservasi Aspek Rasio Asli:** Tampilan layar penuh (*fullscreen*) menggunakan `BoxFit.contain` dan auto-detection aspek rasio untuk mencegah distorsi/peregangan video yang merusak proporsi visual.
- **Global User-Agent Override:** Menerapkan `AppHttpOverrides` pada tingkat Dart VM serta konfigurasi header BetterPlayer/ExoPlayer native untuk memastikan seluruh panggilan jaringan menggunakan identitas browser resmi (Chrome 157) alih-alih identitas default `Dart/3.13 (dart:io)`.
- **Chat Admin Placeholder:** Tab terdedikasi di bawah video player dengan penanda visual bertuliskan *"Chat Under Development"*.

### 6. Stabilitas PiP pada Real Device & Pencegahan ANR (Issue #11, #12)
- **Stabilitas Picture-in-Picture (PiP):** Menambahkan atribut `android:resizeableActivity="true"` pada Android Manifest dan validasi GlobalKey context sebelum transisi mode PiP untuk mencegah crash atau screen lock pada perangkat Android fisik.
- **Pencegahan Application Not Responding (ANR) HTTP 403:**
  - Menonaktifkan loop retry agresif pada controller video saat server menolak otorisasi.
  - Menangkap event `BetterPlayerEventType.exception` secara real-time dan segera menghentikan pemutaran secara aman (`pause()`).
  - Menampilkan overlay status *"Akses Siaran Dibatasi (403)"* lengkap dengan tombol coba lagi yang responsif tanpa membekukan antarmuka aplikasi.

### 7. Resolusi Tautan APK Otomatis Berdasarkan Arsitektur (ABI Resolution)
- Meresolusi template URL pembaruan `{abi}` dan `{version}` secara dinamis berdasarkan arsitektur CPU perangkat pengguna (`arm64-v8a`, `armeabi-v7a`, `x86_64`), sehingga file unduhan yang didapatkan selalu sesuai (`MicinProject_{abi}_{version}.apk`).

---

## 📁 Struktur Direktori

```text
lib/
├── core/
│   ├── components/         # Widget modular yang dapat digunakan kembali
│   │   ├── provider_card.dart
│   │   └── provider_content_card.dart
│   ├── config/             # Pengaturan endpoint, base URL, dan User-Agent
│   │   └── app_config.dart
│   ├── constants/          # Palet warna, tema Always Dark, dan string konstanta
│   │   ├── app_colors.dart
│   │   └── app_constants.dart
│   ├── theme/              # Definisi ThemeData aplikasi
│   │   └── app_theme.dart
│   └── utils/              # Helper deteksi ABI perangkat dan resolusi URL APK
│       └── abi_helper.dart
├── models/                 # Model data & kontrak JSON
│   ├── app_update_model.dart
│   ├── provider_content_model.dart
│   ├── provider_model.dart
│   └── watch_detail_model.dart
├── services/               # Layanan HTTP client & penanganan response/error
│   ├── provider_service.dart
│   └── update_service.dart
├── viewmodels/             # Logika bisnis, manajemen state, dan controller pemutar
│   ├── home_viewmodel.dart
│   ├── provider_content_viewmodel.dart
│   └── watch_viewmodel.dart
├── views/                  # Tampilan UI deklaratif
│   ├── home/
│   │   └── home_view.dart
│   ├── provider_content/
│   │   └── provider_content_view.dart
│   └── watch/
│       └── watch_view.dart
└── main.dart               # Entry point, Flutter binding, & Dart HttpOverrides
```

---

## 📡 Spesifikasi API & Kontrak Data

| Fitur | Endpoint / URI | Metode | Deskripsi |
| :--- | :--- | :---: | :--- |
| **Check Update** | `BASE_URL/check-update` | `GET` | Memeriksa versi rilis terbaru, status force update, dan URL file APK |
| **Provider List** | `BASE_URL/provider` | `GET` | Mengambil daftar penyedia siaran yang aktif (`is_publish: true`) |
| **Provider Content** | `BASE_URL/{slug}` | `GET` | Mengambil daftar siaran/acara dari provider terpilih |
| **Watch Detail** | `BASE_URL/{slug}/{id}` | `GET` | Mengambil metadata siaran, manifest streaming (DASH/HLS), dan kunci DRM |

---

## 📦 Mekanisme Pembaruan Otomatis & ABI Dynamic Link

Endpoint pemeriksaan pembaruan mendukung pola template URL dinamis:
```json
{
  "data": {
    "latest_version_name": "1.0.0",
    "latest_build_number": 1,
    "is_force_update": false,
    "update_message": "Penambahan server UK dan optimalisasi streaming olahraga.",
    "update_url": "https://github.com/MicinProject-{abi}-{version}.apk"
  },
  "message": "GET_SUCCESS",
  "status": 200
}
```

Aplikasi menggunakan `AbiHelper` untuk menerjemahkan placeholder secara otomatis:
- `{abi}` ➔ digantikan dengan ABI perangkat aktif (misal `arm64-v8a`, `armeabi-v7a`, `x86_64`).
- `{version}` ➔ digantikan dengan nilai `latest_version_name` (misal `1.0.0`).
- Format nama aset rilis yang didukung:
  - `MicinProject_{abi}_{version}.apk` (contoh: `MicinProject_arm64-v8a_1.0.0.apk`)
  - `MicinProject-{abi}-{version}.apk` (contoh: `MicinProject-arm64-v8a-1.0.0.apk`)

---

## 🛠️ Panduan Pengembangan & Menjalankan Aplikasi

### Prasyarat
- Flutter SDK versi 3.13.0 ke atas
- Dart SDK versi 3.x
- Android SDK (API level 26+ direkomendasikan untuk stabilitas PiP)

### Menjalankan Pengujian & Analisis Kode
```bash
# Analisis statis kode (pastikan 0 issues found)
flutter analyze

# Menjalankan seluruh rangkaian unit & widget test
flutter test
```

### Menjalankan Aplikasi di Mode Debug
```bash
flutter run
```

---

## 🚀 Panduan Build & Distribusi APK

Untuk menghasilkan paket APK rilis terpisah berdasarkan arsitektur CPU (*split per ABI*) guna meminimalkan ukuran download pengguna:

```bash
# Build split APK rilis
flutter build apk --split-per-abi --release
```

Output file APK yang dihasilkan pada direktori `build/app/outputs/flutter-apk/`:
1. `app-arm64-v8a-release.apk` ➔ Ubah nama menjadi: `MicinProject_arm64-v8a_1.0.0.apk`
2. `app-armeabi-v7a-release.apk` ➔ Ubah nama menjadi: `MicinProject_armeabi-v7a_1.0.0.apk`
3. `app-x86_64-release.apk` ➔ Ubah nama menjadi: `MicinProject_x86_64_1.0.0.apk`

---

## ⚖️ Kebijakan Git & Workflow

> [!IMPORTANT]
> **Kebijakan Branching & Kontribusi:**
> 1. **Dilarang melakukan *direct commit* langsung ke branch `master`.**
> 2. Seluruh pekerjaan fitur baru atau perbaikan bug **wajib** dilakukan pada branch terpisah (contoh format: `feat/...` atau `fix/...`).
> 3. Penggabungan kode ke branch `master` **wajib** melalui mekanisme **Pull Request (PR)** setelah lulus verifikasi `flutter analyze` dan `flutter test`.
