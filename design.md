# Penote Design System for AI-Generated Flutter UI

## 1. Purpose

Dokumen ini ditulis agar AI dapat menghasilkan UI Flutter untuk aplikasi Penote dengan hasil yang modern, konsisten, dan siap dipakai. Fokus desain adalah pengalaman pengguna yang terasa hangat, bersih, premium, dan produktif.

Panduan ini harus diperlakukan sebagai instruksi visual yang wajib diikuti. Saat membuat kode, AI harus menghasilkan tampilan yang terasa seperti aplikasi kelas atas, bukan tampilan sederhana atau kuno.

---

## 2. Product Identity

- Nama aplikasi: Penote
- Jenis aplikasi: To-Do List & Task Management
- Nuansa visual: modern, clean, minimal, friendly, warm, premium
- Tujuan utama: membuat pengguna merasa nyaman saat mengatur tugas, agenda, dan aktivitas harian

Brand tone yang diinginkan:
- Hangat dan tidak kaku
- Bersih dan tidak berantakan
- Elegan tetapi tetap ramah
- Fokus pada kenyamanan visual dan alur kerja yang mudah

---

## 3. Design Philosophy

Desain Penote harus memiliki karakter berikut:
- Visual yang lembut, bersih, dan tidak terlalu padat
- Hierarki informasi jelas
- Tombol dan elemen interaktif terlihat menonjol
- Layout tidak terlalu formal, tetapi tetap modern
- Semua elemen harus terasa terukur, proporsional, dan konsisten

Gunakan prinsip berikut saat membuat UI:
- Prioritaskan isi yang paling penting
- Beri ruang kosong yang cukup agar tidak terasa sesak
- Gunakan rounded corners dan shadow halus untuk kesan premium
- Hindari tampilan yang terlalu flat atau terlalu sederhana

---

## 4. Color System

### Primary Color
- Primary: #F7E9CF
- Digunakan sebagai warna dominan untuk background utama, splash screen, dan area branding

### Supporting Palette

| Role | Color | Use |
|---|---|---|
| Secondary Background | #F5EFE6 | Section background, panel lembut |
| Surface / Card | #FFFDF8 | Card, modal, list item |
| Primary Button | #8A5A44 | Tombol utama / CTA |
| Secondary Button | #E8D8C2 | Tombol alternatif |
| FAB | #A96A46 | Tombol tambah tugas |
| App Bar | #FFF6E5 | Header area |
| Icon Active | #6F4E37 | Ikon utama |
| Text Primary | #2F241D | Teks utama |
| Text Secondary | #6E6258 | Teks penjelas |
| Border / Divider | #D8CDBE | Garis pembatas |
| Success | #4F9D69 | Status selesai |
| Warning | #D9872F | Status perhatian |
| Error | #C94F4F | Error |
| Field Fill | #FCF8F1 | Background input |

### Accessibility Requirement
- Semua teks harus memiliki kontras yang cukup sesuai WCAG AA
- Body text minimal 4.5:1 contrast ratio
- Elemen UI besar minimal 3:1 contrast ratio
- Jangan mengandalkan warna saja untuk menyampaikan status

---

## 5. Typography System

### Font Family
- Gunakan Google Fonts Poppins

### Type Scale

| Element | Size | Weight | Line Height |
|---|---:|---|---:|
| Display / Hero | 32px | 700 | 40px |
| Heading | 24px | 600 | 32px |
| Subheading | 18px | 600 | 26px |
| Body Large | 16px | 400 | 24px |
| Body Regular | 14px | 400 | 22px |
| Caption | 12px | 400 | 18px |
| Button | 14px–16px | 600 | 20px |

### Typography Rules
- Gunakan font weight 400 untuk teks biasa
- Gunakan 500–600 untuk subheading dan label penting
- Gunakan 700 untuk judul utama
- Line height body: 1.4–1.6
- Hindari teks terlalu rapat atau terlalu kecil

---

## 6. Spacing System

Gunakan sistem spacing 8px grid.

### Spacing Scale
- 4px: ruang kecil antar elemen
- 8px: spacing dasar
- 12px: spacing menengah
- 16px: padding standar
- 20px–24px: jarak antar section
- 28px–32px: spacing besar
- 40px–48px: ruang layout utama

### Layout Rules
- Margin horizontal minimum 16px, ideal 20px
- Padding konten card 16px–20px
- Padding input field 14px–16px
- Jarak antar elemen vertical 8px–16px

---

## 7. Shape & Elevation

### Border Radius
- Small: 8px
- Medium: 12px
- Large: 16px
- Extra Large: 20px–24px
- Pill: 999px

### Shadow / Elevation
- Level 0: no shadow
- Level 1: shadow halus untuk card ringan
- Level 2: shadow sedang untuk modal dan card penting
- Level 3: shadow kuat untuk FAB dan elemen utama

Gunakan rounded corners yang konsisten. Hindari sudut tajam yang membuat UI terasa kaku.

---

## 8. UI Component Rules

### App Bar
- Gunakan app bar ringan, bersih, dan modern
- Judul singkat, jelas, dan tidak terlalu besar
- Gunakan ikon aksi yang minimal dan konsisten
- Background putih hangat atau beige muda, bukan warna gelap yang terlalu keras

### Bottom Navigation Bar
- Gunakan 2–3 item utama saja
- Home, Tasks, Profile jika perlu
- Aktif state harus terlihat jelas dengan warna lebih tua dan ikon lebih tegas
- Pastikan tinggi navbar nyaman dan tidak terlalu tebal

### Floating Action Button
- Letakkan di kanan bawah
- Gunakan warna aksen yang kontras
- Ukuran tombol cukup besar dan mudah dijangkau satu tangan

### Task Card
- Card harus memiliki rounded corners, padding yang nyaman, dan shadow ringan
- Susun elemen: checkbox, judul, lokasi, waktu, dan aksi
- Pastikan informasi paling penting muncul di bagian atas
- Hindari card yang terlalu padat atau terlalu tinggi

### Checkbox
- Ukuran minimal 24px
- Gunakan warna aksen atau hijau untuk status selesai
- Berikan feedback visual saat ditekan

### Search Bar
- Letakkan di bagian atas layar home
- Gunakan container rounded dengan background lembut
- Sertakan icon search dan clear action

### Text Field
- Gunakan style rounded dan lembut
- Label harus jelas dan tidak terlalu dekat dengan input
- Gunakan hint text yang membantu
- Berikan visual state fokus, error, dan disabled yang jelas

### Modal Bottom Sheet
- Digunakan untuk form pembuatan tugas, filter, dan pilihan cepat
- Muncul dari bawah dengan sudut atas membulat
- Berikan header yang jelas dan tombol aksi di bawah

### Dialog Confirmation
- Singkat, jelas, dan tidak terlalu formal
- Gunakan dua tombol: primary dan secondary

### Empty State
- Tampilkan pesan yang hangat dan jelas
- Sertakan ilustrasi sederhana atau ikon besar
- Tambahkan tombol aksi jika memungkinkan

### Loading State
- Gunakan shimmer atau skeleton ringan
- Jangan tampilkan layar kosong saat data sedang diproses

### Error State
- Tampilkan pesan yang jelas dan solusi cepat
- Sertakan tombol retry jika relevan

---

## 9. Screen Layout Guidelines

### Splash Screen
- Tampilkan logo Penote, nama aplikasi, dan loading indicator singkat
- Background utama menggunakan warna primary #F7E9CF
- Tampilan harus bersih, fokus, dan modern
- Hindari elemen yang terlalu ramai

### Home Screen
- Susun seperti layout modern berikut:
  1. Header greeting
  2. Ringkasan progress / statistik ringan
  3. Search bar
  4. Daftar tugas dalam card
  5. FAB untuk tambah tugas
- Prioritaskan tugas penting dan yang dekat deadline
- Letakkan elemen penting dalam jangkauan satu tangan

### Create Task Screen
- Gunakan form yang bersih dan mudah dipahami
- Susun elemen secara vertikal: judul, tanggal, jam, lokasi, tombol lanjut
- Tombol utama ditempatkan di bagian bawah dengan spacing cukup
- Hindari form yang terasa terlalu panjang

### Task Detail Screen
- Tampilkan informasi utama di bagian atas
- Sertakan status, tanggal, lokasi, dan ringkasan tugas
- Tombol edit dan delete harus terlihat jelas
- Layout harus terasa lega dan tidak sesak

### Profile / Settings Screen
- Gunakan header profil yang rapi
- Tempatkan avatar atau inisial user di bagian atas
- Susun menu setting secara vertikal dengan icon dan label yang konsisten

---

## 10. Visual Style Direction for AI Generation

AI harus menghasilkan tampilan yang memiliki karakter berikut:
- Premium soft aesthetic
- Warm beige background
- White or cream surfaces
- Rounded corners everywhere
- Gentle shadows
- Strong but tasteful contrast
- Spacious layout with breathing room
- Smooth, polished interactions

Jangan hasilkan tampilan:
- terlalu tua
- terlalu flat
- terlalu ramai
- terlalu gelap
- terlalu minimalis sampai terasa kosong
- terlalu rapat
- terlalu kecil tombolnya

---

## 11. Flutter Implementation Rules

Gunakan Flutter modern dengan pendekatan berikut:
- Material 3
- ThemeData terpusat
- ColorScheme terdefinisi dengan warna yang konsisten
- Google Fonts Poppins
- Responsive layout
- Dark mode support
- Accessibility support
- Reusable widgets
- Clean architecture ready

### Implementation Requirements
- Semua warna harus merujuk ke token design system, bukan nilai hardcoded yang acak
- Semua spacing dan radius harus konsisten
- Gunakan `Theme.of(context).colorScheme` untuk warna utama
- Gunakan `GoogleFonts.poppinsTextTheme()` untuk typography
- Gunakan `SafeArea`, `Expanded`, dan `LayoutBuilder` untuk responsivitas
- Pastikan touch target minimal 44x44 dp

### Recommended Reusable Widgets
- `PenoteAppBar`
- `PenotePrimaryButton`
- `PenoteSecondaryButton`
- `PenoteTaskCard`
- `PenoteTextField`
- `PenoteBottomNavBar`
- `PenoteModalSheet`

---

## 12. AI Prompt Instructions

Ketika AI diminta membuat UI Flutter untuk Penote, gunakan instruksi berikut:

1. Bangun UI dengan nuansa warm beige, cream, dan brown soft.
2. Gunakan Poppins sebagai font utama.
3. Pastikan layout modern, bersih, dan tidak padat.
4. Gunakan rounded corners yang konsisten.
5. Beri spacing yang lega dan proporsional.
6. Gunakan card, shadow halus, dan elemen interaktif yang terasa premium.
7. Pastikan tombol besar, jelas, dan mudah diklik.
8. Prioritaskan pengalaman mobile-first.
9. Jaga keterbacaan teks dan kontras warna.
10. Gunakan Material 3 dan widget Flutter modern.

---

## 13. Final Design Standard

Hasil kode UI harus terasa:
- modern
- nyaman dipakai
- premium namun tidak berlebihan
- konsisten di semua layar
- siap digunakan sebagai aplikasi to-do list yang serius dan menyenangkan
