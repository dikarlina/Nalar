import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'isi_kelas.dart';

class CreateClassForm extends StatefulWidget {
  const CreateClassForm({super.key});

  @override
  State<CreateClassForm> createState() => _CreateClassFormState();
}

class _CreateClassFormState extends State<CreateClassForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _classNameController = TextEditingController();
  final TextEditingController _sectionController = TextEditingController();
  final TextEditingController _subjekController = TextEditingController();
  final TextEditingController _roomController = TextEditingController();

  // ================= GENERATE KODE KELAS =================
  String _generateClassCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random();
    return List.generate(6, (i) => chars[rand.nextInt(chars.length)]).join();
  }

  @override
  void dispose() {
    _classNameController.dispose();
    _sectionController.dispose();
    _subjekController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    if (_formKey.currentState!.validate()) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) throw Exception("User belum login");

        final classCode = _generateClassCode();

        DocumentReference docRef = await FirebaseFirestore.instance
            .collection('classes')
            .add({
              'className': _classNameController.text.trim(),
              'section': _sectionController.text.trim(),
              'subject': _subjekController.text.trim(),
              'room': _roomController.text.trim(),
              'createdAt': Timestamp.now(),
              'createdBy': user.uid,        // ← penting buat cek guru
              'classCode': classCode,        // ← buat join kelas
            });

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kelas berhasil dibuat! Kode: $classCode')),
        );

        Navigator.pushReplacement(
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
          SnackBar(content: Text('Gagal membuat kelas: $e')),
        );
      }
    }
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    bool isRequired = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF327CA0),
            ),
            children: isRequired
                ? const [
                    TextSpan(
                      text: ' (required)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF327CA0),
                      ),
                    ),
                  ]
                : [],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          decoration: InputDecoration(
            hintText: 'Type here',
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(
                color: Color(0xFF327CA0),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Buat Kelas",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF327CA0),
            letterSpacing: 1,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF327CA0)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildField(
                label: 'Class name',
                controller: _classNameController,
                isRequired: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Class name tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildField(label: 'Section', controller: _sectionController),
              const SizedBox(height: 20),
              _buildField(label: 'Subjek', controller: _subjekController),
              const SizedBox(height: 20),
              _buildField(label: 'Room', controller: _roomController),
              const SizedBox(height: 36),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _handleCreate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF327CA0),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Create',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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
}