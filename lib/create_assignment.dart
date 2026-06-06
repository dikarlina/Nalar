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
  final titleController = TextEditingController();
  final scoreController = TextEditingController();
  DateTime? deadline;
  bool isLoading = false;

  Uint8List? fileBytes;
  String? fileName;

  @override
  void dispose() {
    titleController.dispose();
    scoreController.dispose();
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("File gagal dibaca")));
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

    await supabase.storage
        .from('materials')
        .uploadBinary(
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
    );

    if (date != null) setState(() => deadline = date);
  }

  // ================= SAVE =================
  Future<void> save() async {
    final title = titleController.text.trim();
    final scoreText = scoreController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Judul wajib diisi")));
      return;
    }

    if (scoreText.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Score wajib diisi")));
      return;
    }

    if (deadline == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Deadline wajib dipilih")));
      return;
    }

    setState(() => isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User belum login");

      // upload PDF kalau ada
      final fileUrl = await uploadFile();

      await FirebaseFirestore.instance
          .collection('classes')
          .doc(widget.classId)
          .collection('assignments')
          .add({
            'title': title,
            'score': int.tryParse(scoreText) ?? 0,
            'deadline': Timestamp.fromDate(deadline!),
            'createdBy': user.uid,
            'creatorEmail': user.email ?? '',
            'createdAt': FieldValue.serverTimestamp(),
            // null kalau ga ada file
            'fileUrl': fileUrl ?? '',
            'fileName': fileName ?? '',
          });

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal menyimpan: $e")));
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Assignment")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Judul Assignment"),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: scoreController,
              decoration: const InputDecoration(labelText: "Score Maksimal"),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 20),

            OutlinedButton.icon(
              onPressed: pickDate,
              icon: const Icon(Icons.calendar_today),
              label: Text(
                deadline == null
                    ? "Pilih Deadline"
                    : "Deadline: ${deadline!.day}/${deadline!.month}/${deadline!.year}",
              ),
            ),

            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: isLoading ? null : pickPDF,
              icon: const Icon(Icons.upload_file),
              label: const Text("Lampirkan PDF (opsional)"),
            ),

            if (fileName != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.picture_as_pdf, color: Colors.red, size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      fileName!,
                      style: const TextStyle(color: Colors.green, fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],

            const Spacer(),

            ElevatedButton(
              onPressed: isLoading ? null : save,
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}
