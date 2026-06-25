# Pinote Design Guidelines

## 1. Design Philosophy

Pinote adalah aplikasi To-Do List modern yang dirancang untuk membantu pengguna mengelola tugas dengan cepat, tenang, dan tanpa hambatan. Fokus utama desain adalah:

- Kemudahan penggunaan
- Produktivitas yang terasa alami
- Visual yang bersih, hangat, dan modern
- Pengalaman yang nyaman untuk penggunaan jangka panjang
- Konsistensi antar layar dan komponen

Gaya visual yang diusung adalah Modern, Clean, Minimalist, dan User Friendly. Desain harus terasa lembut, warm, dan tidak membebani mata, sambil tetap menjaga kejelasan informasi dan hierarki visual yang kuat.

---

## 2. Color Palette

### Primary Color
- Primary Color: #F7E9CF
- Digunakan sebagai warna dominan untuk latar utama, elemen brand, dan area yang ingin terasa hangat dan nyaman.

### Supporting Colors

| Role | Color | Usage |
|---|---|---|
| Secondary Background | #F5EFE6 | Background panel, section container |
| Surface / Card | #FFFDF8 | Card, modal, list item |
| Primary Button | #8A5A44 | CTA utama, action utama |
| Secondary Button | #E8D8C2 | Button alternatif, tindakan sekunder |
| App Bar | #FFF6E5 | Header area |
| Floating Action Button | #A96A46 | Tombol tambah tugas |
| Icon Color | #6F4E37 | Ikon aktif dan navigasi |
| Text Primary | #2F241D | Teks utama |
| Text Secondary | #6E6258 | Teks penjelas |
| Border / Divider | #D8CDBE | Garis pembatas dan outline |
| Success | #4F9D69 | Status selesai |
| Warning | #D9872F | Status menunggu / perhatian |
| Error | #C94F4F | Error / gagal |
| Info | #4A90E2 | Informasi tambahan |
| Text Field Fill | #FCF8F1 | Input field background |

### Accessibility Notes
- Pastikan semua teks memiliki kontras yang cukup sesuai WCAG.
- Target minimal:
  - Body text: contrast ratio ≥ 4.5:1
  - Large text / UI elements: contrast ratio ≥ 3:1
- Hindari penggunaan warna saja sebagai satu-satunya penanda status. Sertakan ikon atau label tambahan.

---

## 3. Typography System

### Font Family
- Primary Font: Poppins
- Gunakan Google Fonts: Poppins

### Type Scale

| Element | Size | Weight | Line Height |
|---|---:|---|---:|
| Heading 1 | 32px | 700 | 40px |
| Heading 2 | 24px | 600 | 32px |
| Heading 3 | 20px | 600 | 28px |
| Subheading | 18px | 500 | 26px |
| Body Large | 16px | 400 | 24px |
| Body Regular | 14px | 400 | 22px |
| Caption | 12px | 400 | 18px |
| Button | 14px or 16px | 600 | 20px |

### Typography Rules
- Gunakan font weight 400 untuk teks normal, 500 untuk subheading, 600–700 untuk judul penting.
- Line height yang nyaman: 1.4–1.6 untuk body text.
- Hindari teks terlalu padat; pastikan spasi antar baris cukup lega.
- Untuk tombol, gunakan ukuran yang jelas dan konsisten.

---

## 4. Spacing System

Gunakan sistem spacing berbasis 8px grid untuk menjaga konsistensi visual.

### Spacing Scale
- 4px: ruang tipis antar elemen kecil
- 8px: spacing dasar
- 12px: spacing menengah
- 16px: padding standar layar
- 24px: jarak antar section
- 32px: jarak besar antar blok UI
- 48px: jarak pada layout utama yang lebih luas

### Layout Standards
- Margin horizontal layar: 16px minimum, 24px pada layar lebih besar
- Padding konten card: 16px sampai 20px
- Padding form input: 14px–16px
- Gap antar elemen vertical: 8px–16px

### Border Radius
- Small: 8px
- Medium: 12px
- Large: 16px
- Full pill: 999px

### Elevation / Shadow
- Level 0: no shadow
- Level 1: subtle shadow, opacity rendah
- Level 2: card / modal elevation
- Level 3: floating action button / important surface

---

## 5. Component Guidelines

### App Bar
- Gunakan app bar yang bersih dengan title singkat dan jelas.
- Tambahkan action icon bila perlu, tetapi jangan terlalu padat.
- Pastikan tinggi app bar nyaman untuk satu tangan.
- Gunakan ikon minimalis dan konsisten.

### Bottom Navigation Bar
- Gunakan 3–5 item maksimum.
- Item utama: Home, Tasks, Profile.
- Ikon harus jelas dan mudah dikenali.
- Aktif state harus terlihat jelas dengan warna primary atau icon tint yang lebih kuat.

### Floating Action Button
- Letakkan di pojok kanan bawah.
- Gunakan warna kontras agar mudah terlihat.
- Tombol tambah tugas harus selalu mudah dijangkau dengan satu tangan.

### Task Card
- Gunakan card dengan rounded corners, padding yang konsisten, dan sedikit shadow.
- Sediakan elemen: checkbox, title, due date, tag/category, dan action icon.
- Prioritaskan informasi terpenting di bagian atas card.
- Hindari card terlalu padat.

### Checkbox
- Ukuran minimal 20px–24px.
- Gunakan warna utama atau warna status selesai.
- Berikan feedback visual saat ditekan.

### Search Bar
- Letakkan di bagian atas layar home.
- Gunakan rounded container.
- Tambahkan icon search dan clear action.
- Pastikan field cukup lebar dan nyaman untuk input thumb.

### Text Field
- Gunakan outline atau filled style yang lembut.
- Label harus jelas dan tidak terlalu dekat dengan input.
- Tambahkan hint text yang membantu pengguna.
- Berikan state focus, error, dan disabled yang terlihat jelas.

### Modal Bottom Sheet
- Digunakan untuk tindakan cepat seperti filter, pilih prioritas, atau opsi task.
- Gunakan tinggi moderat dan spacing yang konsisten.
- Pastikan tombol aksi berada di bawah dengan jarak yang cukup.

### Dialog Konfirmasi
- Gunakan untuk aksi berisiko seperti hapus task.
- Tulisan singkat, jelas, dan langsung ke tujuan.
- Sediakan dua tombol: utama dan sekunder.

### Empty State
- Tampilkan ilustrasi sederhana, pesan singkat, dan tombol aksi jika relevan.
- Fokus pada dukungan pengguna saat belum ada data.

### Loading State
- Gunakan skeleton atau shimmer ringan.
- Hindari layar kosong saat data sedang dimuat.

### Error State
- Tampilkan pesan yang jelas dan tindakan pemulihan.
- Sertakan tombol retry jika memungkinkan.

---

## 6. Screen Layout Guidelines

### Splash Screen
- Tampilkan logo Pinote, nama aplikasi, dan loading indicator singkat.
- Latar belakang menggunakan warna utama.
- Pastikan tampilan bersih dan tidak terlalu ramai.
- Fokus pada branding dan transisi yang halus.

### Onboarding (jika diperlukan)
- Maksimal 3 layar onboarding.
- Gunakan bahasa sederhana dan visual yang jelas.
- Tombol utama ditempatkan di bawah dengan skema yang konsisten.
- Sediakan opsi skip untuk pengalaman yang lebih cepat.

### Home Screen
- Tata letak utama:
  - Header dengan greeting dan search bar
  - Ringkasan task / progress
  - List task yang terorganisir
  - Bottom navigation
  - Floating action button di bawah kanan
- Prioritas visual harus jelas: task penting dan yang mendekati deadline lebih menonjol.
- Pastikan elemen mudah dijangkau dengan satu tangan.

### Create Task Screen
- Gunakan form yang terstruktur dan mudah diisi.
- Susun elemen secara vertikal: title, description, category, due date, priority, reminder.
- Tombol simpan ditempatkan di area bawah yang mudah dijangkau.
- Hindari form terlalu panjang; gunakan section yang ringkas.

### Task Detail Screen
- Tampilkan informasi utama di bagian atas.
- Sertakan status, tanggal, prioritas, dan deskripsi.
- Tombol edit dan delete ditempatkan dengan jelas.
- Pastikan konten tidak terlalu padat dan mudah dibaca.

### Profile / Settings Screen
- Tempatkan avatar atau inisial pengguna di bagian atas.
- Susun menu setting secara rapi dan mudah dipahami.
- Gunakan icon yang konsisten dan teks yang singkat.
- Sertakan opsi theme, notifications, about, dan support.

---

## 7. Accessibility Guidelines

Pinote harus mudah digunakan oleh berbagai jenis pengguna, termasuk pengguna dengan kebutuhan aksesibilitas.

### Prinsip yang diterapkan
- Gunakan ukuran teks yang cukup besar dan nyaman dibaca.
- Pastikan target button minimal 44x44 dp.
- Berikan label yang jelas untuk ikon dan form field.
- Sertakan fokus visual yang terlihat saat navigasi keyboard atau screen reader.
- Hindari elemen yang terlalu rapat atau terlalu kecil.
- Pastikan semua interaksi dapat dipahami tanpa bergantung pada warna saja.

### Rekomendasi WCAG
- Text contrast minimum sesuai standar WCAG AA.
- Button dan touch target cukup besar.
- Gunakan semantics yang benar pada Flutter widgets.
- Dukung screen reader dengan label yang deskriptif.

---

## 8. Responsive Design Rules

Desain harus adaptif untuk berbagai ukuran layar.

### Aturan Utama
- Gunakan layout yang fleksibel pada mobile, tablet, dan desktop.
- Hindari overflow dengan memanfaatkan layout builder dan responsive widgets.
- Jaga jarak antar elemen tetap konsisten.
- Untuk layar sempit, prioritaskan konten utama dan kurangi elemen yang tidak penting.
- Untuk layar lebih luas, gunakan ruang yang lebih lega dan tata letak yang lebih lapang.

### Praktik yang disarankan
- Gunakan `LayoutBuilder` atau media query untuk menyesuaikan ukuran.
- Gunakan `SafeArea` dan `Expanded` secara tepat.
- Pastikan scroll view bekerja dengan baik untuk form panjang.
- Hindari fixed-size yang dapat memecah layout pada device berbeda.

---

## 9. Dark Mode Strategy

Pinote harus mendukung light dan dark mode secara konsisten.

### Light Mode
- Latar utama warm beige.
- Teks gelap agar mudah dibaca.
- Card dan surface tetap terang namun tidak terlalu putih.

### Dark Mode
- Gunakan latar gelap dengan nuansa warm brown/charcoal.
- Teks utama tetap terang dan kontras.
- Elemen interaktif tetap terlihat jelas dan tidak kehilangan hierarki.

### Prinsip Dark Mode
- Jangan hanya membalik warna; sesuaikan kontras dan visibilitas.
- Pastikan status warna tetap mudah dipahami.
- Gunakan warna yang tetap nyaman untuk mata pada malam hari.

---

## 10. Flutter Implementation Recommendations

### Teknologi dan Arsitektur
- Gunakan Flutter dengan Material 3.
- Definisikan tema di file tema terpusat.
- Gunakan `ThemeData` dan `ColorScheme` untuk menjaga konsistensi visual.
- Gunakan Google Fonts untuk Poppins.
- Bangun komponen UI reusable agar mudah dipelihara.
- Siapkan struktur yang clean architecture ready untuk memisahkan UI, state, dan business logic.

### Recommended Implementation Approach
- Buat tema pusat di `app_theme.dart`.
- Definisikan warna, typo, spacing, dan shadow di satu tempat.
- Gunakan reusable widget seperti:
  - `PinoteAppBar`
  - `PinoteButton`
  - `PinoteTaskCard`
  - `PinoteTextField`
  - `PinoteBottomNav`
- Gunakan `Theme.of(context).colorScheme` untuk semua warna UI.
- Gunakan `GoogleFonts.poppinsTextTheme()` untuk typography.
- Pastikan semua layar mengikuti prinsip spacing dan accessibility yang sama.

### Suggested Theme Direction
- `useMaterial3: true`
- `colorScheme` berbasis warna warm neutral dan brown accent
- `textTheme` menggunakan Poppins
- `scaffoldBackgroundColor` mengikuti warna utama atau secondary background tergantung mode
- `elevation` dan `shape` konsisten di seluruh komponen

---

## Final Design Summary

Pinote dirancang sebagai aplikasi to-do list yang terasa hangat, modern, dan mudah digunakan. Desain ini menyeimbangkan estetika visual, fungsionalitas, dan aksesibilitas agar memberikan pengalaman pengguna yang nyaman, produktif, dan konsisten di semua layar.
