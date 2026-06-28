import 'package:flutter/material.dart';

// ══════════════════════════════════════════════════════════════════════════════
// notes_helper.dart
// Berisi semua widget dan fungsi bantu untuk editor dan pratinjau catatan.
// Digunakan bersama oleh modal.dart dan canvas_screen.dart.
// ══════════════════════════════════════════════════════════════════════════════

// ── Toolbar formatting catatan ────────────────────────────────────────────────

/// Toolbar pemformatan untuk field catatan.
///
/// Menyediakan tiga tombol: Bold (**), Italic (_), dan Bullet Point (•).
/// Setiap tombol memanggil callback yang diteruskan dari parent.
class NotesFormattingToolbar extends StatelessWidget {
  const NotesFormattingToolbar({
    super.key,
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
          FormatButton(
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
          FormatButton(
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
          FormatButton(
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

// ── Tombol format ─────────────────────────────────────────────────────────────

/// Tombol kecil dalam toolbar dengan tooltip dan efek ripple.
class FormatButton extends StatelessWidget {
  const FormatButton({
    super.key,
    required this.tooltip,
    required this.onTap,
    required this.child,
  });

  /// Teks tooltip yang muncul saat tombol ditekan lama.
  final String tooltip;

  /// Callback ketika tombol diketuk.
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

// ── Editor catatan dengan pratinjau markdown ──────────────────────────────────

/// Editor catatan multi-baris yang menampilkan input teks dan pratinjau
/// render markdown secara langsung di bawahnya.
///
/// Mendukung format **bold**, _italic_, dan bullet point (• ).
class RichNotesEditor extends StatefulWidget {
  const RichNotesEditor({
    super.key,
    required this.controller,
    required this.focusNode,
  });

  /// Controller teks untuk field catatan.
  final TextEditingController controller;

  /// FocusNode untuk mengontrol fokus keyboard.
  final FocusNode focusNode;

  @override
  State<RichNotesEditor> createState() => _RichNotesEditorState();
}

/// State dari [RichNotesEditor] yang mendengarkan perubahan fokus dan teks.
class _RichNotesEditorState extends State<RichNotesEditor> {
  @override
  void initState() {
    super.initState();
    // Daftarkan listener agar pratinjau rebuild saat fokus/teks berubah
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
        // Input field catatan
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

        // Pratinjau hasil render — hanya tampil jika ada isi
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
                buildNotesPreview(widget.controller.text),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

// ── Top-level render helpers ──────────────────────────────────────────────────

/// Merender teks catatan dengan markdown sederhana menjadi Column widget.
///
/// Setiap baris diproses oleh [parseNotesInline] untuk format **bold** dan _italic_.
/// Baris yang diawali `• ` ditampilkan sebagai item bullet dengan ikon lingkaran.
Widget buildNotesPreview(String text) {
  final lines = text.split('\n');
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: lines.map((line) {
      if (line.startsWith('• ')) {
        // Baris bullet — tampilkan dengan ikon titik coklat di depan
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
      // Baris biasa
      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: parseNotesInline(line),
      );
    }).toList(),
  );
}

/// Mem-parse satu baris teks dengan pola **bold** dan _italic_ menjadi [Text.rich].
///
/// Menggunakan regex untuk mendeteksi `**teks**` (bold) dan `_teks_` (italic).
/// Teks biasa di luar pola ditampilkan dengan gaya normal.
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
    // Teks biasa sebelum pola
    if (match.start > cursor) {
      spans.add(
        TextSpan(text: line.substring(cursor, match.start), style: baseStyle),
      );
    }
    if (match.group(1) != null) {
      // Bold — warna lebih gelap dan font lebih tebal
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
      // Italic — warna coklat dan font miring
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

  // Sisa teks setelah pola terakhir
  if (cursor < line.length)
    spans.add(TextSpan(text: line.substring(cursor), style: baseStyle));
  if (spans.isEmpty) spans.add(TextSpan(text: line, style: baseStyle));

  // Pakai Text.rich agar mewarisi DefaultTextStyle dari context
  return Text.rich(TextSpan(children: spans));
}

// ── Widget pratinjau catatan ──────────────────────────────────────────────────

/// Widget pratinjau catatan siap pakai yang menampilkan label "Catatan"
/// dan hasil render markdown di bawahnya.
///
/// Mengembalikan [SizedBox.shrink] secara otomatis jika catatan kosong.
class NotesPreviewCard extends StatelessWidget {
  const NotesPreviewCard({super.key, required this.notes});

  /// Teks catatan yang akan dirender dalam format markdown sederhana.
  final String notes;

  @override
  Widget build(BuildContext context) {
    // Tidak tampilkan apapun jika catatan kosong
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
