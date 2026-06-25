import 'package:flutter/material.dart';

/// Model data untuk satu Aktifitas
class PenoteTask {
  PenoteTask({
    required this.id,
    required this.title,
    required this.location,
    required this.scheduledAt,
    required this.createdAt,
    required this.updatedAt,
    this.isCompleted = false,
    this.completedAt,
  });

  final String id;
  String title;
  String location;
  final DateTime scheduledAt;
  final DateTime createdAt;
  DateTime updatedAt;
  bool isCompleted;
  DateTime? completedAt; // datetime saat user centang

  String formatDateTime(DateTime value) {
    final weekdays = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    final wd = weekdays[value.weekday - 1];
    final mo = months[value.month - 1];
    return '$wd, ${value.day} $mo ${value.year} • ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
  }
}

// ── Widget daftar aktifitas ──────────────────────────────────────────────────

class TaskListView extends StatelessWidget {
  const TaskListView({
    super.key,
    required this.tasks,
    required this.onToggleComplete,
    required this.onEdit,
    required this.onDelete,
  });

  final List<PenoteTask> tasks;
  final ValueChanged<PenoteTask> onToggleComplete;
  final ValueChanged<PenoteTask> onEdit;
  final ValueChanged<PenoteTask> onDelete;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: tasks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final task = tasks[index];
        return _TaskCard(
          task: task,
          onToggle: () => onToggleComplete(task),
          onEdit: () => onEdit(task),
          onDelete: () => onDelete(task),
        );
      },
    );
  }
}

// ── Kartu satu aktifitas ─────────────────────────────────────────────────────

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.task,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  final PenoteTask task;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  bool get _isLate =>
      task.scheduledAt.isBefore(DateTime.now()) && !task.isCompleted;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
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
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 8, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Tombol Centang ──
              _CheckButton(isCompleted: task.isCompleted, onTap: onToggle),
              const SizedBox(width: 12),

              // ── Konten ──
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Judul + badge terlambat
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            task.title,
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
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
                        if (_isLate) _LateChip(),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Lokasi
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

                    // Waktu aktifitas
                    _InfoRow(
                      icon: Icons.event_rounded,
                      label: 'Aktifitas',
                      value: task.formatDateTime(task.scheduledAt),
                      color: const Color(0xFF8A5A44),
                    ),

                    // Waktu konfirmasi centang
                    if (task.isCompleted && task.completedAt != null) ...[
                      const SizedBox(height: 4),
                      _InfoRow(
                        icon: Icons.check_circle_rounded,
                        label: 'Selesai',
                        value: task.formatDateTime(task.completedAt!),
                        color: const Color(0xFF4F9D69),
                      ),
                    ],
                  ],
                ),
              ),

              // ── Menu aksi ──
              _ActionMenu(onEdit: onEdit, onDelete: onDelete),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Tombol centang animasi ───────────────────────────────────────────────────

class _CheckButton extends StatelessWidget {
  const _CheckButton({required this.isCompleted, required this.onTap});
  final bool isCompleted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isCompleted ? const Color(0xFF4F9D69) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isCompleted
                ? const Color(0xFF4F9D69)
                : const Color(0xFF8A5A44),
            width: 2,
          ),
          boxShadow: isCompleted
              ? [
                  BoxShadow(
                    color: const Color(0xFF4F9D69).withOpacity(0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: isCompleted
            ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
            : null,
      ),
    );
  }
}

// ── Badge "Terlambat" ────────────────────────────────────────────────────────

class _LateChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
    );
  }
}

// ── Baris info kecil ─────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: const Color(0xFF6E6258)),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ── Menu popup edit / hapus ──────────────────────────────────────────────────

class _ActionMenu extends StatelessWidget {
  const _ActionMenu({required this.onEdit, required this.onDelete});
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'edit') onEdit();
        if (value == 'delete') onDelete();
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 4,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: const [
              Icon(Icons.edit_rounded, size: 18, color: Color(0xFF8A5A44)),
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
    );
  }
}
