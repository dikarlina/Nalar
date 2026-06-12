import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'isi_kelas.dart';

// ─── Entry point: call this instead of Navigator.push ────────────────────────
void showCreateClassModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.35),
    builder: (_) => const _CreateClassSheet(),
  );
}

// ─── Keep the original class so existing Navigator.push calls still work ─────
class CreateClassForm extends StatelessWidget {
  const CreateClassForm({super.key});

  @override
  Widget build(BuildContext context) {
    // Immediately show the modal over a transparent scaffold
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showCreateClassModal(context);
    });
    return const Scaffold(backgroundColor: Colors.transparent);
  }
}

// ─── The actual modal sheet ───────────────────────────────────────────────────
class _CreateClassSheet extends StatefulWidget {
  const _CreateClassSheet();

  @override
  State<_CreateClassSheet> createState() => _CreateClassSheetState();
}

class _CreateClassSheetState extends State<_CreateClassSheet> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final TextEditingController _classNameController = TextEditingController();
  final TextEditingController _sectionController = TextEditingController();
  final TextEditingController _subjekController = TextEditingController();
  final TextEditingController _roomController = TextEditingController();

  final FocusNode _classNameFocus = FocusNode();
  final FocusNode _sectionFocus = FocusNode();
  final FocusNode _subjekFocus = FocusNode();
  final FocusNode _roomFocus = FocusNode();

  @override
  void dispose() {
    _classNameController.dispose();
    _sectionController.dispose();
    _subjekController.dispose();
    _roomController.dispose();
    _classNameFocus.dispose();
    _sectionFocus.dispose();
    _subjekFocus.dispose();
    _roomFocus.dispose();
    super.dispose();
  }

  String _generateClassCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random();
    return List.generate(6, (i) => chars[rand.nextInt(chars.length)]).join();
  }

  Future<void> _handleCreate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User belum login");

      final classCode = _generateClassCode();

      DocumentReference docRef =
          await FirebaseFirestore.instance.collection('classes').add({
        'className': _classNameController.text.trim(),
        'section': _sectionController.text.trim(),
        'subject': _subjekController.text.trim(),
        'room': _roomController.text.trim(),
        'createdAt': Timestamp.now(),
        'createdBy': user.uid,
        'classCode': classCode,
      });

      if (!mounted) return;

      Navigator.pop(context); // close modal

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kelas berhasil dibuat! Kode: $classCode'),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ClassDetailsScreen(
            classId: docRef.id,
            className: _classNameController.text.trim(),
            section: _sectionController.text.trim(),
            subject: _subjekController.text.trim(),
            room: _roomController.text.trim(),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membuat kelas: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade400,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(24)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 8, 24, 24 + bottomInset),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 20),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E8EE),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                // Header
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF327CA0).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.add_box_outlined,
                        color: Color(0xFF327CA0),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Buat Kelas",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A2D3D),
                          ),
                        ),
                        Text(
                          "Isi informasi kelas kamu",
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF8FA3B0),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F5F7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 18,
                          color: Color(0xFF8FA3B0),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // Fields
                _buildField(
                  label: 'Nama Kelas',
                  hint: 'cth. Matematika Lanjut',
                  controller: _classNameController,
                  focusNode: _classNameFocus,
                  nextFocus: _sectionFocus,
                  isRequired: true,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Nama kelas tidak boleh kosong'
                      : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildField(
                        label: 'Section',
                        hint: 'cth. A',
                        controller: _sectionController,
                        focusNode: _sectionFocus,
                        nextFocus: _subjekFocus,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildField(
                        label: 'Room',
                        hint: 'cth. Lab 3',
                        controller: _roomController,
                        focusNode: _roomFocus,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildField(
                  label: 'Subjek',
                  hint: 'cth. Fisika, Kimia, Biologi',
                  controller: _subjekController,
                  focusNode: _subjekFocus,
                  nextFocus: _roomFocus,
                ),

                const SizedBox(height: 28),

                // Divider
                Container(
                  height: 1,
                  color: const Color(0xFFF0F4F7),
                ),
                const SizedBox(height: 20),

                // Info chip
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF327CA0).withOpacity(0.06),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          size: 15,
                          color: const Color(0xFF327CA0).withOpacity(0.8)),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          "Kode kelas akan dibuat otomatis setelah kamu klik Buat.",
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

                // Submit button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleCreate,
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
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'Buat Kelas',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required FocusNode focusNode,
    FocusNode? nextFocus,
    bool isRequired = false,
    String? Function(String?)? validator,
  }) {
    return _FocusField(
      label: label,
      hint: hint,
      controller: controller,
      focusNode: focusNode,
      nextFocus: nextFocus,
      isRequired: isRequired,
      validator: validator,
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
  final String? Function(String?)? validator;

  const _FocusField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.focusNode,
    this.nextFocus,
    this.isRequired = false,
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
                    )
                  ]
                : [],
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            validator: widget.validator,
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
                borderSide: const BorderSide(
                    color: Color(0xFF327CA0), width: 1.6),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.red.shade300),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.red.shade400, width: 1.6),
              ),
              errorStyle: const TextStyle(fontSize: 11),
            ),
          ),
        ),
      ],
    );
  }
}