import 'package:flutter/material.dart';
import 'list.dart';
import 'canvas/main.dart';

// ── Entry point: buka modal buat / edit aktifitas ───────────────────────────

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

class TaskCreationSheet extends StatefulWidget {
  const TaskCreationSheet({
    super.key,
    this.task,
    required this.scrollController,
  });

  final PenoteTask? task;
  final ScrollController scrollController;

  @override
  State<TaskCreationSheet> createState() => _TaskCreationSheetState();
}

class _TaskCreationSheetState extends State<TaskCreationSheet> {
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late final TextEditingController _titleController;
  late final TextEditingController _locationController;

  bool get _isEdit => widget.task != null;

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
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    super.dispose();
  }

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
    );
  }

  /// Simpan dan tutup modal
  void _submit() {
    final task = _buildTask();
    if (task == null) return;
    Navigator.of(context).pop(task);
  }

  /// Simpan lalu buka Canvas
  void _openEditDetail() {
    final task = _buildTask();
    if (task == null) return;
    // Kembalikan task dulu agar HomeView memperbarui daftar
    Navigator.of(context).pop(task);
    // Navigasi ke Canvas setelah modal tertutup
    Future.microtask(() {
      if (!context.mounted) return;
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => CanvasScreen(task: task)));
    });
  }

  // ── UI ────────────────────────────────────────────────────────────────────

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
        const SizedBox(height: 28),

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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
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

class _DateTimePickerTile extends StatelessWidget {
  const _DateTimePickerTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final String value;
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

class _PenoteTextField extends StatelessWidget {
  const _PenoteTextField({
    required this.controller,
    required this.hint,
    required this.icon,
  });
  final TextEditingController controller;
  final String hint;
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
