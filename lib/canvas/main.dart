import 'package:flutter/material.dart';
import '../list.dart';

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

  /// Waktu aktifitas yang sedang dipilih (digabungkan tanggal + jam).
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

  // ── Format helpers ────────────────────────────────────────────────────────

  /// Membungkus teks yang dipilih di editor catatan dengan [prefix] dan [suffix].
  ///
  /// Jika tidak ada teks yang dipilih, menempatkan wrapper di posisi kursor
  /// sehingga user bisa langsung mengetik teks berformat.
  /// Setelah selesai, fokus dikembalikan ke editor catatan.
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
    final newEnd = newStart + selected.length;

    ctrl.value = ctrl.value.copyWith(
      text: newText,
      selection: TextSelection(baseOffset: newStart, extentOffset: newEnd),
    );
    _notesFocus.requestFocus();
  }

  /// Menambahkan bullet point (• ) di awal baris saat ini atau di awal
  /// setiap baris yang dipilih di editor catatan.
  ///
  /// Jika baris sudah memiliki bullet, bullet akan dihapus (toggle).
  /// Jika tidak ada kursor aktif, bullet disisipkan di akhir teks.
  void _insertBullet() {
    final ctrl = _notesCtrl;
    final sel = ctrl.selection;
    final text = ctrl.text;

    if (!sel.isValid) {
      // Tidak ada kursor — sisipkan di akhir
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
      // Sisipkan bullet di posisi kursor
      // Cari awal baris saat ini
      final lineStart = before.lastIndexOf('\n') + 1;
      final linePrefix = before.substring(lineStart);
      final hasBullet = linePrefix.startsWith('• ');

      if (hasBullet) {
        // Sudah ada bullet — hapus
        final newBefore =
            before.substring(0, lineStart) + linePrefix.substring(2);
        final newText = '$newBefore$after';
        ctrl.value = ctrl.value.copyWith(
          text: newText,
          selection: TextSelection.collapsed(offset: newBefore.length),
        );
      } else {
        // Tambah bullet di awal baris
        final newBefore = before.substring(0, lineStart) + '• ' + linePrefix;
        final newText = '$newBefore$after';
        ctrl.value = ctrl.value.copyWith(
          text: newText,
          selection: TextSelection.collapsed(offset: newBefore.length),
        );
      }
    } else {
      // Tambah bullet di tiap baris yang dipilih
      final bulleted = selected
          .split('\n')
          .map((line) => line.startsWith('• ') ? line : '• $line')
          .join('\n');
      final newText = '$before$bulleted$after';
      ctrl.value = ctrl.value.copyWith(
        text: newText,
        selection: TextSelection(
          baseOffset: sel.start,
          extentOffset: sel.start + bulleted.length,
        ),
      );
    }
    _notesFocus.requestFocus();
  }

  /// Memvalidasi input dan menyimpan perubahan ke objek aktifitas.
  ///
  /// Menampilkan snackbar error jika judul atau lokasi kosong.
  /// Jika valid, langsung memperbarui field di objek [widget.task]
  /// dan menutup halaman dengan mengembalikan task yang sudah diperbarui.
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

    // Update field langsung di objek yang sama
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

  /// Membangun tampilan utama Canvas dengan AppBar, status banner,
  /// form detail, picker waktu, editor catatan, dan tombol simpan.
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
              // ── Status badge ──
              _StatusBanner(task: widget.task),
              const SizedBox(height: 20),

              // ── Card detail form ──
              _DetailCard(
                children: [
                  _CanvasSectionLabel('Judul Aktifitas'),
                  const SizedBox(height: 8),
                  _CanvasTextField(
                    controller: _titleCtrl,
                    hint: 'Nama aktifitas',
                    icon: Icons.title_rounded,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 16),
                  _CanvasSectionLabel('Tempat Aktifitas'),
                  const SizedBox(height: 8),
                  _CanvasTextField(
                    controller: _locationCtrl,
                    hint: 'Lokasi aktifitas',
                    icon: Icons.location_on_outlined,
                    maxLines: 1,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Card waktu ──
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

              // ── Card catatan ──
              _DetailCard(
                children: [
                  _CanvasSectionLabel('Catatan Tambahan'),
                  const SizedBox(height: 10),
                  // Toolbar formatting
                  _NotesFormattingToolbar(
                    onBold: () => _wrapSelection('**', '**'),
                    onItalic: () => _wrapSelection('_', '_'),
                    onBullet: _insertBullet,
                  ),
                  const SizedBox(height: 8),
                  // Editor catatan
                  _RichNotesEditor(
                    controller: _notesCtrl,
                    focusNode: _notesFocus,
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // ── Tombol Simpan ──
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

  /// Membangun AppBar dengan judul "Detail Aktifitas" dan tombol Simpan di kanan.
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
    );
  }
}

// ── Banner status aktifitas ───────────────────────────────────────────────────

/// Banner yang menampilkan status aktifitas di bagian atas halaman Canvas.
///
/// Menampilkan salah satu dari tiga kondisi: selesai (hijau),
/// terlambat (merah), atau dalam rencana (coklat).
class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.task});

  /// Aktifitas yang status-nya akan ditampilkan.
  final PenoteTask task;

  @override
  Widget build(BuildContext context) {
    final isCompleted = task.isCompleted;
    final isLate = task.scheduledAt.isBefore(DateTime.now()) && !isCompleted;

    Color bgColor;
    Color textColor;
    IconData iconData;
    String label;

    // Tentukan warna dan label berdasarkan status aktifitas
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

// ── Helper widgets ────────────────────────────────────────────────────────────

/// Kartu kontainer dengan rounded corner dan shadow untuk mengelompokkan konten.
class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.children});

  /// Daftar widget yang ditampilkan di dalam kartu.
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
            color: Colors.black.withOpacity(0.05),
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

/// TextField bergaya Canvas untuk input teks satu atau multi baris.
///
/// Mendukung prefixIcon hanya untuk field satu baris. Field multi baris
/// tidak menampilkan ikon agar lebih lapang.
class _CanvasTextField extends StatelessWidget {
  const _CanvasTextField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.maxLines = 1,
  });

  /// Controller yang terhubung dengan field ini.
  final TextEditingController controller;

  /// Teks placeholder saat field kosong.
  final String hint;

  /// Ikon prefix (hanya tampil jika [maxLines] == 1).
  final IconData icon;

  /// Jumlah baris maksimal. Default 1 (single-line).
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
        // Prefix icon hanya untuk field satu baris
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

// ── Toolbar formatting catatan ────────────────────────────────────────────────

/// Toolbar pemformatan untuk editor catatan Canvas.
///
/// Menyediakan tombol Bold, Italic, dan Bullet Point serta
/// hint teks panduan format markdown yang didukung.
class _NotesFormattingToolbar extends StatelessWidget {
  const _NotesFormattingToolbar({
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
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF7E9CF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD8CDBE), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _FormatButton(
            tooltip: 'Tebal (Bold)',
            onTap: onBold,
            child: const Text(
              'B',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color(0xFF2F241D),
              ),
            ),
          ),
          const SizedBox(width: 2),
          _FormatButton(
            tooltip: 'Miring (Italic)',
            onTap: onItalic,
            child: const Text(
              'I',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic,
                color: Color(0xFF2F241D),
              ),
            ),
          ),
          const SizedBox(width: 2),
          _FormatButton(
            tooltip: 'Bullet Point',
            onTap: onBullet,
            child: const Icon(
              Icons.format_list_bulleted_rounded,
              size: 18,
              color: Color(0xFF2F241D),
            ),
          ),
          const SizedBox(width: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              '• **tebal**  _miring_',
              style: TextStyle(
                fontSize: 10,
                color: Color(0xFF9E8E7E),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tombol format kecil dalam toolbar dengan tooltip dan efek ripple.
class _FormatButton extends StatelessWidget {
  const _FormatButton({
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

// ── Editor catatan dengan render markdown sederhana ───────────────────────────

/// Editor catatan yang menampilkan input teks sekaligus pratinjau render markdown.
///
/// Menampilkan kolom input di atas, dan di bawahnya — jika ada isi —
/// pratinjau hasil render **bold**, _italic_, dan bullet point.
class _RichNotesEditor extends StatefulWidget {
  const _RichNotesEditor({required this.controller, required this.focusNode});

  /// Controller teks untuk field catatan.
  final TextEditingController controller;

  /// FocusNode untuk mengontrol fokus keyboard pada field catatan.
  final FocusNode focusNode;

  @override
  State<_RichNotesEditor> createState() => _RichNotesEditorState();
}

/// State dari [_RichNotesEditor] yang mendengarkan perubahan fokus dan teks.
class _RichNotesEditorState extends State<_RichNotesEditor> {
  @override
  void initState() {
    super.initState();
    // Rebuild saat focus berubah agar preview ikut update
    widget.focusNode.addListener(_onFocusChange);
    widget.controller.addListener(_onTextChange);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    widget.controller.removeListener(_onTextChange);
    super.dispose();
  }

  /// Memicu rebuild saat status fokus field berubah.
  void _onFocusChange() => setState(() {});

  /// Memicu rebuild saat isi teks berubah agar pratinjau selalu sinkron.
  void _onTextChange() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Input field
        TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          maxLines: null,
          minLines: 5,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2F241D),
            height: 1.6,
          ),
          decoration: InputDecoration(
            hintText:
                'Tulis catatan...\n\nGunakan **teks** untuk tebal, _teks_ untuk miring,\natau tekan • untuk bullet point.',
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
              borderSide: const BorderSide(
                color: Color(0xFF8A5A44),
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.all(14),
          ),
        ),

        // Preview render (selalu tampil jika ada isi)
        if (widget.controller.text.trim().isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9F0),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFD8CDBE), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.visibility_outlined,
                      size: 13,
                      color: Color(0xFF9E8E7E),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Pratinjau',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF9E8E7E),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Render teks catatan dengan markdown sederhana
                buildNotesPreview(widget.controller.text),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

// ── Top-level helpers: bisa dipakai canvas & modal ───────────────────────────

/// Merender teks catatan dengan dukungan markdown sederhana menjadi Widget.
///
/// Mendukung baris bullet (dimulai dengan `• `) yang akan ditampilkan
/// sebagai item daftar dengan ikon lingkaran kecil.
/// Setiap baris diproses oleh [parseNotesInline] untuk render **bold** dan _italic_.
Widget buildNotesPreview(String text) {
  final lines = text.split('\n');
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: lines.map((line) {
      if (line.startsWith('• ')) {
        // Baris bullet — tampilkan dengan ikon titik di depan
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 7, right: 10),
                child: Icon(Icons.circle, size: 8, color: Color(0xFF8A5A44)),
              ),
              Expanded(child: parseNotesInline(line.substring(2))),
            ],
          ),
        );
      }
      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: parseNotesInline(line),
      );
    }).toList(),
  );
}

/// Mem-parse teks satu baris dengan format **bold** dan _italic_ menjadi [Text.rich].
///
/// Menggunakan regex untuk mendeteksi pola `**teks**` (bold) dan `_teks_` (italic).
/// Teks biasa di luar pola tersebut ditampilkan dengan gaya normal.
Widget parseNotesInline(String line) {
  final spans = <InlineSpan>[];
  final pattern = RegExp(r'\*\*(.+?)\*\*|_(.+?)_');
  int cursor = 0;

  const baseStyle = TextStyle(
    fontSize: 14,
    color: Color(0xFF4A3B2F),
    height: 1.7,
    fontWeight: FontWeight.w400,
  );

  for (final match in pattern.allMatches(line)) {
    // Tambahkan teks biasa sebelum pola
    if (match.start > cursor) {
      spans.add(
        TextSpan(text: line.substring(cursor, match.start), style: baseStyle),
      );
    }
    if (match.group(1) != null) {
      // Bold - gunakan fontWeight.w900 dan warna lebih gelap
      spans.add(
        TextSpan(
          text: match.group(1),
          style: baseStyle.copyWith(
            fontWeight: FontWeight.w900,
            color: const Color(0xFF1F1612),
            letterSpacing: 0.2,
          ),
        ),
      );
    } else if (match.group(2) != null) {
      // Italic - gunakan fontStyle italic dan warna coklat
      spans.add(
        TextSpan(
          text: match.group(2),
          style: baseStyle.copyWith(
            fontStyle: FontStyle.italic,
            color: const Color(0xFF8A5A44),
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }
    cursor = match.end;
  }

  // Tambahkan sisa teks setelah pola terakhir
  if (cursor < line.length) {
    spans.add(TextSpan(text: line.substring(cursor), style: baseStyle));
  }
  if (spans.isEmpty) {
    spans.add(TextSpan(text: line, style: baseStyle));
  }

  return Text.rich(TextSpan(children: spans));
}

/// Widget pratinjau catatan siap pakai dengan label "Catatan" dan konten render.
///
/// Mengembalikan [SizedBox.shrink] jika catatan kosong sehingga
/// tidak mengambil ruang di layar.
class NotesPreviewCard extends StatelessWidget {
  const NotesPreviewCard({super.key, required this.notes});

  /// Teks catatan yang akan dirender.
  final String notes;

  @override
  Widget build(BuildContext context) {
    if (notes.trim().isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9F0),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD8CDBE), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.notes_rounded, size: 13, color: Color(0xFF9E8E7E)),
              SizedBox(width: 4),
              Text(
                'Catatan',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF9E8E7E),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          buildNotesPreview(notes),
        ],
      ),
    );
  }
}

/// Tile yang bisa diketuk untuk memilih tanggal atau jam di halaman Canvas.
///
/// Menampilkan ikon, label (misalnya "Tanggal"), dan nilai yang dipilih
/// dalam kotak krem dengan border tipis.
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
