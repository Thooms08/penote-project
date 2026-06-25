import 'package:flutter/material.dart';

/// Widget bottom navigation bar yang digunakan di seluruh aplikasi Penote.
///
/// Menampilkan dua tab utama: Home dan Profile. Menggunakan desain
/// minimalis dengan warna coklat hangat sesuai tema aplikasi.
class PinoteBottomNavBar extends StatelessWidget {
  /// Indeks tab yang sedang aktif (0 = Home, 1 = Profile).
  final int currentIndex;

  /// Callback yang dipanggil ketika user mengetuk salah satu tab.
  final Function(int) onTap;

  const PinoteBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  /// Membangun bottom navigation bar dengan dua item: Home dan Profile.
  ///
  /// Menggunakan [Container] sebagai pembungkus untuk menambahkan
  /// border atas yang halus sebagai pemisah konten.
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // Border tipis di bagian atas navbar sebagai pemisah halaman
        border: Border(
          top: BorderSide(
            color: const Color(0xFFD8CDBE).withOpacity(0.5),
            width: 1.0,
          ),
        ),
      ),
      child: BottomNavigationBar(
        backgroundColor: const Color(0xFFFFFDF8), // Surface color
        elevation: 0, // Dibuat 0 karena sudah ada border di Container
        selectedItemColor: const Color(0xFF8A5A44), // Primary Action
        unselectedItemColor: const Color(
          0xFF6F4E37,
        ).withOpacity(0.6), // Icon unselected
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
        currentIndex: currentIndex,
        onTap: onTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
