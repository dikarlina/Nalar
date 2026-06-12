import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class JoinClassScreen extends StatefulWidget {
  const JoinClassScreen({super.key});

  @override
  State<JoinClassScreen> createState() => _JoinClassScreenState();
}

class _JoinClassScreenState extends State<JoinClassScreen> {
  final _formKey = GlobalKey<FormState>();
  final codeController = TextEditingController();
  final FocusNode _codeFocus = FocusNode();
  bool isLoading = false;

  @override
  void dispose() {
    codeController.dispose();
    _codeFocus.dispose();
    super.dispose();
  }

  Future<void> joinClass() async {
    if (!_formKey.currentState!.validate()) return;

    final code = codeController.text.trim().toUpperCase();

    setState(() => isLoading = true);

    try {
      // Cari kelas berdasarkan kode
      final query = await FirebaseFirestore.instance
          .collection('classes')
          .where('classCode', isEqualTo: code)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Kode kelas tidak ditemukan"),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.red.shade400,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
        return;
      }

      final classDoc = query.docs.first;
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final email = FirebaseAuth.instance.currentUser!.email ?? '';

      // Cek apakah sudah join
      final memberDoc = await classDoc.reference
          .collection('members')
          .doc(uid)
          .get();

      if (memberDoc.exists) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Kamu sudah terdaftar di kelas ini"),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
        return;
      }

      // Tambah ke subcollection members
      await classDoc.reference.collection('members').doc(uid).set({
        'uid': uid,
        'email': email,
        'joinedAt': FieldValue.serverTimestamp(),
        'role': 'siswa',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Berhasil join kelas!"),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal join: $e"),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red.shade400,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A2D3D)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Join Kelas",
          style: TextStyle(
            color: Color(0xFF1A2D3D),
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header / Intro Section
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
                        Icons.group_add_outlined,
                        color: Color(0xFF327CA0),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Masuk Kelas Baru",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A2D3D),
                            ),
                          ),
                          Text(
                            "Gunakan kode yang diberikan oleh gurumu",
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF8FA3B0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Animated Input Field (Identik dengan Create Class)
                _FocusField(
                  label: 'Kode Kelas',
                  hint: 'Contoh: ABC123',
                  controller: codeController,
                  focusNode: _codeFocus,
                  isRequired: true,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Kode kelas tidak boleh kosong'
                      : null,
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
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                          "Pastikan kode terdiri dari kombinasi huruf dan angka tanpa spasi.",
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

                const SizedBox(height: 24),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : joinClass,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF327CA0),
                      disabledBackgroundColor: const Color(0xFF327CA0).withOpacity(0.5),
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
                            'Join Kelas',
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
}

// ─── Animated focus field (Sama persis dengan Create Class) ──────────────────
class _FocusField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isRequired;
  final String? Function(String?)? validator;

  const _FocusField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.focusNode,
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
                color: _focused ? const Color(0xFF327CA0) : const Color(0xFF5A7080),
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
            textCapitalization: TextCapitalization.characters,
            textInputAction: TextInputAction.done,
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
                borderSide: const BorderSide(color: Color(0xFF327CA0), width: 1.6),
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