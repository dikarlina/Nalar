import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreateAssignmentScreen extends StatefulWidget {
  final String classId;

  const CreateAssignmentScreen({super.key, required this.classId});

  @override
  State<CreateAssignmentScreen> createState() => _CreateAssignmentScreenState();
}

class _CreateAssignmentScreenState extends State<CreateAssignmentScreen> {
  final _formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final scoreController = TextEditingController();
  final descriptionController = TextEditingController();

  final titleFocus = FocusNode();
  final scoreFocus = FocusNode();
  final descriptionFocus = FocusNode();

  DateTime? deadline;
  bool isLoading = false;

  Uint8List? fileBytes;
  String? fileName;

  @override
  void dispose() {
    titleController.dispose();
    scoreController.dispose();
    descriptionController.dispose();
    titleFocus.dispose();
    scoreFocus.dispose();
    descriptionFocus.dispose();
    super.dispose();
  }

  // ================= PICK PDF =================
  Future<void> pickPDF() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );

    if (result == null) return;

    final file = result.files.first;

    if (file.bytes == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          _snackBar("File gagal dibaca", isError: true),
        );
      }
      return;
    }

    setState(() {
      fileBytes = file.bytes;
      fileName = file.name;
    });
  }

  // ================= UPLOAD PDF KE SUPABASE =================
  Future<String?> uploadFile() async {
    if (fileBytes == null) return null;

    final supabase = Supabase.instance.client;
    final fileId = DateTime.now().millisecondsSinceEpoch.toString();
    final path = '${widget.classId}/assignments/$fileId.pdf';

    await supabase.storage.from('materials').uploadBinary(
      path,
      fileBytes!,
      fileOptions: const FileOptions(contentType: 'application/pdf'),
    );

    return supabase.storage.from('materials').getPublicUrl(path);
  }

  // ================= PICK DATE =================
  Future<void> pickDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF327CA0),
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) setState(() => deadline = date);
  }

  // ================= SAVE =================
  Future<void> save() async {
    if (!_formKey.currentState!.validate()) return;

    if (deadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        _snackBar("Deadline wajib dipilih", isError: true),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User belum login");

      final fileUrl = await uploadFile();

      await FirebaseFirestore.instance
          .collection('classes')
          .doc(widget.classId)
          .collection('assignments')
          .add({
        'title': titleController.text.trim(),
        'description': descriptionController.text.trim(),
        'score': int.tryParse(scoreController.text.trim()) ?? 0,
        'deadline': Timestamp.fromDate(deadline!),
        'createdBy': user.uid,
        'creatorEmail': user.email ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'fileUrl': fileUrl ?? '',
        'fileName': fileName ?? '',
      });

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          _snackBar("Gagal menyimpan: $e", isError: true),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  SnackBar _snackBar(String message, {bool isError = false}) {
    return SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      backgroundColor: isError ? Colors.red.shade400 : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  // ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F5F7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back, size: 18, color: Color(0xFF5A7080)),
          ),
        ),
        title: const Text(
          "Buat Tugas",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A2D3D),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header card ──
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF327CA0).withOpacity(0.07),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF327CA0).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.assignment_outlined,
                        color: Color(0xFF327CA0),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Tugas Baru",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A2D3D),
                          ),
                        ),
                        Text(
                          "Isi detail tugas untuk siswa",
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF8FA3B0),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Form fields card ──
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF327CA0).withOpacity(0.07),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _FocusField(
                      label: 'Judul Tugas',
                      hint: 'cth. Latihan Soal Bab 3',
                      controller: titleController,
                      focusNode: titleFocus,
                      nextFocus: scoreFocus,
                      isRequired: true,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Judul wajib diisi' : null,
                    ),

                    const SizedBox(height: 16),

                    _FocusField(
                      label: 'Score Maksimal',
                      hint: 'cth. 100',
                      controller: scoreController,
                      focusNode: scoreFocus,
                      nextFocus: descriptionFocus,
                      isRequired: true,
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Score wajib diisi' : null,
                    ),

                    const SizedBox(height: 16),

                    _FocusField(
                      label: 'Deskripsi',
                      hint: 'Jelaskan instruksi atau detail tugas...',
                      controller: descriptionController,
                      focusNode: descriptionFocus,
                      maxLines: 4,
                    ),

                    const SizedBox(height: 20),

                    // ── Deadline picker ──
                    _SectionLabel(label: 'Deadline', isRequired: true),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: pickDate,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 13),
                        decoration: BoxDecoration(
                          color: deadline != null
                              ? const Color(0xFF327CA0).withOpacity(0.05)
                              : const Color(0xFFF7F9FB),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: deadline != null
                                ? const Color(0xFF327CA0)
                                : const Color(0xFFE8EFF4),
                            width: deadline != null ? 1.6 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 18,
                              color: deadline != null
                                  ? const Color(0xFF327CA0)
                                  : const Color(0xFFB8CCDA),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              deadline == null
                                  ? 'Pilih tanggal deadline'
                                  : '${deadline!.day}/${deadline!.month}/${deadline!.year}',
                              style: TextStyle(
                                fontSize: 14,
                                color: deadline != null
                                    ? const Color(0xFF1A2D3D)
                                    : const Color(0xFFB8CCDA),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── PDF picker ──
                    _SectionLabel(label: 'Lampiran PDF (opsional)'),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: isLoading ? null : pickPDF,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 13),
                        decoration: BoxDecoration(
                          color: fileName != null
                              ? const Color(0xFF327CA0).withOpacity(0.05)
                              : const Color(0xFFF7F9FB),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: fileName != null
                                ? const Color(0xFF327CA0)
                                : const Color(0xFFE8EFF4),
                            width: fileName != null ? 1.6 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              fileName != null
                                  ? Icons.picture_as_pdf
                                  : Icons.upload_file_outlined,
                              size: 18,
                              color: fileName != null
                                  ? Colors.red.shade400
                                  : const Color(0xFFB8CCDA),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                fileName ?? 'Pilih file PDF',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: fileName != null
                                      ? const Color(0xFF1A2D3D)
                                      : const Color(0xFFB8CCDA),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (fileName != null)
                              GestureDetector(
                                onTap: () => setState(() {
                                  fileBytes = null;
                                  fileName = null;
                                }),
                                child: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Color(0xFF8FA3B0),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Info chip ──
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF327CA0).withOpacity(0.06),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 15,
                      color: const Color(0xFF327CA0).withOpacity(0.8),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        "Siswa akan menerima notifikasi setelah tugas disimpan.",
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF327CA0),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Save button ──
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: isLoading ? null : save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF327CA0),
                    disabledBackgroundColor:
                        const Color(0xFF327CA0).withOpacity(0.5),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Simpan Tugas',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Section label ────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  final bool isRequired;

  const _SectionLabel({required this.label, this.isRequired = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF5A7080),
          ),
        ),
        if (isRequired)
          const Text(
            ' *',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF327CA0),
            ),
          ),
      ],
    );
  }
}

// ─── Animated focus field ─────────────────────────────────────────────────────
class _FocusField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final FocusNode focusNode;
  final FocusNode? nextFocus;
  final bool isRequired;
  final int maxLines;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const _FocusField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.focusNode,
    this.nextFocus,
    this.isRequired = false,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  State<_FocusField> createState() => _FocusFieldState();
}

class _FocusFieldState extends State<_FocusField> {
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(() {
      if (mounted) setState(() => _focused = widget.focusNode.hasFocus);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _focused
                    ? const Color(0xFF327CA0)
                    : const Color(0xFF5A7080),
              ),
            ),
            if (widget.isRequired)
              const Text(
                ' *',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF327CA0),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: _focused
                ? [
                    BoxShadow(
                      color: const Color(0xFF327CA0).withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            validator: widget.validator,
            maxLines: widget.maxLines,
            keyboardType: widget.keyboardType,
            textInputAction: widget.nextFocus != null
                ? TextInputAction.next
                : TextInputAction.done,
            onFieldSubmitted: (_) {
              if (widget.nextFocus != null) {
                FocusScope.of(context).requestFocus(widget.nextFocus);
              }
            },
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1A2D3D),
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: const TextStyle(
                color: Color(0xFFB8CCDA),
                fontSize: 13,
              ),
              filled: true,
              fillColor: _focused ? Colors.white : const Color(0xFFF7F9FB),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 13,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE8EFF4)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFF327CA0), width: 1.6),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.red.shade300),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    BorderSide(color: Colors.red.shade400, width: 1.6),
              ),
              errorStyle: const TextStyle(fontSize: 11),
            ),
          ),
        ),
      ],
    );
  }
}