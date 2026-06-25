import 'package:flutter/material.dart';
import 'main.dart';

/// Layar pembuka (splash screen) yang tampil saat aplikasi pertama kali dibuka.
///
/// Menampilkan logo, nama aplikasi, dan indikator loading selama 2 detik,
/// kemudian otomatis berpindah ke [MainScreen].
class OpeningScreen extends StatefulWidget {
  const OpeningScreen({super.key});

  @override
  State<OpeningScreen> createState() => _OpeningScreenState();
}

class _OpeningScreenState extends State<OpeningScreen> {
  /// Dipanggil saat widget pertama kali dimasukkan ke dalam tree.
  ///
  /// Langsung memanggil [_navigateToHome] untuk memulai hitungan mundur
  /// sebelum berpindah ke halaman utama.
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  /// Menunggu 2 detik kemudian mengganti rute ke [MainScreen].
  ///
  /// Menggunakan [Navigator.pushReplacement] agar user tidak bisa kembali
  /// ke splash screen setelah navigasi.
  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    }
  }

  /// Membangun tampilan splash screen dengan logo, nama app, dan loading indicator.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7E9CF),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.png',
              width: 120,
              height: 120,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.image_not_supported,
                size: 80,
                color: Color(0xFF8A5A44),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Penote',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2F241D),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'To-Do List & Task Management',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF6E6258)),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(color: Color(0xFF8A5A44)),
          ],
        ),
      ),
    );
  }
}
