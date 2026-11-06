# Issue: Inisialisasi Proyek Flutter & Setup Fondasi Arsitektur

## 1. Deskripsi & Tujuan
Membuat proyek Flutter baru dari awal di direktori ini, menetapkan identifier aplikasi yang sesuai, menyusun struktur folder berbasis arsitektur MVVM (Model-View-ViewModel/Controller) dengan dukungan reusable components, serta mengonfigurasi tema aplikasi agar selalu berjalan dalam **Dark Mode**.

Dokumen ini ditujukan sebagai panduan eksekusi tingkat tinggi (*high-level roadmap*) bagi programmer atau AI agent pelaksana.

---

## 2. Rincian Kebutuhan (Requirements)

### A. Inisialisasi Proyek Flutter
- **Lokasi:** Root folder saat ini (`micin-mobile`).
- **Application ID / Package Name:** `com.micinproject.app`
- **Output:** File konfigurasi platform dasar (Android, iOS, dll.) dengan namespace `com.micinproject.app`.

### B. Arsitektur & Struktur Folder Proyek
Terapkan arsitektur modular berbasis **MVVM (Model - View - ViewModel / Controller)** yang memisahkan logika bisnis, tampilan antarmuka, dan manajemen data:

1. **Model:** Representasi data, model entitas, dan serialisasi data.
2. **View:** UI/Screen antarmuka pengguna tanpa memuat business logic yang kompleks.
3. **ViewModel / Controller:** Penanganan state, event handling, dan logika presentasi per fitur.
4. **Reusable Components:** Folder khusus untuk komponen UI bersama (*shared/common widgets*) seperti custom button, input field, card, app bar, modal dialog, dsb.

**Panduan Struktur Direktori yang Direkomendasikan:**
```text
lib/
├── core/
│   ├── components/      # Reusable UI widgets (buttons, inputs, cards, etc.)
│   ├── constants/       # App constants (strings, assets, dimensi)
│   └── theme/           # Konfigurasi tema & style
├── models/              # Data models / entities
├── viewmodels/          # Logika presentasi & state management (Controller/ViewModel)
├── views/               # Tampilan layar (Screens/Pages)
└── main.dart            # Entry point aplikasi
```
*(Catatan: Pelaksana dapat menyesuaikan ke pola feature-first jika diperlukan, selama prinsip MVVM dan pemisahan komponen tetap konsisten).*

### C. Konfigurasi Tema (Selalu Dark Mode)
- **Mode Tampilan:** Aplikasi **wajib** selalu tampil dalam **Dark Mode**, terlepas dari pengaturan tema sistem pada perangkat pengguna.
- **Konfigurasi `MaterialApp`:**
  - Mengatur `themeMode: ThemeMode.dark`.
  - Menyediakan `darkTheme` terdefinisi menggunakan skema warna gelap (misal: background gelap/hitam/slate, teks kontras tinggi, dsb.).
  - Hindari fallback otomatis ke light mode.

---

## 3. Kriteria Penerimaan (Acceptance Criteria)
- [ ] Proyek Flutter terbuat dan dapat di-*build* tanpa konflik konfigurasi di folder `micin-mobile`.
- [ ] Identitas bundle/package aplikasi terkonfirmasi adalah `com.micinproject.app`.
- [ ] Struktur folder mencerminkan pola MVVM dan memiliki direktori khusus untuk reusable components.
- [ ] Saat aplikasi dijalankan pertama kali (misalnya via `flutter run`), tampilan awal langsung menggunakan Dark Mode.
- [ ] Terdapat setidaknya contoh 1 reusable component dan 1 tampilan dasar (skeleton) yang mengikuti struktur arsitektur yang sudah ditentukan.

---

## 4. Catatan untuk Pelaksana
- Pemilihan state management library (misal: `Provider`, `Riverpod`, `Bloc`, `GetX`, atau `ChangeNotifier` bawaan) dibebaskan kepada tim pelaksana sesuai standar tim.
- Hindari hardcoding warna di dalam views; selalu rujuk warna melalui `Theme.of(context)` atau class token warna di modul `theme`.

