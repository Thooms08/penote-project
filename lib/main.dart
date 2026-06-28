import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'opening.dart';
import 'btmnavbar.dart';
import 'list.dart';
import 'modal.dart';
import 'notes_helper.dart' show NotesPreviewCard;
import 'profile/main.dart' show ProfileView;

/// Titik masuk (entry point) aplikasi Penote.
///
/// Menjalankan [PenoteApp] sebagai root widget.
void main() {
  runApp(const PenoteApp());
}

/// Widget root aplikasi Penote yang mengatur tema dan rute awal.
///
/// Mendukung tema terang dan gelap yang otomatis mengikuti
/// pengaturan sistem perangkat.
class PenoteApp extends StatelessWidget {
  const PenoteApp({super.key});

  /// Membangun [MaterialApp] dengan tema Penote (Poppins, warna coklat hangat)
  /// dan mengatur halaman awal ke [OpeningScreen].
  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData(
      useMaterial3: true,
      fontFamily: GoogleFonts.poppins().fontFamily,
    );

    return MaterialApp(
      title: 'Penote',
      debugShowCheckedModeBanner: false,
      theme: baseTheme.copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF7E9CF),
          primary: const Color(0xFF8A5A44),
          secondary: const Color(0xFFA96A46),
          surface: const Color(0xFFFFFDF8),
        ),
        textTheme: GoogleFonts.poppinsTextTheme(baseTheme.textTheme),
        scaffoldBackgroundColor: const Color(0xFFF5EFE6),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
        ),
      ),
      darkTheme: baseTheme.copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF7E9CF),
          brightness: Brightness.dark,
          primary: const Color(0xFFE8CFAF),
          secondary: const Color(0xFFA96A46),
          surface: const Color(0xFF1F1A17),
        ),
        scaffoldBackgroundColor: const Color(0xFF171311),
        textTheme: GoogleFonts.poppinsTextTheme(baseTheme.textTheme),
      ),
      themeMode: ThemeMode.system,
      home: const OpeningScreen(),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// MainScreen — shell dengan bottom nav
// ══════════════════════════════════════════════════════════════════════════════

/// Shell utama aplikasi yang mengandung bottom navigation bar
/// dan mengelola perpindahan antara tab Home dan Profile.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

/// State dari [MainScreen] yang melacak tab aktif dan referensi ke HomeView.
class _MainScreenState extends State<MainScreen> {
  /// Indeks tab yang sedang aktif (0 = Home, 1 = Profile).
  int _currentIndex = 0;

  /// GlobalKey untuk mengakses state [HomeView] dari luar,
  /// khususnya untuk membuka modal tambah aktifitas via FAB.
  // HomeView adalah StatefulWidget — tidak bisa const di sini
  // karena pakai DateTime.now() di initState
  final _homeKey = GlobalKey<_HomeViewState>();

  /// Membangun layout utama dengan [IndexedStack], FAB, dan [PinoteBottomNavBar].
  ///
  /// FAB hanya ditampilkan di tab Home (index 0).
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeView(key: _homeKey),
          const ProfileView(),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () => _homeKey.currentState?._openTaskCreator(),
              icon: const Icon(Icons.add_rounded),
              label: const Text(
                'Aktifitas',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              backgroundColor: const Color(0xFFA96A46),
              foregroundColor: Colors.white,
              elevation: 4,
            )
          : null,
      bottomNavigationBar: PinoteBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// HomeView — tampilan utama
// ══════════════════════════════════════════════════════════════════════════════

/// Tampilan halaman utama yang menampilkan daftar aktifitas,
/// progress card, dan grafik bar.
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

/// State dari [HomeView] yang mengelola daftar aktifitas dan semua aksi user.
class _HomeViewState extends State<HomeView> {
  /// Daftar aktifitas user. Diinisialisasi dengan dua data sample.
  late final List<PenoteTask> _tasks = [
    PenoteTask(
      id: 'sample-1',
      title: 'Rapat Tim Desain',
      location: 'Ruangan 4B',
      scheduledAt: DateTime.now().add(const Duration(hours: 2)),
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    PenoteTask(
      id: 'sample-2',
      title: 'Review Produk Mingguan',
      location: 'Zoom Meeting',
      scheduledAt: DateTime.now().subtract(const Duration(hours: 1)),
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
  ];

  /// Membuka modal sheet untuk menambah aktifitas baru atau mengedit yang ada.
  ///
  /// Jika [task] diberikan, modal terbuka dalam mode edit.
  /// Hasilnya ditambahkan ke atau diperbarui dalam [_tasks].
  Future<void> _openTaskCreator({PenoteTask? task}) async {
    final result = await showTaskCreationSheet(context, task: task);
    if (!mounted || result == null) return;

    setState(() {
      if (task != null) {
        // Perbarui aktifitas yang sudah ada berdasarkan id
        final idx = _tasks.indexWhere((t) => t.id == task.id);
        if (idx >= 0) _tasks[idx] = result;
      } else {
        // Tambah aktifitas baru di paling atas daftar
        _tasks.insert(0, result);
      }
    });
  }

  /// Mengubah status selesai aktifitas dan mencatat waktu penyelesaian.
  ///
  /// Menampilkan snackbar konfirmasi dengan waktu selesai atau pesan pembatalan.
  void _toggleTask(PenoteTask task) {
    setState(() {
      task.isCompleted = !task.isCompleted;
      task.completedAt = task.isCompleted ? DateTime.now() : null;
      task.updatedAt = DateTime.now();
    });

    final msg = task.isCompleted
        ? 'Aktifitas selesai ✓  ${task.formatDateTime(task.completedAt!)}'
        : 'Status aktifitas dibuka kembali';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: task.isCompleted
            ? const Color(0xFF4F9D69)
            : const Color(0xFF8A5A44),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// Menghapus aktifitas dari daftar dan menampilkan snackbar konfirmasi.
  void _deleteTask(PenoteTask task) {
    setState(() => _tasks.removeWhere((t) => t.id == task.id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Aktifitas dihapus'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// Persentase aktifitas yang sudah selesai (0.0 – 1.0).
  /// Mengembalikan 0 jika tidak ada aktifitas.
  double get _completionRate => _tasks.isEmpty
      ? 0
      : _tasks.where((t) => t.isCompleted).length / _tasks.length;

  /// Jumlah aktifitas yang sudah diselesaikan.
  int get _completedCount => _tasks.where((t) => t.isCompleted).length;

  /// Jumlah aktifitas yang belum selesai dan belum melewati jadwal.
  int get _pendingCount => _tasks
      .where((t) => !t.isCompleted && !t.scheduledAt.isBefore(DateTime.now()))
      .length;

  /// Jumlah aktifitas yang belum selesai namun sudah melewati jadwal.
  int get _lateCount => _tasks
      .where((t) => !t.isCompleted && t.scheduledAt.isBefore(DateTime.now()))
      .length;

  /// Membangun tampilan utama yang berisi header, progress card,
  /// grafik bar, dan daftar aktifitas.
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Scrollable header + list ──
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              children: [
                // Header dengan logo
                _HomeHeader(),
                const SizedBox(height: 20),

                // Progress Card
                _ProgressCard(
                  completionRate: _completionRate,
                  completedCount: _completedCount,
                  pendingCount: _pendingCount,
                  lateCount: _lateCount,
                  total: _tasks.length,
                ),
                const SizedBox(height: 16),

                // Grafik bar
                _ActivityBarChart(
                  completedCount: _completedCount,
                  pendingCount: _pendingCount,
                  lateCount: _lateCount,
                ),
                const SizedBox(height: 20),

                // Label daftar + badge total
                Row(
                  children: [
                    Text(
                      'Aktifitas Kamu',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7E9CF),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${_tasks.length} total',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF8A5A44),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // ── Daftar aktifitas atau empty state ──
                if (_tasks.isEmpty)
                  _EmptyAktifitas()
                else
                  ...List.generate(_tasks.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _TaskCardItem(
                        task: _tasks[index],
                        onToggle: () => _toggleTask(_tasks[index]),
                        onEdit: () => _openTaskCreator(task: _tasks[index]),
                        onDelete: () => _deleteTask(_tasks[index]),
                      ),
                    );
                  }),
              ],
            ),
          ),
        ],
      ),
    );
  }
} // end _HomeViewState

// ══════════════════════════════════════════════════════════════════════════════
// _TaskCardItem — card aktifitas inline (tanpa nested ListView)
// ══════════════════════════════════════════════════════════════════════════════

/// Kartu aktifitas yang digunakan langsung dalam [ListView] di HomeView.
///
/// Menampilkan informasi lengkap aktifitas termasuk judul, lokasi, waktu,
/// status, dan pratinjau catatan jika ada.
class _TaskCardItem extends StatelessWidget {
  const _TaskCardItem({
    required this.task,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  /// Data aktifitas yang akan ditampilkan pada kartu ini.
  final PenoteTask task;

  /// Callback ketika tombol centang ditekan.
  final VoidCallback onToggle;

  /// Callback ketika menu "Edit Aktifitas" dipilih.
  final VoidCallback onEdit;

  /// Callback ketika menu "Hapus" dipilih.
  final VoidCallback onDelete;

  /// Mengembalikan `true` jika waktu aktifitas sudah lewat dan belum selesai.
  bool get _isLate =>
      task.scheduledAt.isBefore(DateTime.now()) && !task.isCompleted;

  /// Membangun kartu aktifitas dengan animasi warna, tombol centang,
  /// konten informasi, dan menu popup aksi.
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.fromLTRB(14, 14, 8, 14),
      decoration: BoxDecoration(
        // Warna kartu berubah ke hijau muda saat aktifitas selesai
        color: task.isCompleted
            ? const Color(0xFFF0FAF4)
            : const Color(0xFFFFFDF8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: task.isCompleted
              ? const Color(0xFF4F9D69).withOpacity(0.35)
              : const Color(0xFFD8CDBE).withOpacity(0.6),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tombol centang
          GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: task.isCompleted
                    ? const Color(0xFF4F9D69)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: task.isCompleted
                      ? const Color(0xFF4F9D69)
                      : const Color(0xFF8A5A44),
                  width: 2,
                ),
                boxShadow: task.isCompleted
                    ? [
                        BoxShadow(
                          color: const Color(0xFF4F9D69).withOpacity(0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: task.isCompleted
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 20,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),

          // Konten
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        task.title,
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          // Strikethrough saat aktifitas selesai
                          color: task.isCompleted
                              ? const Color(0xFF6E6258)
                              : const Color(0xFF2F241D),
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          decorationColor: const Color(0xFF4F9D69),
                        ),
                      ),
                    ),
                    // Badge terlambat jika aktifitas melewati jadwal
                    if (_isLate)
                      Container(
                        margin: const EdgeInsets.only(left: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE4D3),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'Terlambat',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFC94F4F),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      size: 13,
                      color: Color(0xFFA96A46),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        task.location,
                        style: textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF6E6258),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.event_rounded,
                      size: 13,
                      color: Color(0xFF8A5A44),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Aktifitas: ${task.formatDateTime(task.scheduledAt)}',
                        style: textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF8A5A44),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                // Tampilkan waktu penyelesaian jika aktifitas sudah selesai
                if (task.isCompleted && task.completedAt != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 13,
                        color: Color(0xFF4F9D69),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Selesai: ${task.formatDateTime(task.completedAt!)}',
                          style: textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF4F9D69),
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                // Preview catatan jika ada
                if (task.notes != null && task.notes!.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  NotesPreviewCard(notes: task.notes!),
                ],
              ],
            ),
          ),

          // Menu aksi
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') onEdit();
              if (value == 'delete') onDelete();
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 4,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: const [
                    Icon(
                      Icons.edit_rounded,
                      size: 18,
                      color: Color(0xFF8A5A44),
                    ),
                    SizedBox(width: 10),
                    Text('Edit Aktifitas'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: const [
                    Icon(
                      Icons.delete_outline_rounded,
                      size: 18,
                      color: Color(0xFFC94F4F),
                    ),
                    SizedBox(width: 10),
                    Text('Hapus', style: TextStyle(color: Color(0xFFC94F4F))),
                  ],
                ),
              ),
            ],
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFF5EFE6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.more_vert_rounded,
                size: 18,
                color: Color(0xFF8A5A44),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Widget: Header dengan logo Penote
// ══════════════════════════════════════════════════════════════════════════════

/// Header halaman utama yang menampilkan logo, sapaan berdasarkan waktu,
/// dan badge tanggal hari ini.
class _HomeHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final hour = now.hour;
    String greeting;
    IconData greetIcon;
    // Tentukan sapaan berdasarkan jam saat ini
    if (hour < 11) {
      greeting = 'Selamat pagi';
      greetIcon = Icons.wb_sunny_rounded;
    } else if (hour < 15) {
      greeting = 'Selamat siang';
      greetIcon = Icons.light_mode_rounded;
    } else if (hour < 18) {
      greeting = 'Selamat sore';
      greetIcon = Icons.wb_twilight_rounded;
    } else {
      greeting = 'Selamat malam';
      greetIcon = Icons.nightlight_round_rounded;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Logo Penote
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFFFFDF8),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(
              'assets/logo.png',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.check_circle_outline_rounded,
                color: Color(0xFF8A5A44),
                size: 28,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(greetIcon, size: 14, color: const Color(0xFFA96A46)),
                  const SizedBox(width: 4),
                  Text(
                    greeting,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF6E6258),
                    ),
                  ),
                ],
              ),
              Text(
                'Atur aktifitasmu',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2F241D),
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
        // Badge tanggal hari ini
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFDF8),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                _weekdayShort(now.weekday),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6E6258),
                ),
              ),
              Text(
                '${now.day}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2F241D),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Mengubah nomor hari dalam seminggu (1-7) menjadi singkatan bahasa Indonesia.
  ///
  /// Contoh: 1 → "Sen", 7 → "Min"
  String _weekdayShort(int wd) {
    const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    return days[wd - 1];
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Widget: Progress Card dengan circular indicator + persentase
// ══════════════════════════════════════════════════════════════════════════════

/// Kartu ringkasan pencapaian yang menampilkan persentase penyelesaian
/// dalam bentuk circular progress indicator beserta statistik mini.
class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.completionRate,
    required this.completedCount,
    required this.pendingCount,
    required this.lateCount,
    required this.total,
  });

  /// Tingkat penyelesaian dalam rentang 0.0 – 1.0.
  final double completionRate;

  /// Jumlah aktifitas yang sudah diselesaikan.
  final int completedCount;

  /// Jumlah aktifitas yang masih pending (belum selesai, belum terlambat).
  final int pendingCount;

  /// Jumlah aktifitas yang terlambat (belum selesai, sudah lewat jadwal).
  final int lateCount;

  /// Total seluruh aktifitas.
  final int total;

  /// Membangun kartu progress dengan circular indicator di kiri
  /// dan teks motivasi serta statistik mini di kanan.
  @override
  Widget build(BuildContext context) {
    // Konversi ke persentase bulat untuk ditampilkan
    final pct = (completionRate * 100).round();
    final textTheme = Theme.of(context).textTheme;

    // Pilih pesan motivasi berdasarkan persentase penyelesaian
    String motivasi;
    if (pct == 100) {
      motivasi = 'Sempurna! Semua selesai 🎉';
    } else if (pct >= 75) {
      motivasi = 'Hampir selesai, terus semangat!';
    } else if (pct >= 50) {
      motivasi = 'Sudah setengah jalan, lanjutkan!';
    } else if (pct > 0) {
      motivasi = 'Yuk mulai selesaikan aktifitasmu';
    } else {
      motivasi = 'Belum ada yang selesai hari ini';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF6E5), Color(0xFFF7E9CF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── Circular progress ──
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    value: completionRate,
                    strokeWidth: 7,
                    backgroundColor: const Color(0xFFE8D8C2),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF4F9D69),
                    ),
                  ),
                ),
                Text(
                  '$pct%',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF2F241D),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          // ── Info teks ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pencapaian Aktifitas',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2F241D),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  motivasi,
                  style: textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF6E6258),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _MiniStat(
                      label: 'Selesai',
                      count: completedCount,
                      color: const Color(0xFF4F9D69),
                    ),
                    const SizedBox(width: 12),
                    _MiniStat(
                      label: 'Pending',
                      count: pendingCount,
                      color: const Color(0xFF8A5A44),
                    ),
                    const SizedBox(width: 12),
                    _MiniStat(
                      label: 'Terlambat',
                      count: lateCount,
                      color: const Color(0xFFC94F4F),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget statistik mini yang menampilkan angka dan label dalam satu kolom.
///
/// Digunakan di dalam [_ProgressCard] untuk menampilkan ringkasan
/// jumlah selesai, pending, dan terlambat.
class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.count,
    required this.color,
  });

  /// Label teks di bawah angka (misalnya "Selesai", "Pending").
  final String label;

  /// Angka yang ditampilkan secara besar di atas label.
  final int count;

  /// Warna teks angka yang mencerminkan kategori statistik.
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$count',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6E6258),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Widget: Grafik Bar Perbandingan Aktifitas
// ══════════════════════════════════════════════════════════════════════════════

/// Grafik bar horizontal yang memvisualisasikan perbandingan
/// aktifitas selesai, pending, dan terlambat.
///
/// Widget ini tidak ditampilkan jika tidak ada aktifitas sama sekali.
class _ActivityBarChart extends StatelessWidget {
  const _ActivityBarChart({
    required this.completedCount,
    required this.pendingCount,
    required this.lateCount,
  });

  /// Jumlah aktifitas yang sudah diselesaikan.
  final int completedCount;

  /// Jumlah aktifitas yang masih pending.
  final int pendingCount;

  /// Jumlah aktifitas yang terlambat.
  final int lateCount;

  @override
  Widget build(BuildContext context) {
    final total = completedCount + pendingCount + lateCount;
    // Sembunyikan grafik jika tidak ada data
    if (total == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF8),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bar_chart_rounded, color: Color(0xFF8A5A44)),
              const SizedBox(width: 8),
              Text(
                'Grafik Aktifitas',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2F241D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _BarRow(
            label: 'Selesai',
            count: completedCount,
            total: total,
            color: const Color(0xFF4F9D69),
            icon: Icons.check_circle_outline_rounded,
          ),
          const SizedBox(height: 10),
          _BarRow(
            label: 'Pending',
            count: pendingCount,
            total: total,
            color: const Color(0xFF8A5A44),
            icon: Icons.pending_actions_rounded,
          ),
          const SizedBox(height: 10),
          _BarRow(
            label: 'Terlambat',
            count: lateCount,
            total: total,
            color: const Color(0xFFC94F4F),
            icon: Icons.warning_amber_rounded,
          ),
        ],
      ),
    );
  }
}

/// Satu baris dalam grafik bar yang menampilkan ikon, label, bar, dan persentase.
class _BarRow extends StatelessWidget {
  const _BarRow({
    required this.label,
    required this.count,
    required this.total,
    required this.color,
    required this.icon,
  });

  final String label;
  final int count;
  final int total;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 0.0 : count / total;
    final pct = (ratio * 100).round();

    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        SizedBox(
          width: 64,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6E6258),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Stack(
              children: [
                // Track bar (background)
                Container(height: 10, color: const Color(0xFFF5EFE6)),
                // Fill bar dengan animasi
                FractionallySizedBox(
                  widthFactor: ratio,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOut,
                    height: 10,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 36,
          child: Text(
            '$pct%',
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Widget: Empty state aktifitas
// ══════════════════════════════════════════════════════════════════════════════

/// Widget empty state yang ditampilkan saat daftar aktifitas masih kosong.
///
/// Menampilkan ikon, judul, dan teks panduan untuk mendorong user
/// menambahkan aktifitas pertama mereka.
class _EmptyAktifitas extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF7E9CF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.event_note_outlined,
                size: 52,
                color: Color(0xFF8A5A44),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Belum ada aktifitas',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2F241D),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tambahkan aktifitas baru lewat tombol di bawah agar hari-harimu lebih teratur.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: const Color(0xFF6E6258)),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// ProfileView
// ══════════════════════════════════════════════════════════════════════════════

// ProfileView dan _SettingsCard dipindah ke lib/profile/main.dart
