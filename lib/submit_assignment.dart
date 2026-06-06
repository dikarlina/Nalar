import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class SubmitAssignmentScreen extends StatefulWidget {
  final String classId;
  final String assignmentId;
  final String assignmentTitle;
  final bool sudahSubmit;

  const SubmitAssignmentScreen({
    super.key,
    required this.classId,
    required this.assignmentId,
    required this.assignmentTitle,
    required this.sudahSubmit,
  });

  @override
  State<SubmitAssignmentScreen> createState() => _SubmitAssignmentScreenState();
}

class _SubmitAssignmentScreenState extends State<SubmitAssignmentScreen> {
  Uint8List? fileBytes;
  String? fileName;
  bool isLoading = false;
  Map<String, dynamic>? existingSubmission;

  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    if (widget.sudahSubmit) _loadExistingSubmission();
  }

  // ================= LOAD SUBMISSION LAMA =================
  Future<void> _loadExistingSubmission() async {
    final doc = await FirebaseFirestore.instance
        .collection('classes')
        .doc(widget.classId)
        .collection('assignments')
        .doc(widget.assignmentId)
        .collection('submissions')
        .doc(user?.uid)
        .get();

    if (doc.exists) {
      setState(() => existingSubmission = doc.data());
    }
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
    if (file.bytes == null) return;

    setState(() {
      fileBytes = file.bytes;
      fileName = file.name;
    });
  }

  // ================= UPLOAD & SUBMIT =================
  Future<void> submit() async {
    if (fileBytes == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Pilih file PDF dulu")));
      return;
    }

    setState(() => isLoading = true);

    try {
      final supabase = Supabase.instance.client;
      final fileId = DateTime.now().millisecondsSinceEpoch.toString();
      final path =
          '${widget.classId}/submissions/${widget.assignmentId}/${user!.uid}_$fileId.pdf';

      await supabase.storage
          .from('materials')
          .uploadBinary(
            path,
            fileBytes!,
            fileOptions: const FileOptions(contentType: 'application/pdf'),
          );

      final fileUrl = supabase.storage.from('materials').getPublicUrl(path);

      await FirebaseFirestore.instance
          .collection('classes')
          .doc(widget.classId)
          .collection('assignments')
          .doc(widget.assignmentId)
          .collection('submissions')
          .doc(user!.uid)
          .set({
            'fileUrl': fileUrl,
            'fileName': fileName ?? '',
            'submittedBy': user!.uid,
            'submitterEmail': user!.email ?? '',
            'submittedAt': FieldValue.serverTimestamp(),
          });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Tugas berhasil dikumpulkan!")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal submit: $e")));
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Submit: ${widget.assignmentTitle}")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // kalau sudah submit, tampilkan info submission lama
            if (widget.sudahSubmit && existingSubmission != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "✓ Sudah dikumpulkan",
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "File: ${existingSubmission!['fileName'] ?? '-'}",
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () async {
                        final url = existingSubmission!['fileUrl'] ?? '';
                        if (url.isNotEmpty) {
                          final uri = Uri.parse(url);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.open_in_new, size: 16),
                      label: const Text("Lihat file yang dikumpulkan"),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Kumpulkan ulang:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
            ],

            OutlinedButton.icon(
              onPressed: isLoading ? null : pickPDF,
              icon: const Icon(Icons.upload_file),
              label: const Text("Pilih File PDF"),
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
              onPressed: isLoading ? null : submit,
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      widget.sudahSubmit
                          ? "Kumpulkan Ulang"
                          : "Kumpulkan Tugas",
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
