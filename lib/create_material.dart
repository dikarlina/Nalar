import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';

class CreateMaterialScreen extends StatefulWidget {
  final String classId;

  const CreateMaterialScreen({super.key, required this.classId});

  @override
  State<CreateMaterialScreen> createState() => _CreateMaterialScreenState();
}

class _CreateMaterialScreenState extends State<CreateMaterialScreen> {
  final TextEditingController titleController = TextEditingController();

  Uint8List? fileBytes;
  String? fileName;
  bool isLoading = false;

  @override
  void dispose() {
    titleController.dispose();
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
          const SnackBar(content: Text("File gagal dibaca")),
        );
      }
      return;
    }

    setState(() {
      fileBytes = file.bytes;
      fileName = file.name;
    });
  }

  // ================= UPLOAD FILE KE SUPABASE =================
  Future<String> uploadFile() async {
    final supabase = Supabase.instance.client;
    final fileId = DateTime.now().millisecondsSinceEpoch.toString();
    final path = '${widget.classId}/$fileId.pdf';

    await supabase.storage.from('materials').uploadBinary(
      path,
      fileBytes!,
      fileOptions: const FileOptions(contentType: 'application/pdf'),
    );

    final url = supabase.storage.from('materials').getPublicUrl(path);

    return url;
  }

  // ================= SAVE MATERIAL =================
  Future<void> saveMaterial() async {
    final title = titleController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Judul wajib diisi")),
      );
      return;
    }

    if (fileBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih file PDF dulu")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User belum login");

      final url = await uploadFile();

      await FirebaseFirestore.instance
          .collection('classes')
          .doc(widget.classId)
          .collection('materials')
          .add({
            'title': title,
            'fileUrl': url,
            'fileName': fileName ?? '',
            'createdBy': user.uid,
            'creatorEmail': user.email ?? '',
            'createdAt': FieldValue.serverTimestamp(),
          });

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Upload gagal: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Material")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Judul Material"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: isLoading ? null : pickPDF,
              child: const Text("Pilih PDF"),
            ),

            const SizedBox(height: 10),

            Text(
              fileName ?? "Belum ada file dipilih",
              style: TextStyle(
                color: fileName != null ? Colors.green : Colors.grey,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: isLoading ? null : saveMaterial,
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text("Upload Material"),
            ),
          ],
        ),
      ),
    );
  }
}