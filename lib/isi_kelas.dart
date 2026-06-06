import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

import 'daftar_tugas.dart';
import 'anggota_kelas.dart';
import 'forum_kelas.dart';
import 'setting_kelas.dart';

import 'create_material.dart';
import 'create_assignment.dart';
import 'user_service.dart';

class ClassDetailsScreen extends StatefulWidget {
  final String classId;
  final String className;
  final String section;
  final String subject;
  final String room;

  const ClassDetailsScreen({
    super.key,
    required this.classId,
    required this.className,
    required this.section,
    required this.subject,
    required this.room,
  });

  @override
  State<ClassDetailsScreen> createState() => _ClassDetailsScreenState();
}

class _ClassDetailsScreenState extends State<ClassDetailsScreen> {
  int _selectedIndex = 0;
  bool _isGuru = false;

  @override
  void initState() {
    super.initState();
    _checkRole();
  }

  Future<void> _checkRole() async {
    final result = await UserService.isGuruDiKelas(widget.classId);
    if (mounted) setState(() => _isGuru = result);
  }

  CollectionReference get assignmentsRef => FirebaseFirestore.instance
      .collection('classes')
      .doc(widget.classId)
      .collection('assignments');

  CollectionReference get materialsRef => FirebaseFirestore.instance
      .collection('classes')
      .doc(widget.classId)
      .collection('materials');

  // ================= BUKA FILE =================
  Future<void> _openFile(String url) async {
    if (url.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Tidak ada file terlampir")));
      return;
    }
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Gagal membuka file")));
      }
    }
  }

  // ================= HAPUS ASSIGNMENT =================
  Future<void> _deleteAssignment(String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hapus Assignment"),
        content: const Text("Yakin mau hapus assignment ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    await assignmentsRef.doc(docId).delete();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Assignment dihapus")));
    }
  }

  // ================= HAPUS MATERIAL =================
  Future<void> _deleteMaterial(String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hapus Material"),
        content: const Text("Yakin mau hapus material ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    await materialsRef.doc(docId).delete();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Material dihapus")));
    }
  }

  // ================= CREATE ASSIGNMENT =================
  Future<void> _goCreateAssignment() async {
    if (!_isGuru) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Hanya guru yang bisa membuat assignment"),
        ),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateAssignmentScreen(classId: widget.classId),
      ),
    );
  }

  // ================= CREATE MATERIAL =================
  Future<void> _goCreateMaterial() async {
    if (!_isGuru) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Hanya guru yang bisa upload materi")),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateMaterialScreen(classId: widget.classId),
      ),
    );
  }

  // ================= NAVIGATION =================
  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DaftarTugasScreen(
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
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: Text(widget.className),
        centerTitle: true,
        actions: [
          if (_isGuru) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ClassSettingsScreen()),
                );
              },
            ),
            IconButton(icon: const Icon(Icons.delete), onPressed: () {}),
          ],
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.subject),
                  Text("Room: ${widget.room}"),
                  Text("Section: ${widget.section}"),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // tombol create hanya tampil kalau guru
            if (_isGuru)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _goCreateMaterial,
                      child: const Text("Create Material"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _goCreateAssignment,
                      child: const Text("Create Assignment"),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 20),

            // ================= ASSIGNMENTS =================
            const Text(
              "Assignments",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            StreamBuilder<QuerySnapshot>(
              stream: assignmentsRef.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return const Text(
                    "Belum ada assignment",
                    style: TextStyle(color: Colors.grey),
                  );
                }
                return Column(
                  children: docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final fileUrl = data['fileUrl'] ?? '';
                    final hasFile = fileUrl.isNotEmpty;

                    return ListTile(
                      leading: const Icon(Icons.assignment),
                      title: Text(data['title'] ?? '-'),
                      subtitle: Text(
                        "by: ${data['creatorEmail'] ?? 'unknown'}",
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (hasFile)
                            IconButton(
                              icon: const Icon(
                                Icons.picture_as_pdf,
                                color: Colors.red,
                              ),
                              onPressed: () => _openFile(fileUrl),
                            ),
                          // tombol hapus hanya untuk guru
                          if (_isGuru)
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.grey,
                              ),
                              onPressed: () => _deleteAssignment(doc.id),
                            ),
                        ],
                      ),
                      onTap: hasFile ? () => _openFile(fileUrl) : null,
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 20),

            // ================= MATERIALS =================
            const Text(
              "Materials",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            StreamBuilder<QuerySnapshot>(
              stream: materialsRef.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return const Text(
                    "Belum ada materi",
                    style: TextStyle(color: Colors.grey),
                  );
                }
                return Column(
                  children: docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final fileUrl = data['fileUrl'] ?? '';

                    return ListTile(
                      leading: const Icon(
                        Icons.picture_as_pdf,
                        color: Colors.red,
                      ),
                      title: Text(data['title'] ?? '-'),
                      subtitle: Text(
                        "by: ${data['creatorEmail'] ?? 'unknown'}",
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.open_in_new),
                          if (_isGuru)
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.grey,
                              ),
                              onPressed: () => _deleteMaterial(doc.id),
                            ),
                        ],
                      ),
                      onTap: () => _openFile(fileUrl),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
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
