import 'package:flutter/material.dart';

// Warna utama
const Color kBlue = Color(0xFF327BA1);
const Color kRed = Color(0xFFF24144);

class ClassSettingsScreen extends StatefulWidget {
  const ClassSettingsScreen({super.key});

  @override
  State<ClassSettingsScreen> createState() => _ClassSettingsScreenState();
}

class _ClassSettingsScreenState extends State<ClassSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _classNameController = TextEditingController();
  final _sectionController = TextEditingController();
  final _subjectController = TextEditingController();
  final _roomController = TextEditingController();
  final _emailController = TextEditingController();

  final String _createdDate = 'Oct 1, 2025, 09.31.';

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
      // Navigasi kembali ke ClassDetailsScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ClassDetailsScreen()),
      );
    }
  }

  void _onDeleteClass() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Class'),
        content: const Text(
          'Are you sure you want to delete this class? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              // TODO: Tambahkan logika hapus kelas di sini
            },
            style: TextButton.styleFrom(foregroundColor: kRed),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _onAddEmail() {
    final email = _emailController.text.trim();
    if (email.isNotEmpty) {
      // TODO: Tambahkan logika invite email di sini
      _emailController.clear();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Invitation sent to $email')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const SizedBox(height: 12),
                Center(
                  child: Column(
                    children: [
                      const Text(
                        'Class Settings',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Created on $_createdDate',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Class Details Section
                const Text(
                  'Class Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 14),

                // Class Name
                _buildLabel('Class name', required: true),
                const SizedBox(height: 6),
                _buildTextField(
                  controller: _classNameController,
                  hint: 'Type here',
                  validator: (val) => (val == null || val.isEmpty)
                      ? 'Class name is required'
                      : null,
                ),
                const SizedBox(height: 14),

                // Section
                _buildLabel('Section'),
                const SizedBox(height: 6),
                _buildTextField(
                  controller: _sectionController,
                  hint: 'Type here',
                ),
                const SizedBox(height: 14),

                // Subjek
                _buildLabel('Subjek'),
                const SizedBox(height: 6),
                _buildTextField(
                  controller: _subjectController,
                  hint: 'Type here',
                ),
                const SizedBox(height: 14),

                // Room
                _buildLabel('Room'),
                const SizedBox(height: 6),
                _buildTextField(controller: _roomController, hint: 'Type here'),
                const SizedBox(height: 28),

                // Class Invitation Section
                const Text(
                  'Class Invitation',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Add Manually',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: kBlue,
                  ),
                ),
                const SizedBox(height: 8),

                // Email Input
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'email@domain.com',
                          hintStyle: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(
                              color: Color(0xFFCCCCCC),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(
                              color: Color(0xFFCCCCCC),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(color: kBlue, width: 1.5),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _onAddEmail,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: kBlue, width: 2),
                        ),
                        child: Icon(Icons.add, color: kBlue, size: 20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _onSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Delete Class Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _onDeleteClass,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kRed,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Delete Class',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, {bool required = false}) {
    return Row(
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: kBlue,
          ),
        ),
        if (required) ...[
          const SizedBox(width: 4),
          Text(
            '(required)',
            style: TextStyle(fontSize: 13, color: kBlue.withOpacity(0.7)),
          ),
        ],
      ],
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
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: kBlue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: kRed),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Placeholder ClassDetailsScreen
// Ganti ini dengan implementasi aslimu
// ─────────────────────────────────────────────
class ClassDetailsScreen extends StatelessWidget {
  const ClassDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Class Details'),
        backgroundColor: Color(0xFF327BA1),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Class Details Screen', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
