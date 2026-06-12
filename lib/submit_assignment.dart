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

class _SubmitAssignmentScreenState extends State<SubmitAssignmentScreen> with SingleTickerProviderStateMixin {
  Uint8List? fileBytes;
  String? fileName;
  bool isLoading = false;
  bool isTeacher = false;
  Map<String, dynamic>? existingSubmission;
  TabController? _tabController;

  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
    if (widget.sudahSubmit) _loadExistingSubmission();
  }

  // ================= CEK APAKAH USER ADALAH PENGAJAR =================
  Future<void> _checkUserRole() async {
    try {
      final classDoc = await FirebaseFirestore.instance
          .collection('classes')
          .doc(widget.classId)
          .get();
      
      if (classDoc.exists) {
        final data = classDoc.data();
        // Cek jika UID user saat ini sama dengan pembuat kelas
        if (data?['createdBy'] == user?.uid || data?['teacherId'] == user?.uid) {
          setState(() {
            isTeacher = true;
            _tabController = TabController(length: 3, vsync: this);
          });
        }
      }
    } catch (e) {
      debugPrint("Gagal cek role: $e");
    }
  }

  // ================= LOAD SUBMISSION LAMA (ALUR PELAJAR) =================
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

  // ================= PICK PDF (ALUR PELAJAR) =================
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

  // ================= UPLOAD & SUBMIT (ALUR PELAJAR) =================
  Future<void> submit() async {
    if (fileBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Pilih file PDF terlebih dahulu"),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
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
            'isGraded': false,
            'grade': null,
          });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Tugas berhasil dikumpulkan!"),
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
            content: Text("Gagal submit: $e"),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // ================= UPDATE NILAI TUGAS (ALUR PENGAJAR) =================
  Future<void> _submitGrade(String studentId, String gradeValue) async {
    if (gradeValue.isEmpty) return;
    try {
      await FirebaseFirestore.instance
          .collection('classes')
          .doc(widget.classId)
          .collection('assignments')
          .doc(widget.assignmentId)
          .collection('submissions')
          .doc(studentId)
          .update({
            'grade': int.tryParse(gradeValue) ?? gradeValue,
            'isGraded': true,
            'gradedAt': FieldValue.serverTimestamp(),
          });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Nilai berhasil disimpan!"), 
            behavior: SnackBarBehavior.floating
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal menilai: $e"), 
            behavior: SnackBarBehavior.floating
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return isTeacher ? _buildTeacherLayout() : _buildStudentLayout();
  }

  // ───────────────────────────────────────────────────────────────────────────
  // VIEW UTAMA: ALUR PENGAJAR (REVIEW & PENILAIAN)
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildTeacherLayout() {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A2D3D)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Daftar Pengumpulan Tugas",
              style: TextStyle(color: Color(0xFF8FA3B0), fontSize: 11, fontWeight: FontWeight.w600),
            ),
            Text(
              widget.assignmentTitle,
              style: const TextStyle(color: Color(0xFF1A2D3D), fontWeight: FontWeight.w800, fontSize: 15),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF327CA0),
          unselectedLabelColor: const Color(0xFF8FA3B0),
          indicatorColor: const Color(0xFF327CA0),
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          tabs: const [
            Tab(text: "Ditugaskan"),
            Tab(text: "Terlambat"),
            Tab(text: "Dinilai"),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('classes')
            .doc(widget.classId)
            .collection('assignments')
            .doc(widget.assignmentId)
            .collection('submissions')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF327CA0)));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState("Belum ada siswa yang mengumpulkan tugas.");
          }

          final allSubmissions = snapshot.data!.docs;

          // Filter data submission berdasarkan status nilai siswa
          final ditugaskanList = allSubmissions.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['isGraded'] == false; 
          }).toList();

          final terlambatList = allSubmissions.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['isLate'] == true && data['isGraded'] == false;
          }).toList();

          final dinilaiList = allSubmissions.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['isGraded'] == true;
          }).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildSubmissionList(ditugaskanList),
              _buildSubmissionList(terlambatList.isEmpty ? ditugaskanList.where((d) => (d.data() as Map)['submittedAt'] == null).toList() : terlambatList),
              _buildSubmissionList(dinilaiList, isGradedTab: true),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSubmissionList(List<QueryDocumentSnapshot> docs, {bool isGradedTab = false}) {
    if (docs.isEmpty) {
      return _buildEmptyState("Tidak ada data di kategori ini.");
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      itemCount: docs.length,
      itemBuilder: (context, index) {
        final submission = docs[index].data() as Map<String, dynamic>;
        final studentId = docs[index].id;
        final email = submission['submitterEmail'] ?? 'Tanpa Email';
        final fileNameText = submission['fileName'] ?? 'dokumen.pdf';
        final fileUrl = submission['fileUrl'] ?? '';
        final currentGrade = submission['grade']?.toString() ?? '';
        
        // Parsing Waktu Submit secara human-readable
        String timeString = "-";
        if (submission['submittedAt'] != null) {
          final timestamp = submission['submittedAt'] as Timestamp;
          final date = timestamp.toDate();
          timeString = "${date.day}/${date.month} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
        }

        final TextEditingController gradeController = TextEditingController(text: currentGrade);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE8EFF4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // SUDAH FIX KATA 'spaceBetween'
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          email,
                          style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1A2D3D), fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Diserahkan: $timeString",
                          style: const TextStyle(color: Color(0xFF8FA3B0), fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  if (isGradedTab)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF327CA0).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "Nilai: $currentGrade",
                        style: const TextStyle(color: Color(0xFF327CA0), fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                ],
              ),
              const Divider(height: 24, color: Color(0xFFE8EFF4)),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        if (fileUrl.isNotEmpty) {
                          final uri = Uri.parse(fileUrl);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          }
                        }
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.picture_as_pdf, color: Color(0xFFD32F2F), size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              fileNameText,
                              style: const TextStyle(color: Color(0xFF327CA0), fontSize: 12, fontWeight: FontWeight.w600, decoration: TextDecoration.underline),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Input skor nilai
                  SizedBox(
                    width: 70,
                    height: 36,
                    child: TextField(
                      controller: gradeController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        hintText: "0-100",
                        hintStyle: const TextStyle(color: Color(0xFFB8CCDA), fontSize: 11),
                        contentPadding: EdgeInsets.zero,
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE8EFF4))),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF327CA0))),
                      ),
                      onSubmitted: (value) => _submitGrade(studentId, value),
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    icon: const Icon(Icons.check_circle, color: Color(0xFF327CA0), size: 22),
                    onPressed: () => _submitGrade(studentId, gradeController.text),
                  )
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String msg) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_turned_in_outlined, color: const Color(0xFF8FA3B0).withOpacity(0.5), size: 48),
          const SizedBox(height: 12),
          Text(msg, style: const TextStyle(color: Color(0xFF8FA3B0), fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // VIEW UTAMA: ALUR PELAJAR (KUMPULKAN FILE PDF)
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildStudentLayout() {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A2D3D)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Submit: ${widget.assignmentTitle}",
          style: const TextStyle(color: Color(0xFF1A2D3D), fontWeight: FontWeight.w800, fontSize: 16),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.sudahSubmit && existingSubmission != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF327CA0).withOpacity(0.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF327CA0).withOpacity(0.15)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(color: Color(0xFF327CA0), shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "Sudah Dikumpulkan",
                          style: TextStyle(color: Color(0xFF1A2D3D), fontWeight: FontWeight.w800, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "File: ${existingSubmission!['fileName'] ?? '-'}",
                      style: const TextStyle(fontSize: 12, color: Color(0xFF5A7080), fontWeight: FontWeight.w500),
                    ),
                    if (existingSubmission!['grade'] != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        "Nilai Anda: ${existingSubmission!['grade']}",
                        style: const TextStyle(fontSize: 13, color: Color(0xFF327CA0), fontWeight: FontWeight.w700),
                      ),
                    ],
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: () async {
                        final url = existingSubmission!['fileUrl'] ?? '';
                        if (url.isNotEmpty) {
                          final uri = Uri.parse(url);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          }
                        }
                      },
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.open_in_new, size: 14, color: Color(0xFF327CA0)),
                          SizedBox(width: 6),
                          Text(
                            "Lihat file yang dikumpulkan",
                            style: TextStyle(fontSize: 12, color: Color(0xFF327CA0), fontWeight: FontWeight.w700, decoration: TextDecoration.underline),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Kumpulkan Ulang",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF5A7080)),
              ),
              const SizedBox(height: 8),
            ],

            InkWell(
              onTap: isLoading ? null : pickPDF,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE8EFF4), width: 1.5),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF327CA0).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.upload_file_outlined, color: Color(0xFF327CA0), size: 22),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      fileName == null ? "Pilih Dokumen Tugas" : "Ganti Dokumen Tugas",
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A2D3D)),
                    ),
                    const SizedBox(height: 4),
                    const Text("Format file harus berupa PDF", style: TextStyle(fontSize: 11, color: Color(0xFF8FA3B0))),
                  ],
                ),
              ),
            ),

            if (fileName != null) ...[
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE8EFF4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.picture_as_pdf, color: Color(0xFFD32F2F), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        fileName!,
                        style: const TextStyle(color: Color(0xFF1A2D3D), fontSize: 13, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.check_circle, color: Color(0xFF327CA0), size: 18),
                  ],
                ),
              ),
            ],

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isLoading ? null : submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF327CA0),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : Text(
                        widget.sudahSubmit ? "Kumpulkan Ulang" : "Kumpulkan Tugas",
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }
}