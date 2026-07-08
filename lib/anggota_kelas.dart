import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'constants.dart';

import 'isi_kelas.dart';
import 'daftar_tugas.dart';
import 'forum_kelas.dart';
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

class AnggotaKelasScreen extends StatefulWidget {
  final String classId;
  final String className;
  final String section;
  final String subject;
  final String room;

  const AnggotaKelasScreen({
    super.key,
    required this.classId,
    required this.className,
    required this.section,
    required this.subject,
    required this.room,
  });

  @override
  State<AnggotaKelasScreen> createState() => _AnggotaKelasScreenState();
}

class _AnggotaKelasScreenState extends State<AnggotaKelasScreen> {
  int _selectedIndex = 2;

  // ── Refs ──────────────────────────────────────────────────────────────────
  DocumentReference get classDoc =>
      FirebaseFirestore.instance.collection('classes').doc(widget.classId);

  CollectionReference get membersRef =>
      classDoc.collection('members');

  // ── Navigation ────────────────────────────────────────────────────────────
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
    } else if (index == 1) {
      Navigator.pushReplacement(context, _tabRoute(
        DaftarTugasScreen(
          classId: widget.classId, className: widget.className,
          section: widget.section, subject: widget.subject, room: widget.room,
        ),
      ));
    } else if (index == 3) {
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
      // ── AppBar ──────────────────────────────────────────────────────────────
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

      // ── Body ────────────────────────────────────────────────────────────────
      body: StreamBuilder<QuerySnapshot>(
        stream: membersRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2, color: kBlue),
            );
          }

          final memberDocs = snapshot.data!.docs;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // ── SECTION PENGAJAR ──
              const Text(
                'PENGAJAR',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF8FA3B0),
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 12),

              // FutureBuilder untuk mengambil data 'createdBy' dari dokumen kelas
              FutureBuilder<DocumentSnapshot>(
                future: classDoc.get(),
                builder: (context, classSnap) {
                  if (!classSnap.hasData || !classSnap.data!.exists) {
                    return const SizedBox.shrink();
                  }
                  
                  final classData = classSnap.data!.data() as Map<String, dynamic>?;
                  final String? teacherUid = classData?['createdBy'];

                  if (teacherUid == null) return const SizedBox.shrink();

                  // Mengambil profil pengajar dari koleksi 'users' berdasarkan UID
                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance.collection('users').doc(teacherUid).get(),
                    builder: (context, userSnap) {
                      if (!userSnap.hasData || !userSnap.data!.exists) {
                        return const _MemberTile(name: 'Memuat pengajar...', isTeacher: true);
                      }

                      final userData = userSnap.data!.data() as Map<String, dynamic>?;
                      // Koleksi 'users' menggunakan field 'nama'
                      final String teacherName = userData?['nama'] ?? 'Pengajar Kelas';

                      return _MemberTile(name: teacherName, isTeacher: true);
                    },
                  );
                },
              ),

              const SizedBox(height: 28),
              const Divider(height: 1, color: kBorder),
              const SizedBox(height: 24),

              // ── SECTION ANGGOTA / SISWA ──
              _SectionLabel(label: 'Anggota', count: memberDocs.length),
              const SizedBox(height: 12),

              if (memberDocs.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'Belum ada anggota di kelas ini',
                    style: TextStyle(fontSize: 13, color: Color(0xFF8FA3B0)),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: memberDocs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final data = memberDocs[index].data() as Map<String, dynamic>;

                    // Coba ambil nama langsung dulu dari dokumen member
                    final String? directName = data['nama'] as String?;
                    if (directName != null && directName.isNotEmpty) {
                      return _MemberTile(name: directName, isTeacher: false);
                    }

                    // Kalau tidak ada field 'nama', lookup ke koleksi 'users' via UID
                    // UID bisa dari field 'uid'/'userId'/'user_id', atau pakai doc ID
                    final String? memberUid =
                        (data['uid'] ?? data['userId'] ?? data['user_id'] ?? memberDocs[index].id)
                            as String?;

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .doc(memberUid)
                          .get(),
                      builder: (context, userSnap) {
                        if (userSnap.connectionState == ConnectionState.waiting) {
                          return const _MemberTile(name: 'Memuat...', isTeacher: false);
                        }
                        if (!userSnap.hasData || !userSnap.data!.exists) {
                          return _MemberTile(
                            name: memberUid ?? 'Tidak Diketahui',
                            isTeacher: false,
                          );
                        }
                        final userData =
                            userSnap.data!.data() as Map<String, dynamic>?;
                        final String name =
                            userData?['nama'] ??
                            userData?['name'] ??
                            userData?['displayName'] ??
                            'Tidak Diketahui';
                        return _MemberTile(name: name, isTeacher: false);
                      },
                    );
                  },
                ),
            ],
          );
        },
      ),

      // ── Bottom Navigation ───────────────────────────────────────────────────
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

// ─── Member Tile ──────────────────────────────────────────────────────────────
class _MemberTile extends StatelessWidget {
  final String name;
  final bool isTeacher;

  const _MemberTile({required this.name, this.isTeacher = false});

  @override
  Widget build(BuildContext context) {
    // Membuat inisial huruf dari nama secara dinamis
    String initials = '';
    if (name.trim().isNotEmpty) {
      final parts = name.trim().split(' ');
      if (parts.length > 1) {
        initials = (parts[0][0] + parts[1][0]).toUpperCase();
      } else if (parts[0].isNotEmpty) {
        initials = parts[0][0].toUpperCase();
      }
    }

    final Color bgColor = isTeacher ? kBlue.withOpacity(0.1) : const Color(0xFFF0F4F8);
    final Color fgColor = isTeacher ? kBlue : const Color(0xFF5A7080);

    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(11),
          ),
          alignment: Alignment.center,
          child: Text(
            initials.isNotEmpty ? initials : '?',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: fgColor,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A2D3D),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Section Label ────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  final int count;

  const _SectionLabel({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFF8FA3B0),
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFFEDF2F5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFF5A7080),
            ),
          ),
        ),
      ],
    );
  }
}