import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Model data profil user aplikasi Penote.
///
/// Menyimpan informasi identitas user yang dapat diedit
/// melalui [ProfileEditScreen].
class UserProfile {
  UserProfile({required this.name, this.bio, this.avatarPath});

  /// Nama tampilan user.
  String name;

  /// Bio singkat user. Null jika belum diisi.
  String? bio;

  /// Path lokal file foto profil. Null jika belum memilih foto.
  String? avatarPath;
}

// ══════════════════════════════════════════════════════════════════════════════
// ProfileView — Halaman profil full layar
// ══════════════════════════════════════════════════════════════════════════════

/// Halaman profil full-screen yang menampilkan foto, nama, bio,
/// dan menu pengaturan pengguna.
class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

/// State dari [ProfileView] yang mengelola data profil dan navigasi edit.
class _ProfileViewState extends State<ProfileView> {
  /// Data profil user yang sedang ditampilkan.
  late UserProfile _profile;

  /// Menginisialisasi profil default dengan nama "Penote User".
  @override
  void initState() {
    super.initState();
    _profile = UserProfile(name: 'Penote User');
  }

  /// Membuka halaman [ProfileEditScreen] dan memperbarui data profil
  /// jika user menyimpan perubahan.
  Future<void> _editProfile() async {
    final result = await Navigator.of(context).push<UserProfile>(
      MaterialPageRoute(builder: (_) => ProfileEditScreen(profile: _profile)),
    );
    if (result != null) setState(() => _profile = result);
  }

  /// Membangun tampilan halaman profil yang terdiri dari area header bergradien
  /// (foto, nama, bio, tombol edit) dan area menu di bawahnya.
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      body: Column(
        children: [
          // ── Bagian atas: background coklat hangat, foto + nama + bio ──
          Container(
            width: double.infinity,
            // Ambil ~55% tinggi layar untuk area profil
            height: size.height * 0.55,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF8A5A44), Color(0xFFA96A46)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  // Foto profil
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Lingkaran cahaya di belakang avatar
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.15),
                        ),
                      ),
                      // Avatar — tampilkan foto jika ada, ikon orang jika tidak
                      _profile.avatarPath != null
                          ? CircleAvatar(
                              radius: 62,
                              backgroundImage: FileImage(
                                File(_profile.avatarPath!),
                              ),
                              backgroundColor: Colors.transparent,
                            )
                          : CircleAvatar(
                              radius: 62,
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.25,
                              ),
                              child: const Icon(
                                Icons.person_rounded,
                                color: Colors.white,
                                size: 68,
                              ),
                            ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Nama
                  Text(
                    _profile.name,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Bio — tampilkan placeholder miring jika belum ada
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      _profile.bio?.isNotEmpty == true
                          ? _profile.bio!
                          : 'Belum ada bio — tambahkan sekarang',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.85),
                        fontStyle: _profile.bio?.isNotEmpty == true
                            ? FontStyle.normal
                            : FontStyle.italic,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 28),
                  // Tombol Edit Profil
                  GestureDetector(
                    onTap: _editProfile,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.edit_rounded,
                            size: 16,
                            color: Color(0xFF8A5A44),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Edit Profil',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF8A5A44),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Bagian bawah: menu pengaturan ──
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 10),
                    child: Text(
                      'Pengaturan',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF6E6258),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  _MenuCard(
                    children: [
                      _MenuItem(
                        icon: Icons.notifications_none_rounded,
                        label: 'Notifikasi',
                        onTap: () {},
                      ),
                      const _MenuDivider(),
                      _MenuItem(
                        icon: Icons.info_outline_rounded,
                        label: 'Tentang Penote',
                        onTap: () => _showAbout(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Menampilkan dialog informasi tentang aplikasi Penote.
  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFFFDF8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.book_rounded, color: Color(0xFF8A5A44)),
            SizedBox(width: 10),
            Text(
              'Penote',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF2F241D),
              ),
            ),
          ],
        ),
        content: const Text(
          'Penote adalah aplikasi manajemen aktifitas dan catatan harian yang membantu kamu tetap terorganisir.\n\nVersi 1.0.0',
          style: TextStyle(color: Color(0xFF6E6258), height: 1.6),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF8A5A44),
            ),
            child: const Text(
              'Tutup',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Menu widgets ──────────────────────────────────────────────────────────────

/// Kartu kontainer untuk mengelompokkan item menu pengaturan.
///
/// Menggunakan rounded corner dan shadow untuk tampilan yang bersih.
class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.children});

  /// Daftar widget item menu yang akan ditampilkan di dalam kartu.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF8),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

/// Item menu tunggal dengan ikon, label, dan chevron di kanan.
class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  /// Ikon yang ditampilkan di kiri item menu.
  final IconData icon;

  /// Teks label menu.
  final String label;

  /// Callback yang dipanggil ketika item diketuk.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFF8A5A44);
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2F241D),
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: Color(0xFF8A5A44),
        size: 20,
      ),
    );
  }
}

/// Divider tipis yang memisahkan antar item menu dalam [_MenuCard].
class _MenuDivider extends StatelessWidget {
  const _MenuDivider();
  @override
  Widget build(BuildContext context) => const Divider(
    height: 1,
    indent: 56,
    endIndent: 16,
    color: Color(0xFFEDE5D8),
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// ProfileEditScreen — Edit nama, foto, dan bio
// ══════════════════════════════════════════════════════════════════════════════

/// Halaman untuk mengedit nama, foto profil, dan bio pengguna.
///
/// Menerima [profile] yang ada dan mengembalikan [UserProfile] baru
/// setelah user menyimpan perubahan.
class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key, required this.profile});

  /// Data profil saat ini yang akan ditampilkan sebagai nilai awal form.
  final UserProfile profile;

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

/// State dari [ProfileEditScreen] yang mengelola form edit profil.
class _ProfileEditScreenState extends State<ProfileEditScreen> {
  /// Controller untuk field input nama.
  late final TextEditingController _nameCtrl;

  /// Controller untuk field input bio.
  late final TextEditingController _bioCtrl;

  /// Path lokal foto profil yang dipilih. Null jika belum ada.
  String? _avatarPath;

  /// Instance image picker untuk memilih foto dari kamera atau galeri.
  final ImagePicker _picker = ImagePicker();

  /// Menginisialisasi controller dengan data profil yang ada.
  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.profile.name);
    _bioCtrl = TextEditingController(text: widget.profile.bio ?? '');
    _avatarPath = widget.profile.avatarPath;
  }

  /// Membebaskan controller dari memori.
  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  /// Menampilkan bottom sheet untuk memilih sumber foto (kamera atau galeri).
  ///
  /// Setelah foto dipilih, path-nya disimpan ke [_avatarPath] dan
  /// widget diperbarui.
  Future<void> _pickImage() async {
    final result = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFFFFFDF8),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD8CDBE),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Pilih Sumber Foto',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2F241D),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ImageSourceButton(
                  icon: Icons.camera_alt_rounded,
                  label: 'Kamera',
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
                _ImageSourceButton(
                  icon: Icons.photo_library_rounded,
                  label: 'Galeri',
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );

    if (result != null) {
      // Ambil gambar dengan kualitas 80% untuk menghemat storage
      final image = await _picker.pickImage(source: result, imageQuality: 80);
      if (image != null) {
        setState(() => _avatarPath = image.path);
      }
    }
  }

  /// Memvalidasi form dan menyimpan profil yang diperbarui.
  ///
  /// Menampilkan snackbar error jika nama kosong.
  /// Jika valid, menutup halaman dan mengembalikan [UserProfile] baru.
  void _save() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Nama tidak boleh kosong'),
          backgroundColor: const Color(0xFFC94F4F),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    final updatedProfile = UserProfile(
      name: name,
      bio: _bioCtrl.text.trim().isEmpty ? null : _bioCtrl.text.trim(),
      avatarPath: _avatarPath,
    );

    Navigator.of(context).pop(updatedProfile);
  }

  /// Membangun tampilan halaman edit profil dengan AppBar, avatar editor,
  /// form nama dan bio, serta tombol simpan.
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF6E5),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF2F241D),
            size: 20,
          ),
        ),
        title: Text(
          'Edit Profil',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2F241D),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Avatar editor dengan tombol kamera overlay
              Center(
                child: Stack(
                  children: [
                    // Tampilkan foto jika ada, ikon orang jika tidak
                    _avatarPath != null
                        ? CircleAvatar(
                            radius: 60,
                            backgroundImage: FileImage(File(_avatarPath!)),
                            backgroundColor: Colors.transparent,
                          )
                        : CircleAvatar(
                            radius: 60,
                            backgroundColor: const Color(
                              0xFF8A5A44,
                            ).withValues(alpha: 0.16),
                            child: const Icon(
                              Icons.person_rounded,
                              color: Color(0xFF8A5A44),
                              size: 60,
                            ),
                          ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8A5A44),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Ketuk untuk ubah foto',
                style: textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF6E6258),
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 32),

              // Form nama dan bio
              _EditCard(
                children: [
                  _SectionLabel('Nama'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameCtrl,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2F241D),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Masukkan nama kamu',
                      hintStyle: const TextStyle(
                        color: Color(0xFF9E8E7E),
                        fontWeight: FontWeight.w400,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFFCF8F1),
                      prefixIcon: const Icon(
                        Icons.person_outline_rounded,
                        color: Color(0xFF8A5A44),
                        size: 20,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFD8CDBE)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Color(0xFFD8CDBE),
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Color(0xFF8A5A44),
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _SectionLabel('Bio'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _bioCtrl,
                    maxLines: 4,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2F241D),
                      height: 1.6,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Ceritakan sedikit tentang diri kamu...',
                      hintStyle: const TextStyle(
                        color: Color(0xFF9E8E7E),
                        fontSize: 13,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFFCF8F1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFD8CDBE)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Color(0xFFD8CDBE),
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Color(0xFF8A5A44),
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.all(14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Tombol simpan
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save_rounded, size: 20),
                  label: const Text('SIMPAN PROFIL'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFF8A5A44),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Helper widgets ────────────────────────────────────────────────────────────

/// Kartu form dengan rounded corner dan shadow untuk mengelompokkan field input.
class _EditCard extends StatelessWidget {
  const _EditCard({required this.children});

  /// Daftar widget field yang ditampilkan di dalam kartu.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF8),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

/// Label section kecil dalam form edit profil.
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  /// Teks label yang ditampilkan.
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w700,
        fontSize: 12,
        color: const Color(0xFF6E6258),
        letterSpacing: 0.4,
      ),
    );
  }
}

/// Tombol untuk memilih sumber foto (kamera atau galeri).
///
/// Menampilkan ikon besar dan label teks dalam kotak krem yang bisa diketuk.
class _ImageSourceButton extends StatelessWidget {
  const _ImageSourceButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  /// Ikon yang ditampilkan di dalam tombol.
  final IconData icon;

  /// Teks label di bawah ikon.
  final String label;

  /// Callback ketika tombol diketuk.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 140,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFF7E9CF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFD8CDBE), width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, size: 36, color: const Color(0xFF8A5A44)),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2F241D),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
