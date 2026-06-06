import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'isi_kelas.dart';
import 'daftar_tugas.dart';
import 'forum_kelas.dart';

const Color kBlue = Color(0xFF327BA1);

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

  CollectionReference get membersRef => FirebaseFirestore.instance
      .collection('classes')
      .doc(widget.classId)
      .collection('members');

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

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

    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.className,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: membersRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;

              return _MemberTile(
                name: data['name'] ?? '-',
                joined: data['joined'] ?? '-',
                initials: data['initials'] ?? '--',
                onTap: () {},
              );
            },
          );
        },
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: kBlue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
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

class _MemberTile extends StatelessWidget {
  final String name;
  final String joined;
  final String initials;
  final VoidCallback onTap;

  const _MemberTile({
    required this.name,
    required this.joined,
    required this.initials,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: kBlue.withOpacity(0.15),
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
                Text(
                  joined,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
