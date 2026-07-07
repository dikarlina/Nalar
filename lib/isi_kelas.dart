import 'package:flutter/material.dart';
import 'constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

import 'daftar_tugas.dart';
import 'anggota_kelas.dart';
import 'forum_kelas.dart';
import 'setting_kelas.dart';

import 'create_material.dart';
import 'create_assignment.dart';
import 'user_service.dart';
import 'home_screen.dart';


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

  Future<void> _openFile(String url) async {
    if (url.isEmpty) {
      _showSnack("Tidak ada file terlampir");
      return;
    }
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) _showSnack("Gagal membuka file");
    }
  }

  void _showSnack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: error ? const Color(0xFFE05252) : kBlue,
      ),
    );
  }

  Future<void> _deleteAssignment(String docId) async {
    final confirm = await _showDeleteDialog(
      title: 'Hapus Assignment',
      message: 'Yakin ingin menghapus assignment ini? Data yang sudah dikumpulkan siswa juga akan terhapus.',
    );
    if (confirm != true) return;
    await assignmentsRef.doc(docId).delete();
    if (mounted) _showSnack("Assignment dihapus");
  }

  Future<void> _deleteMaterial(String docId) async {
    final confirm = await _showDeleteDialog(
      title: 'Hapus Materi',
      message: 'Yakin ingin menghapus materi ini?',
    );
    if (confirm != true) return;
    await materialsRef.doc(docId).delete();
    if (mounted) _showSnack("Materi dihapus");
  }

  Future<bool?> _showDeleteDialog({
    required String title,
    required String message,
  }) {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFE05252).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.delete_outline,
                    color: Color(0xFFE05252), size: 20),
              ),
              const SizedBox(height: 14),
              Text(title,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A2D3D))),
              const SizedBox(height: 6),
              Text(message,
                  style: TextStyle(
                      fontSize: 13, color: Colors.grey[600], height: 1.5)),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: kBorder),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 11),
                      ),
                      child: const Text('Batal',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A2D3D))),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE05252),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 11),
                      ),
                      child: const Text('Hapus',
                          style: TextStyle(fontWeight: FontWeight.w600)),
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

  Future<void> _goCreateAssignment() async {
    if (!_isGuru) {
      _showSnack("Hanya guru yang bisa membuat assignment");
      return;
    }
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => CreateAssignmentScreen(classId: widget.classId)));
  }

  Future<void> _goCreateMaterial() async {
    if (!_isGuru) {
      _showSnack("Hanya guru yang bisa upload materi");
      return;
    }
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => CreateMaterialScreen(classId: widget.classId)));
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);

    if (index == 1) {
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (_) => DaftarTugasScreen(
          classId: widget.classId, className: widget.className,
          section: widget.section, subject: widget.subject, room: widget.room,
        ),
      ));
    }
    if (index == 2) {
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (_) => AnggotaKelasScreen(
          classId: widget.classId, className: widget.className,
          section: widget.section, subject: widget.subject, room: widget.room,
        ),
      ));
    }
    if (index == 3) {
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (_) => ForumKelasScreen(
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
        actions: [
          if (_isGuru) ...[
            IconButton(
              icon: const Icon(Icons.settings_outlined, size: 20),
              color: const Color(0xFF1A2D3D),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ClassSettingsScreen(
                      classId: widget.classId,
                      className: widget.className,
                      section: widget.section,
                      subject: widget.subject,
                      room: widget.room,
                    ),
                  ),
                );
              },
            ),
          ],
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: kBorder),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header Banner ─────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: kBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: kBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.class_outlined, color: kBlue, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.subject.isNotEmpty ? widget.subject : widget.className,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A2D3D),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          [
                            if (widget.section.isNotEmpty) widget.section,
                            if (widget.room.isNotEmpty) 'Ruang ${widget.room}',
                          ].join(' · '),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF8FA3B0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Create Buttons (Guru Only) ────────────────────────────────
            if (_isGuru)
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.upload_file_outlined,
                      label: 'Upload Materi',
                      onTap: _goCreateMaterial,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.assignment_outlined,
                      label: 'Buat Tugas',
                      onTap: _goCreateAssignment,
                    ),
                  ),
                ],
              ),

            if (_isGuru) const SizedBox(height: 16),

            // ── Assignments ───────────────────────────────────────────────
            _SectionHeader(title: 'Tugas', icon: Icons.assignment_outlined),
            const SizedBox(height: 8),

            StreamBuilder<QuerySnapshot>(
              stream: assignmentsRef.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const _LoadingTile();
                }
                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return const _EmptyTile(message: 'Belum ada tugas');
                }
                return _ContentCard(
                  children: docs.asMap().entries.map((entry) {
                    final i = entry.key;
                    final doc = entry.value;
                    final data = doc.data() as Map<String, dynamic>;
                    final fileUrl = data['fileUrl'] ?? '';

                    return _ListItemTile(
                      icon: Icons.assignment_outlined,
                      iconColor: kBlue,
                      title: data['title'] ?? '-',
                      subtitle: data['creatorEmail'] ?? 'unknown',
                      last: i == docs.length - 1,
                      onTap: fileUrl.isNotEmpty ? () => _openFile(fileUrl) : null,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (fileUrl.isNotEmpty)
                            _IconBtn(
                              icon: Icons.picture_as_pdf_outlined,
                              color: const Color(0xFFE05252),
                              onTap: () => _openFile(fileUrl),
                            ),
                          if (_isGuru)
                            _IconBtn(
                              icon: Icons.delete_outline,
                              color: Colors.grey[400]!,
                              onTap: () => _deleteAssignment(doc.id),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 20),

            // ── Materials ─────────────────────────────────────────────────
            _SectionHeader(title: 'Materi', icon: Icons.book_outlined),
            const SizedBox(height: 8),

            StreamBuilder<QuerySnapshot>(
              stream: materialsRef.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const _LoadingTile();
                }
                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return const _EmptyTile(message: 'Belum ada materi');
                }
                return _ContentCard(
                  children: docs.asMap().entries.map((entry) {
                    final i = entry.key;
                    final doc = entry.value;
                    final data = doc.data() as Map<String, dynamic>;
                    final fileUrl = data['fileUrl'] ?? '';

                    return _ListItemTile(
                      icon: Icons.picture_as_pdf_outlined,
                      iconColor: const Color(0xFFE05252),
                      title: data['title'] ?? '-',
                      subtitle: data['creatorEmail'] ?? 'unknown',
                      last: i == docs.length - 1,
                      onTap: () => _openFile(fileUrl),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _IconBtn(
                            icon: Icons.open_in_new_rounded,
                            color: Colors.grey[400]!,
                            onTap: () => _openFile(fileUrl),
                          ),
                          if (_isGuru)
                            _IconBtn(
                              icon: Icons.delete_outline,
                              color: Colors.grey[400]!,
                              onTap: () => _deleteMaterial(doc.id),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),

      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
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
    );
  }
}

// ─── Small Reusable Widgets ───────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kBorder),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: kBlue),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: kBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF8FA3B0)),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF8FA3B0),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _ContentCard extends StatelessWidget {
  final List<Widget> children;
  const _ContentCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _ListItemTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool last;
  final VoidCallback? onTap;
  final Widget trailing;

  const _ListItemTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.last,
    this.onTap,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: iconColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A2D3D),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF8FA3B0),
                        ),
                      ),
                    ],
                  ),
                ),
                trailing,
              ],
            ),
          ),
        ),
        if (!last) const Divider(height: 1, indent: 62, color: kBorder),
      ],
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _IconBtn({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}

class _LoadingTile extends StatelessWidget {
  const _LoadingTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
      ),
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: kBlue),
        ),
      ),
    );
  }
}

class _EmptyTile extends StatelessWidget {
  final String message;
  const _EmptyTile({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
      ),
      child: Center(
        child: Text(
          message,
          style: const TextStyle(fontSize: 13, color: Color(0xFFB0BEC5)),
        ),
      ),
    );
  }
}