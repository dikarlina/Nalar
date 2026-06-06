import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

import 'anggota_kelas.dart';
import 'forum_kelas.dart';
import 'isi_kelas.dart';
import 'submit_assignment.dart';

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

  CollectionReference get assignmentsRef => FirebaseFirestore.instance
      .collection('classes')
      .doc(widget.classId)
      .collection('assignments');

  // ================= BUKA FILE =================
  Future<void> _openFile(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // ================= NAVIGATION =================
  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);

    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ClassDetailsScreen(
            classId: widget.classId,
            className: widget.className,
            section: widget.section,
            subject: widget.subject,
            room: widget.room,
          ),
        ),
      );
    }

    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AnggotaKelasScreen(
            classId: widget.classId,
            className: widget.className,
            section: widget.section,
            subject: widget.subject,
            room: widget.room,
          ),
        ),
      );
    }

    if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ForumKelasScreen(
            classId: widget.classId,
            className: widget.className,
            section: widget.section,
            subject: widget.subject,
            room: widget.room,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tugas - ${widget.className}"),
        centerTitle: true,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: assignmentsRef
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                "Belum ada tugas",
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
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

              // cek apakah sudah submit
              return FutureBuilder<DocumentSnapshot>(
                future: assignmentsRef
                    .doc(doc.id)
                    .collection('submissions')
                    .doc(currentUid)
                    .get(),
                builder: (context, subSnap) {
                  final sudahSubmit = subSnap.hasData && subSnap.data!.exists;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: const Icon(
                        Icons.assignment,
                        color: Colors.blue,
                        size: 32,
                      ),
                      title: Text(
                        data['title'] ?? '-',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Deadline: $deadlineStr"),
                          Text("Score: ${data['score'] ?? '-'}"),
                          const SizedBox(height: 4),
                          // status submit
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: sudahSubmit
                                  ? Colors.green.shade100
                                  : Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              sudahSubmit
                                  ? "✓ Sudah dikumpulkan"
                                  : "Belum dikumpulkan",
                              style: TextStyle(
                                color: sudahSubmit
                                    ? Colors.green
                                    : Colors.orange,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // tombol buka soal PDF
                          if (fileUrl.isNotEmpty)
                            IconButton(
                              icon: const Icon(
                                Icons.picture_as_pdf,
                                color: Colors.red,
                              ),
                              tooltip: "Lihat Soal",
                              onPressed: () => _openFile(fileUrl),
                            ),
                          // tombol submit
                          IconButton(
                            icon: Icon(
                              sudahSubmit
                                  ? Icons.check_circle
                                  : Icons.upload_file,
                              color: sudahSubmit ? Colors.green : Colors.blue,
                            ),
                            tooltip: sudahSubmit
                                ? "Sudah Submit"
                                : "Submit Tugas",
                            onPressed: () {
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
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.class_), label: 'Kelas'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Tugas'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Anggota'),
          BottomNavigationBarItem(icon: Icon(Icons.forum), label: 'Forum'),
        ],
      ),
    );
  }
}
