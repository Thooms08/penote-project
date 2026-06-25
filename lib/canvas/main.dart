import 'package:flutter/material.dart';
import '../list.dart';

/// Halaman Canvas — edit detail lengkap sebuah Aktifitas
class CanvasScreen extends StatefulWidget {
  const CanvasScreen({super.key, required this.task});
  final PenoteTask task;

  @override
  State<CanvasScreen> createState() => _CanvasScreenState();
}

class _CanvasScreenState extends State<CanvasScreen> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _notesCtrl;
  late DateTime _scheduledAt;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.task.title);
    _locationCtrl = TextEditingController(text: widget.task.location);
    _notesCtrl = TextEditingController();
    _scheduledAt = widget.task.scheduledAt;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _locationCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

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
                  const SizedBox(height: 8),
                  _CanvasTextField(
                    controller: _notesCtrl,
                    hint: 'Tulis catatan atau detail tambahan di sini...',
                    icon: Icons.notes_rounded,
                    maxLines: 5,
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

// ── Banner status aktifitas ───────────────────────────────────────────────────

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

// ── Helper widgets ────────────────────────────────────────────────────────────

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

class _PickerTile extends StatelessWidget {
  const _PickerTile({
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
