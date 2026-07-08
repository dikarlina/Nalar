import 'package:flutter/material.dart';
import 'constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

import 'anggota_kelas.dart';
import 'forum_kelas.dart';
import 'isi_kelas.dart';
import 'submit_assignment.dart';
import 'home_screen.dart';

// ── Transisi cepat khusus untuk pindah tab lewat bottom nav ──
Route _tabRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (_, __, ___) => page,
    transitionDuration: const Duration(milliseconds: 160),
    reverseTransitionDuration: const Duration(milliseconds: 160),
    transitionsBuilder: (_, animation, __, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

class DaftarTugasScreen extends StatefulWidget {
  final String classId;
  final String className;
  final String section;
  final String subject;
  final String room;

  const DaftarTugasScreen({
    super.key,
    required this.classId,
    required this.className,
    required this.section,
    required this.subject,
    required this.room,
  });

  @override
  State<DaftarTugasScreen> createState() => _DaftarTugasScreenState();
}

class _DaftarTugasScreenState extends State<DaftarTugasScreen> {
  int _selectedIndex = 1;
  final String? currentUid = FirebaseAuth.instance.currentUser?.uid;
  bool _isTeacher = false; // State untuk mendeteksi peran pengajar

  CollectionReference get assignmentsRef => FirebaseFirestore.instance
      .collection('classes')
      .doc(widget.classId)
      .collection('assignments');

  @override
  void initState() {
    super.initState();
    _checkRole();
  }

  // Cek apakah user saat ini adalah pembuat kelas (Pengajar)
  Future<void> _checkRole() async {
    try {
      final classDoc = await FirebaseFirestore.instance
          .collection('classes')
          .doc(widget.classId)
          .get();
      if (classDoc.exists) {
        final data = classDoc.data();
        if (mounted) {
          setState(() {
            _isTeacher = (data?['createdBy'] == currentUid);
          });
        }
      }
    } catch (e) {
      print("Error checking role: $e");
    }
  }

  Future<void> _openFile(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);

    if (index == 0) {
      Navigator.pushReplacement(context, _tabRoute(
        ClassDetailsScreen(
          classId: widget.classId, className: widget.className,
          section: widget.section, subject: widget.subject, room: widget.room,
        ),
      ));
    }
    if (index == 2) {
      Navigator.pushReplacement(context, _tabRoute(
        AnggotaKelasScreen(
          classId: widget.classId, className: widget.className,
          section: widget.section, subject: widget.subject, room: widget.room,
        ),
      ));
    }
    if (index == 3) {
      Navigator.pushReplacement(context, _tabRoute(
        ForumKelasScreen(
          classId: widget.classId, className: widget.className,
          section: widget.section, subject: widget.subject, room: widget.room,
        ),
      ));
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
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
            );
          },
        ),
        centerTitle: true,
        title: Text(
          widget.className,
          style: const TextStyle(
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
      body: StreamBuilder<QuerySnapshot>(
        stream: assignmentsRef.orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2, color: kBlue),
            );
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: kBlue.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(Icons.assignment_outlined, color: kBlue, size: 28),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Belum ada tugas',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1A2D3D)),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tugas yang diberikan akan muncul di sini',
                    style: TextStyle(fontSize: 12, color: Color(0xFF8FA3B0)),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final fileUrl = data['fileUrl'] ?? '';
              final deadline = data['deadline'];

              String deadlineStr = '-';
              if (deadline != null && deadline is Timestamp) {
                final d = deadline.toDate();
                deadlineStr = '${d.day}/${d.month}/${d.year}';
              }

              // Jika user adalah Pengajar, dia tidak punya status submission individu
              if (_isTeacher) {
                return _AssignmentCard(
                  title: data['title'] ?? '-',
                  deadlineStr: deadlineStr,
                  score: data['score']?.toString() ?? '-',
                  fileUrl: fileUrl,
                  sudahSubmit: false,
                  isTeacher: true, 
                  onOpenFile: fileUrl.isNotEmpty ? () => _openFile(fileUrl) : null,
                  onSubmit: () {
                    // Berpindah ke screen detail tugas / halaman list pengumpulan siswa (jika ada)
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SubmitAssignmentScreen(
                          classId: widget.classId,
                          assignmentId: doc.id,
                          assignmentTitle: data['title'] ?? '-',
                          sudahSubmit: false, // Default false untuk view pengajar
                        ),
                      ),
                    );
                  },
                );
              }

              // Jika user adalah Pelajar, ambil status pengumpulannya
              return FutureBuilder<DocumentSnapshot>(
                future: assignmentsRef
                    .doc(doc.id)
                    .collection('submissions')
                    .doc(currentUid)
                    .get(),
                builder: (context, subSnap) {
                  final sudahSubmit = subSnap.hasData && subSnap.data!.exists;

                  return _AssignmentCard(
                    title: data['title'] ?? '-',
                    deadlineStr: deadlineStr,
                    score: data['score']?.toString() ?? '-',
                    fileUrl: fileUrl,
                    sudahSubmit: sudahSubmit,
                    isTeacher: false,
                    onOpenFile: fileUrl.isNotEmpty ? () => _openFile(fileUrl) : null,
                    onSubmit: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SubmitAssignmentScreen(
                            classId: widget.classId,
                            assignmentId: doc.id,
                            assignmentTitle: data['title'] ?? '-',
                            sudahSubmit: sudahSubmit,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: kBorder)),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: kBlue,
          unselectedItemColor: const Color(0xFFB0BEC5),
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.class_outlined), label: 'Kelas'),
            BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), label: 'Tugas'),
            BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: 'Anggota'),
            BottomNavigationBarItem(icon: Icon(Icons.forum_outlined), label: 'Forum'),
          ],
        ),
      ),
    );
  }
}

// ─── Assignment Card ──────────────────────────────────────────────────────────

class _AssignmentCard extends StatelessWidget {
  final String title;
  final String deadlineStr;
  final String score;
  final String fileUrl;
  final bool sudahSubmit;
  final bool isTeacher; 
  final VoidCallback? onOpenFile;
  final VoidCallback onSubmit;

  const _AssignmentCard({
    required this.title,
    required this.deadlineStr,
    required this.score,
    required this.fileUrl,
    required this.sudahSubmit,
    required this.isTeacher,
    this.onOpenFile,
    required this.onSubmit,
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
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: kBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Icon(Icons.assignment_outlined, color: kBlue, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A2D3D)),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined, size: 11, color: Color(0xFF8FA3B0)),
                          const SizedBox(width: 4),
                          Text(
                            deadlineStr,
                            style: const TextStyle(fontSize: 11, color: Color(0xFF8FA3B0)),
                          ),
                          const SizedBox(width: 10),
                          const Icon(Icons.star_outline, size: 11, color: Color(0xFF8FA3B0)),
                          const SizedBox(width: 4),
                          Text(
                            score,
                            style: const TextStyle(fontSize: 11, color: Color(0xFF8FA3B0)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: kBorder),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                // JIKA BUKAN PENGAJAR (SISWA) -> Tampilkan Status Chip
                if (!isTeacher)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: sudahSubmit ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          sudahSubmit ? Icons.check_circle_outline : Icons.radio_button_unchecked,
                          size: 12,
                          color: sudahSubmit ? const Color(0xFF43A047) : const Color(0xFFFB8C00),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          sudahSubmit ? 'Terkumpul' : 'Belum dikumpul',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: sudahSubmit ? const Color(0xFF43A047) : const Color(0xFFFB8C00),
                          ),
                        ),
                      ],
                    ),
                  ),

                // JIKA PENGAJAR -> Status Chip hilang, digantikan dengan Container kosong agar layout/Spacer tetap rapi
                if (isTeacher) const SizedBox.shrink(),

                const Spacer(),

                // Tombol PDF jika ada link filenya
                if (fileUrl.isNotEmpty)
                  GestureDetector(
                    onTap: onOpenFile,
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE05252).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.picture_as_pdf_outlined, size: 16, color: Color(0xFFE05252)),
                    ),
                  ),

                const SizedBox(width: 8),

                // Tombol Aksi Kumpulkan/Lihat (Kini tetap muncul di kedua belah pihak)
                GestureDetector(
                  onTap: onSubmit,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: kBlue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isTeacher
                          ? 'Lihat'
                          : (sudahSubmit ? 'Lihat' : 'Kumpulkan'),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}