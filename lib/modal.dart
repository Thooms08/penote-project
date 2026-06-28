import 'package:flutter/material.dart';
import 'list.dart';
import 'notes_helper.dart';

// ── Entry point: buka modal buat / edit aktifitas ───────────────────────────

/// Menampilkan bottom sheet modal untuk membuat atau mengedit aktifitas.
///
/// Jika [task] diberikan, sheet akan terbuka dalam mode edit dengan data
/// aktifitas yang sudah ada. Mengembalikan [PenoteTask] yang baru/diperbarui,
/// atau null jika user menutup modal tanpa menyimpan.
Future<PenoteTask?> showTaskCreationSheet(
  BuildContext context, {
  PenoteTask? task,
}) async {
  return showModalBottomSheet<PenoteTask>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.80,
        minChildSize: 0.55,
        maxChildSize: 0.92,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Color(0xFFFFFDF8),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: TaskCreationSheet(
              task: task,
              scrollController: scrollController,
            ),
          );
        },
      );
    },
  );
}

// ── Sheet form Aktifitas ─────────────────────────────────────────────────────

/// Widget form di dalam bottom sheet untuk membuat atau mengedit aktifitas.
///
/// Menampilkan field judul, lokasi, waktu, dan catatan. Mendukung
/// pemformatan markdown sederhana pada field catatan.
class TaskCreationSheet extends StatefulWidget {
  const TaskCreationSheet({
    super.key,
    this.task,
    required this.scrollController,
  });

  /// Aktifitas yang diedit. Null jika mode tambah baru.
  final PenoteTask? task;

  /// Controller untuk scroll yang diteruskan dari [DraggableScrollableSheet].
  final ScrollController scrollController;

  @override
  State<TaskCreationSheet> createState() => _TaskCreationSheetState();
}

/// State internal dari [TaskCreationSheet].
///
/// Mengelola semua input form, logika pemformatan catatan,
/// serta interaksi dengan date/time picker dan Canvas editor.
class _TaskCreationSheetState extends State<TaskCreationSheet> {
  /// Tanggal yang dipilih user untuk aktifitas.
  late DateTime _selectedDate;

  /// Jam yang dipilih user untuk aktifitas.
  late TimeOfDay _selectedTime;

  /// Controller untuk field input judul aktifitas.
  late final TextEditingController _titleController;

  /// Controller untuk field input lokasi aktifitas.
  late final TextEditingController _locationController;

  /// Controller untuk field input catatan aktifitas.
  late final TextEditingController _notesController;

  /// FocusNode untuk field catatan, digunakan saat menerapkan format teks.
  late final FocusNode _notesFocus;

  /// Nilai catatan saat ini. Null jika kosong.
  String? _currentNotes;

  /// Mengembalikan `true` jika sheet ini dibuka dalam mode edit.
  bool get _isEdit => widget.task != null;

  /// Inisialisasi semua controller dan listener dari data aktifitas yang ada.
  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate =
        widget.task?.scheduledAt ?? DateTime(now.year, now.month, now.day);
    _selectedTime = TimeOfDay.fromDateTime(widget.task?.scheduledAt ?? now);
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _locationController = TextEditingController(
      text: widget.task?.location ?? '',
    );
    _currentNotes = widget.task?.notes;
    _notesController = TextEditingController(text: _currentNotes ?? '');
    _notesFocus = FocusNode();
    // Sync _currentNotes setiap teks berubah
    _notesController.addListener(() {
      _currentNotes = _notesController.text.isEmpty
          ? null
          : _notesController.text;
      // Rebuild agar preview ikut update
      if (mounted) setState(() {});
    });
  }

  /// Membebaskan semua controller dan focus node dari memori.
  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    _notesFocus.dispose();
    super.dispose();
  }

  // ── Format helpers ────────────────────────────────────────────────────────

  /// Membungkus teks yang dipilih dengan [prefix] dan [suffix].
  ///
  /// Jika tidak ada teks yang dipilih, menambahkan wrapper di posisi kursor.
  /// Digunakan untuk menerapkan format **bold** dan _italic_ pada catatan.
  void _wrapSelection(String prefix, String suffix) {
    final ctrl = _notesController;
    final sel = ctrl.selection;
    if (!sel.isValid) return;
    final text = ctrl.text;
    final before = text.substring(0, sel.start);
    final selected = text.substring(sel.start, sel.end);
    final after = text.substring(sel.end);
    final newText = '$before$prefix$selected$suffix$after';
    final newStart = sel.start + prefix.length;
    ctrl.value = ctrl.value.copyWith(
      text: newText,
      selection: TextSelection(
        baseOffset: newStart,
        extentOffset: newStart + selected.length,
      ),
    );
    _notesFocus.requestFocus();
  }

  /// Menambahkan atau menghapus bullet point (• ) di awal baris pada catatan.
  ///
  /// Jika ada teks yang dipilih, bullet ditambahkan di setiap baris seleksi.
  /// Jika kursor berada di baris yang sudah ada bullet, bullet akan dihapus.
  void _insertBullet() {
    final ctrl = _notesController;
    final sel = ctrl.selection;
    final text = ctrl.text;
    if (!sel.isValid) {
      // Tidak ada kursor — sisipkan bullet di akhir teks
      final newText = '${text.isEmpty ? '' : '$text\n'}• ';
      ctrl.value = ctrl.value.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
      _notesFocus.requestFocus();
      return;
    }
    final before = text.substring(0, sel.start);
    final selected = text.substring(sel.start, sel.end);
    final after = text.substring(sel.end);
    if (selected.isEmpty) {
      // Operasi pada baris saat ini (toggle bullet)
      final lineStart = before.lastIndexOf('\n') + 1;
      final linePrefix = before.substring(lineStart);
      if (linePrefix.startsWith('• ')) {
        // Sudah ada bullet — hapus bullet dari awal baris
        final newBefore =
            before.substring(0, lineStart) + linePrefix.substring(2);
        ctrl.value = ctrl.value.copyWith(
          text: '$newBefore$after',
          selection: TextSelection.collapsed(offset: newBefore.length),
        );
      } else {
        // Tambah bullet di awal baris
        final newBefore = '${before.substring(0, lineStart)}• $linePrefix';
        ctrl.value = ctrl.value.copyWith(
          text: '$newBefore$after',
          selection: TextSelection.collapsed(offset: newBefore.length),
        );
      }
    } else {
      // Tambah bullet di setiap baris yang dipilih
      final bulleted = selected
          .split('\n')
          .map((l) => l.startsWith('• ') ? l : '• $l')
          .join('\n');
      ctrl.value = ctrl.value.copyWith(
        text: '$before$bulleted$after',
        selection: TextSelection(
          baseOffset: sel.start,
          extentOffset: sel.start + bulleted.length,
        ),
      );
    }
    _notesFocus.requestFocus();
  }

  /// Membuka date picker dan memperbarui [_selectedDate] dengan pilihan user.
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF8A5A44)),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  /// Membuka time picker dan memperbarui [_selectedTime] dengan pilihan user.
  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF8A5A44)),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  /// Membangun objek [PenoteTask] dari input form saat ini.
  ///
  /// Menampilkan snackbar error jika judul atau lokasi masih kosong.
  /// Mengembalikan null jika validasi gagal.
  PenoteTask? _buildTask() {
    final title = _titleController.text.trim();
    final location = _locationController.text.trim();

    if (title.isEmpty || location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Judul dan tempat aktifitas wajib diisi.'),
          backgroundColor: const Color(0xFFC94F4F),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return null;
    }

    final scheduledAt = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    return PenoteTask(
      id: widget.task?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      location: location,
      scheduledAt: scheduledAt,
      createdAt: widget.task?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      isCompleted: widget.task?.isCompleted ?? false,
      completedAt: widget.task?.completedAt,
      notes: _currentNotes,
    );
  }

  /// Memvalidasi form, lalu menutup modal dan mengembalikan [PenoteTask].
  void _submit() {
    final task = _buildTask();
    if (task == null) return;
    Navigator.of(context).pop(task);
  }

  /// Memvalidasi form, lalu membuka halaman [CanvasScreen] untuk edit detail lebih lanjut.
  ///
  /// Menyimpan dulu data form ke objek task sementara sebelum diteruskan ke Canvas.
  Future<void> _openEditDetail() async {
    final task = _buildTask();
    if (task == null) return;
    final result = await Navigator.of(context).push<PenoteTask>(
      MaterialPageRoute(builder: (_) => CanvasScreen(task: task)),
    );
    if (!mounted || result == null) return;
    // Sync kembali hasil edit dari Canvas ke form
    setState(() {
      _titleController.text = result.title;
      _locationController.text = result.location;
      _notesController.text = result.notes ?? '';
      _currentNotes = result.notes;
      _selectedDate = result.scheduledAt;
      _selectedTime = TimeOfDay.fromDateTime(result.scheduledAt);
    });
  }

  // ── UI ────────────────────────────────────────────────────────────────────

  /// Membangun tampilan form lengkap di dalam bottom sheet.
  ///
  /// Terdiri dari handle bar, header, field waktu, judul, lokasi,
  /// catatan, dan tombol aksi (Simpan / Tambah / Edit Detail).
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      controller: widget.scrollController,
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      children: [
        // Handle bar
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFD8CDBE),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF7E9CF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                _isEdit ? Icons.edit_calendar_rounded : Icons.add_task_rounded,
                color: const Color(0xFF8A5A44),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isEdit ? 'Edit Aktifitas' : 'Tambah Aktifitas',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2F241D),
                    ),
                  ),
                  Text(
                    _isEdit
                        ? 'Ubah judul atau lokasi aktifitas'
                        : 'Isi detail aktifitas baru kamu',
                    style: textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF6E6258),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close_rounded),
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFFF5EFE6),
                foregroundColor: const Color(0xFF6E6258),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // ── Pilih Tanggal & Jam ──
        _SectionLabel(label: 'Waktu Aktifitas'),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _DateTimePickerTile(
                icon: Icons.calendar_today_rounded,
                label: 'Tanggal',
                value:
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                onTap: _pickDate,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _DateTimePickerTile(
                icon: Icons.access_time_rounded,
                label: 'Jam',
                value: _selectedTime.format(context),
                onTap: _pickTime,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // ── Judul Aktifitas ──
        _SectionLabel(label: 'Judul Aktifitas'),
        const SizedBox(height: 10),
        _PenoteTextField(
          controller: _titleController,
          hint: 'Contoh: Rapat Tim Produk',
          icon: Icons.title_rounded,
        ),
        const SizedBox(height: 16),

        // ── Tempat Aktifitas ──
        _SectionLabel(label: 'Tempat Aktifitas'),
        const SizedBox(height: 10),
        _PenoteTextField(
          controller: _locationController,
          hint: 'Contoh: Ruangan 3B, Lantai 2',
          icon: Icons.location_on_outlined,
        ),
        const SizedBox(height: 20),

        // ── Catatan ──
        _SectionLabel(label: 'Catatan'),
        const SizedBox(height: 10),
        // Toolbar formatting dari notes_helper.dart
        NotesFormattingToolbar(
          onBold: () => _wrapSelection('**', '**'),
          onItalic: () => _wrapSelection('_', '_'),
          onBullet: _insertBullet,
        ),
        const SizedBox(height: 8),
        // Editor catatan dari notes_helper.dart
        RichNotesEditor(controller: _notesController, focusNode: _notesFocus),
        const SizedBox(height: 28),

        // ── Preview catatan (hanya saat ada notes) ──
        if (_notesController.text.trim().isNotEmpty) ...[
          _SectionLabel(label: 'Pratinjau Catatan'),
          const SizedBox(height: 10),
          NotesPreviewCard(notes: _notesController.text),
          const SizedBox(height: 20),
        ],

        // ── Tombol aksi ──
        if (_isEdit) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.save_rounded, size: 18),
              label: const Text('SIMPAN'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                backgroundColor: const Color(0xFF8A5A44),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Tombol EDIT DETAIL — membuka CanvasScreen
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _openEditDetail,
              icon: const Icon(Icons.open_in_full_rounded, size: 18),
              label: const Text('EDIT DETAIL'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                foregroundColor: const Color(0xFF8A5A44),
                side: const BorderSide(color: Color(0xFF8A5A44), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ] else ...[
          // Tombol TAMBAH (baru)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
              label: const Text('TAMBAH AKTIFITAS'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                backgroundColor: const Color(0xFFA96A46),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

/// Label bagian (section) dalam form dengan gaya teks tebal.
class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  /// Teks label yang ditampilkan.
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: const Color(0xFF2F241D),
        fontSize: 13,
      ),
    );
  }
}

/// Tile yang bisa diketuk untuk membuka date atau time picker.
///
/// Menampilkan ikon, label, dan nilai yang dipilih dalam kotak
/// berwarna krem dengan border halus.
class _DateTimePickerTile extends StatelessWidget {
  const _DateTimePickerTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  /// Ikon yang ditampilkan di sebelah kiri tile.
  final IconData icon;

  /// Label kecil di atas nilai (misalnya "Tanggal" atau "Jam").
  final String label;

  /// Nilai yang saat ini dipilih untuk ditampilkan.
  final String value;

  /// Callback ketika tile diketuk.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF7E9CF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFD8CDBE), width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: const Color(0xFF8A5A44)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF6E6258),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2F241D),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 16,
              color: Color(0xFF8A5A44),
            ),
          ],
        ),
      ),
    );
  }
}

/// TextField bergaya khusus Penote untuk input satu baris (judul, lokasi, dll).
///
/// Memiliki tampilan yang konsisten dengan desain aplikasi: rounded corner,
/// warna krem, dan prefixIcon berwarna coklat.
class _PenoteTextField extends StatelessWidget {
  const _PenoteTextField({
    required this.controller,
    required this.hint,
    required this.icon,
  });

  /// Controller teks yang terhubung dengan field ini.
  final TextEditingController controller;

  /// Teks placeholder yang ditampilkan saat field kosong.
  final String hint;

  /// Ikon yang ditampilkan di sebelah kiri field.
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Color(0xFF2F241D),
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF6E6258), fontSize: 13),
        filled: true,
        fillColor: const Color(0xFFFCF8F1),
        prefixIcon: Icon(icon, color: const Color(0xFF8A5A44), size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFD8CDBE)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFD8CDBE), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF8A5A44), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// CanvasScreen — Halaman edit detail lengkap sebuah Aktifitas.
//
// Dipindahkan dari canvas_screen.dart ke sini agar semua kode yang
// berhubungan dengan aktifitas berada dalam satu file.
// ══════════════════════════════════════════════════════════════════════════════

/// Halaman Canvas — tampilan edit detail lengkap sebuah Aktifitas.
///
/// Memungkinkan user mengubah judul, lokasi, waktu, dan catatan
/// aktifitas dalam tampilan full-screen yang lebih luas dari modal.
class CanvasScreen extends StatefulWidget {
  const CanvasScreen({super.key, required this.task});

  /// Aktifitas yang akan diedit di halaman ini.
  final PenoteTask task;

  @override
  State<CanvasScreen> createState() => _CanvasScreenState();
}

/// State dari [CanvasScreen] yang mengelola semua controller dan logika edit.
class _CanvasScreenState extends State<CanvasScreen> {
  /// Controller untuk field input judul aktifitas.
  late final TextEditingController _titleCtrl;

  /// Controller untuk field input lokasi aktifitas.
  late final TextEditingController _locationCtrl;

  /// Controller untuk field input catatan aktifitas.
  late final TextEditingController _notesCtrl;

  /// FocusNode untuk field catatan, digunakan saat menerapkan format teks.
  late final FocusNode _notesFocus;

  /// Waktu aktifitas yang sedang dipilih (gabungan tanggal + jam).
  late DateTime _scheduledAt;

  /// Menginisialisasi semua controller dengan data dari aktifitas yang diteruskan.
  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.task.title);
    _locationCtrl = TextEditingController(text: widget.task.location);
    _notesCtrl = TextEditingController(text: widget.task.notes ?? '');
    _notesFocus = FocusNode();
    _scheduledAt = widget.task.scheduledAt;
  }

  /// Membebaskan semua controller dan focus node dari memori.
  @override
  void dispose() {
    _titleCtrl.dispose();
    _locationCtrl.dispose();
    _notesCtrl.dispose();
    _notesFocus.dispose();
    super.dispose();
  }

  /// Membuka date picker dan memperbarui bagian tanggal dari [_scheduledAt].
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _scheduledAt,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF8A5A44)),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(
        () => _scheduledAt = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _scheduledAt.hour,
          _scheduledAt.minute,
        ),
      );
    }
  }

  /// Membuka time picker dan memperbarui bagian jam dari [_scheduledAt].
  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_scheduledAt),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF8A5A44)),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(
        () => _scheduledAt = DateTime(
          _scheduledAt.year,
          _scheduledAt.month,
          _scheduledAt.day,
          picked.hour,
          picked.minute,
        ),
      );
    }
  }

  /// Membungkus teks yang dipilih dengan [prefix] dan [suffix].
  /// Digunakan untuk format **bold** dan _italic_.
  void _wrapSelection(String prefix, String suffix) {
    final ctrl = _notesCtrl;
    final sel = ctrl.selection;
    final text = ctrl.text;
    if (!sel.isValid) return;
    final before = text.substring(0, sel.start);
    final selected = text.substring(sel.start, sel.end);
    final after = text.substring(sel.end);
    final newText = '$before$prefix$selected$suffix$after';
    final newStart = sel.start + prefix.length;
    ctrl.value = ctrl.value.copyWith(
      text: newText,
      selection: TextSelection(
        baseOffset: newStart,
        extentOffset: newStart + selected.length,
      ),
    );
    _notesFocus.requestFocus();
  }

  /// Menambahkan bullet point (• ) di awal baris. Toggle jika sudah ada.
  void _insertBullet() {
    final ctrl = _notesCtrl;
    final sel = ctrl.selection;
    final text = ctrl.text;
    if (!sel.isValid) {
      final newText = '${text.isEmpty ? '' : '$text\n'}• ';
      ctrl.value = ctrl.value.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
      _notesFocus.requestFocus();
      return;
    }
    final before = text.substring(0, sel.start);
    final selected = text.substring(sel.start, sel.end);
    final after = text.substring(sel.end);
    if (selected.isEmpty) {
      final lineStart = before.lastIndexOf('\n') + 1;
      final linePrefix = before.substring(lineStart);
      if (linePrefix.startsWith('• ')) {
        final newBefore =
            before.substring(0, lineStart) + linePrefix.substring(2);
        ctrl.value = ctrl.value.copyWith(
          text: '$newBefore$after',
          selection: TextSelection.collapsed(offset: newBefore.length),
        );
      } else {
        final newBefore = '${before.substring(0, lineStart)}• $linePrefix';
        ctrl.value = ctrl.value.copyWith(
          text: '$newBefore$after',
          selection: TextSelection.collapsed(offset: newBefore.length),
        );
      }
    } else {
      final bulleted = selected
          .split('\n')
          .map((l) => l.startsWith('• ') ? l : '• $l')
          .join('\n');
      ctrl.value = ctrl.value.copyWith(
        text: '$before$bulleted$after',
        selection: TextSelection(
          baseOffset: sel.start,
          extentOffset: sel.start + bulleted.length,
        ),
      );
    }
    _notesFocus.requestFocus();
  }

  /// Memvalidasi input, menyimpan perubahan ke task, dan menutup halaman.
  void _save() {
    final title = _titleCtrl.text.trim();
    final location = _locationCtrl.text.trim();
    if (title.isEmpty || location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Judul dan tempat aktifitas wajib diisi.'),
          backgroundColor: const Color(0xFFC94F4F),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }
    widget.task.title = title;
    widget.task.location = location;
    widget.task.notes = _notesCtrl.text;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Detail aktifitas berhasil disimpan.'),
        backgroundColor: const Color(0xFF4F9D69),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    Navigator.of(context).pop(widget.task);
  }

  /// Membangun tampilan Canvas dengan AppBar, form detail, dan tombol simpan.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StatusBanner(task: widget.task),
              const SizedBox(height: 20),
              _DetailCard(
                children: [
                  _CanvasSectionLabel('Judul Aktifitas'),
                  const SizedBox(height: 8),
                  _CanvasTextField(
                    controller: _titleCtrl,
                    hint: 'Nama aktifitas',
                    icon: Icons.title_rounded,
                  ),
                  const SizedBox(height: 16),
                  _CanvasSectionLabel('Tempat Aktifitas'),
                  const SizedBox(height: 8),
                  _CanvasTextField(
                    controller: _locationCtrl,
                    hint: 'Lokasi aktifitas',
                    icon: Icons.location_on_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _DetailCard(
                children: [
                  _CanvasSectionLabel('Waktu Aktifitas'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _PickerTile(
                          icon: Icons.calendar_today_rounded,
                          label: 'Tanggal',
                          value:
                              '${_scheduledAt.day}/${_scheduledAt.month}/${_scheduledAt.year}',
                          onTap: _pickDate,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _PickerTile(
                          icon: Icons.access_time_rounded,
                          label: 'Jam',
                          value:
                              '${_scheduledAt.hour.toString().padLeft(2, '0')}:${_scheduledAt.minute.toString().padLeft(2, '0')}',
                          onTap: _pickTime,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _DetailCard(
                children: [
                  _CanvasSectionLabel('Catatan Tambahan'),
                  const SizedBox(height: 10),
                  // Toolbar dari notes_helper.dart
                  NotesFormattingToolbar(
                    onBold: () => _wrapSelection('**', '**'),
                    onItalic: () => _wrapSelection('_', '_'),
                    onBullet: _insertBullet,
                  ),
                  const SizedBox(height: 8),
                  // Editor dari notes_helper.dart
                  RichNotesEditor(
                    controller: _notesCtrl,
                    focusNode: _notesFocus,
                  ),
                ],
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save_rounded, size: 20),
                  label: const Text('SIMPAN DETAIL'),
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

  /// Membangun AppBar Canvas dengan tombol Simpan di kanan.
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFFFF6E5),
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Color(0xFF2F241D),
          size: 20,
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detail Aktifitas',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2F241D),
            ),
          ),
          Text(
            'Canvas Editor',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: const Color(0xFF6E6258)),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF8A5A44),
            borderRadius: BorderRadius.circular(12),
          ),
          child: GestureDetector(
            onTap: _save,
            child: const Text(
              'Simpan',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Widget pendukung Canvas ───────────────────────────────────────────────────

/// Banner status aktifitas: selesai (hijau), terlambat (merah), atau rencana (coklat).
class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.task});
  final PenoteTask task;

  @override
  Widget build(BuildContext context) {
    final isCompleted = task.isCompleted;
    final isLate = task.scheduledAt.isBefore(DateTime.now()) && !isCompleted;
    Color bgColor;
    Color textColor;
    IconData iconData;
    String label;
    if (isCompleted) {
      bgColor = const Color(0xFFDEF5E9);
      textColor = const Color(0xFF2E7D50);
      iconData = Icons.check_circle_rounded;
      label = 'Aktifitas telah selesai';
    } else if (isLate) {
      bgColor = const Color(0xFFFFE4D3);
      textColor = const Color(0xFFC94F4F);
      iconData = Icons.warning_amber_rounded;
      label = 'Aktifitas sudah melewati waktu';
    } else {
      bgColor = const Color(0xFFF7E9CF);
      textColor = const Color(0xFF8A5A44);
      iconData = Icons.pending_actions_rounded;
      label = 'Aktifitas dalam rencana';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(iconData, color: textColor, size: 18),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

/// Kartu kontainer dengan rounded corner dan shadow untuk mengelompokkan konten.
class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
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

/// Label section kecil dalam Canvas dengan gaya teks abu-abu berukuran kecil.
class _CanvasSectionLabel extends StatelessWidget {
  const _CanvasSectionLabel(this.label);
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

/// TextField bergaya Canvas untuk input satu atau multi baris.
class _CanvasTextField extends StatelessWidget {
  const _CanvasTextField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.maxLines = 1,
  });
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Color(0xFF2F241D),
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF6E6258), fontSize: 13),
        filled: true,
        fillColor: const Color(0xFFFCF8F1),
        prefixIcon: maxLines == 1
            ? Icon(icon, color: const Color(0xFF8A5A44), size: 20)
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFD8CDBE)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFD8CDBE), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF8A5A44), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}

/// Tile yang bisa diketuk untuk memilih tanggal atau jam di halaman Canvas.
class _PickerTile extends StatelessWidget {
  const _PickerTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  /// Ikon yang ditampilkan di sebelah kiri tile.
  final IconData icon;

  /// Label kecil di atas nilai (misalnya "Tanggal" atau "Jam").
  final String label;

  /// Nilai yang saat ini dipilih untuk ditampilkan.
  final String value;

  /// Callback ketika tile diketuk.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF7E9CF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFD8CDBE), width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: const Color(0xFF8A5A44)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF6E6258),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2F241D),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 16,
              color: Color(0xFF8A5A44),
            ),
          ],
        ),
      ),
    );
  }
}
