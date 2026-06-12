import 'package:flutter/material.dart';
import 'constants.dart';
import 'home_screen.dart';


class ClassSettingsScreen extends StatefulWidget {
  final String classId;
  final String className;
  final String section;
  final String subject;
  final String room;

  const ClassSettingsScreen({
    super.key,
    required this.classId,
    required this.className,
    required this.section,
    required this.subject,
    required this.room,
  });

  @override
  State<ClassSettingsScreen> createState() => _ClassSettingsScreenState();
}

class _ClassSettingsScreenState extends State<ClassSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _classNameController;
  late final TextEditingController _sectionController;
  late final TextEditingController _subjectController;
  late final TextEditingController _roomController;
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _classNameController = TextEditingController(text: widget.className);
    _sectionController = TextEditingController(text: widget.section);
    _subjectController = TextEditingController(text: widget.subject);
    _roomController = TextEditingController(text: widget.room);
  }

  @override
  void dispose() {
    _classNameController.dispose();
    _sectionController.dispose();
    _subjectController.dispose();
    _roomController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      // TODO: simpan ke Firestore
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Perubahan disimpan'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: kBlue,
        ),
      );
      Navigator.pop(context);
    }
  }

  void _onDeleteClass() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: kRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.delete_outline, color: kRed, size: 22),
              ),
              const SizedBox(height: 16),
              const Text(
                'Hapus Kelas?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A2D3D),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Yakin ingin menghapus kelas ini? Seluruh data kelas termasuk materi, tugas, dan anggota akan terhapus permanen dan tidak bisa dikembalikan.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1A2D3D),
                        side: const BorderSide(color: kBorder),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                      child: const Text(
                        'Batal',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        // TODO: logika hapus kelas di Firestore
                        // Kembali ke HomeScreen setelah hapus
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HomeScreen(),
                          ),
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kRed,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                      child: const Text(
                        'Hapus',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onAddEmail() {
    final email = _emailController.text.trim();
    if (email.isNotEmpty) {
      // TODO: logika invite email
      _emailController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Undangan dikirim ke $email'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: kBlue,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 1,
        shadowColor: Colors.black12,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          color: const Color(0xFF1A2D3D),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Pengaturan Kelas',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A2D3D),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: kBorder),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Section: Detail Kelas ─────────────────────────────────────
              _SectionCard(
                title: 'Detail Kelas',
                children: [
                  _FieldItem(
                    label: 'Nama Kelas',
                    required: true,
                    child: _buildTextField(
                      controller: _classNameController,
                      hint: 'Masukkan nama kelas',
                      validator: (val) =>
                          (val == null || val.isEmpty) ? 'Nama kelas wajib diisi' : null,
                    ),
                  ),
                  _FieldItem(
                    label: 'Seksi',
                    child: _buildTextField(
                      controller: _sectionController,
                      hint: 'Contoh: A, B, 2024',
                    ),
                  ),
                  _FieldItem(
                    label: 'Mata Pelajaran',
                    child: _buildTextField(
                      controller: _subjectController,
                      hint: 'Contoh: Matematika',
                    ),
                  ),
                  _FieldItem(
                    label: 'Ruangan',
                    last: true,
                    child: _buildTextField(
                      controller: _roomController,
                      hint: 'Contoh: Lab 3',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── Section: Undangan ─────────────────────────────────────────
              _SectionCard(
                title: 'Undang Anggota',
                subtitle: 'Kirim undangan lewat email',
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF1A2D3D),
                            ),
                            decoration: InputDecoration(
                              hintText: 'email@domain.com',
                              hintStyle: const TextStyle(
                                color: Color(0xFFB0BEC5),
                                fontSize: 14,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 13,
                              ),
                              filled: true,
                              fillColor: kBg,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: kBorder),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: kBorder),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: kBlue, width: 1.5),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: _onAddEmail,
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: kBlue,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.send_rounded,
                                color: Colors.white, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ── Save Button ───────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Simpan Perubahan',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ── Delete Button ─────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: _onDeleteClass,
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text(
                    'Hapus Kelas',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kRed,
                    side: const BorderSide(color: kRed),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      style: const TextStyle(fontSize: 14, color: Color(0xFF1A2D3D)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFB0BEC5), fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        filled: true,
        fillColor: kBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kBlue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kRed, width: 1.5),
        ),
      ),
    );
  }
}

// ─── Reusable Section Card ────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A2D3D),
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF8FA3B0),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1, color: kBorder),
          ...children,
        ],
      ),
    );
  }
}

// ─── Field Item ───────────────────────────────────────────────────────────────

class _FieldItem extends StatelessWidget {
  final String label;
  final bool required;
  final bool last;
  final Widget child;

  const _FieldItem({
    required this.label,
    this.required = false,
    this.last = false,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
          child: Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8FA3B0),
                  letterSpacing: 0.3,
                ),
              ),
              if (required) ...[
                const SizedBox(width: 4),
                const Text(
                  '*',
                  style: TextStyle(color: kRed, fontSize: 13),
                ),
              ],
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          child: child,
        ),
        if (!last) const Divider(height: 1, color: kBorder),
      ],
    );
  }
}