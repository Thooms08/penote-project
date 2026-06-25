import 'package:flutter/material.dart';
import 'list.dart';
import 'canvas/main.dart';

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
        final newBefore = before.substring(0, lineStart) + '• ' + linePrefix;
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

  /// Memvalidasi form, lalu membuka halaman Canvas untuk edit detail lebih lanjut.
  ///
  /// Setelah kembali dari Canvas, field form diperbarui dengan data terbaru
  /// dari [CanvasScreen].
  Future<void> _openEditDetail() async {
    final task = _buildTask();
    if (task == null) return;

    // Sync notes dari controller ke task sebelum ke canvas
    task.notes = _notesController.text.trim().isEmpty
        ? null
        : _notesController.text;

    final updatedTask = await Navigator.of(context).push<PenoteTask>(
      MaterialPageRoute(builder: (_) => CanvasScreen(task: task)),
    );

    if (updatedTask != null && mounted) {
      setState(() {
        _currentNotes = updatedTask.notes;
        _notesController.text = updatedTask.notes ?? '';
        _titleController.text = updatedTask.title;
        _locationController.text = updatedTask.location;
      });
    }
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
        // Toolbar formatting
        _NotesToolbar(
          onBold: () => _wrapSelection('**', '**'),
          onItalic: () => _wrapSelection('_', '_'),
          onBullet: _insertBullet,
        ),
        const SizedBox(height: 8),
        // Editor
        _NotesField(controller: _notesController, focusNode: _notesFocus),
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
          // Tombol EDIT DETAIL → Canvas
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _openEditDetail,
              icon: const Icon(Icons.open_in_new_rounded, size: 18),
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
          const SizedBox(height: 12),
          // Tombol SIMPAN
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

// ── Notes toolbar & field ────────────────────────────────────────────────────

/// Toolbar pemformatan untuk field catatan.
///
/// Menyediakan tombol Bold, Italic, dan Bullet Point yang bekerja
/// pada teks yang dipilih dalam editor catatan.
class _NotesToolbar extends StatelessWidget {
  const _NotesToolbar({
    required this.onBold,
    required this.onItalic,
    required this.onBullet,
  });

  /// Callback untuk menerapkan format tebal (**bold**).
  final VoidCallback onBold;

  /// Callback untuk menerapkan format miring (_italic_).
  final VoidCallback onItalic;

  /// Callback untuk menambahkan bullet point (• ).
  final VoidCallback onBullet;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF7E9CF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD8CDBE)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToolBtn(
            tooltip: 'Tebal',
            onTap: onBold,
            child: const Text(
              'B',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: Color(0xFF2F241D),
              ),
            ),
          ),
          const SizedBox(width: 2),
          _ToolBtn(
            tooltip: 'Miring',
            onTap: onItalic,
            child: const Text(
              'I',
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2F241D),
              ),
            ),
          ),
          const SizedBox(width: 2),
          _ToolBtn(
            tooltip: 'Bullet',
            onTap: onBullet,
            child: const Icon(
              Icons.format_list_bulleted_rounded,
              size: 18,
              color: Color(0xFF2F241D),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            '**tebal**  _miring_',
            style: TextStyle(
              fontSize: 10,
              color: Color(0xFF9E8E7E),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tombol kecil dalam toolbar dengan tooltip dan efek ripple.
class _ToolBtn extends StatelessWidget {
  const _ToolBtn({
    required this.tooltip,
    required this.onTap,
    required this.child,
  });

  /// Teks tooltip yang muncul saat tombol ditekan lama.
  final String tooltip;

  /// Callback ketika tombol ini diketuk.
  final VoidCallback onTap;

  /// Widget konten di dalam tombol (teks atau ikon).
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Widget field input untuk catatan aktifitas.
///
/// Menggunakan [StatefulWidget] agar bisa merespons perubahan teks
/// dan memicu rebuild ketika konten berubah.
class _NotesField extends StatefulWidget {
  const _NotesField({required this.controller, required this.focusNode});

  /// Controller teks yang terhubung dengan field ini.
  final TextEditingController controller;

  /// FocusNode untuk mengontrol fokus keyboard.
  final FocusNode focusNode;

  @override
  State<_NotesField> createState() => _NotesFieldState();
}

/// State dari [_NotesField] yang mendengarkan perubahan teks.
class _NotesFieldState extends State<_NotesField> {
  @override
  void initState() {
    super.initState();
    // Daftarkan listener untuk memicu rebuild saat teks berubah
    widget.controller.addListener(_rebuild);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_rebuild);
    super.dispose();
  }

  /// Memicu rebuild widget agar UI selalu sinkron dengan isi teks.
  void _rebuild() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      maxLines: null,
      minLines: 4,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Color(0xFF2F241D),
        height: 1.6,
      ),
      decoration: InputDecoration(
        hintText:
            'Tulis catatan...\nGunakan **teks** untuk tebal, _teks_ untuk miring.',
        hintStyle: const TextStyle(
          color: Color(0xFF9E8E7E),
          fontSize: 13,
          height: 1.6,
        ),
        filled: true,
        fillColor: const Color(0xFFFCF8F1),
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
        contentPadding: const EdgeInsets.all(14),
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
