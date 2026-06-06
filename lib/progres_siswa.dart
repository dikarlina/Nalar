import 'package:flutter/material.dart';
import 'dart:math';

import 'isi_kelas.dart';
import 'daftar_tugas.dart';
import 'forum_kelas.dart';
import 'anggota_kelas.dart';

const Color kBlue = Color(0xFF327BA1);

const Color _teal = Color(0xFF327BA1);
const Color _tealBg = Color(0xFFEAF4F6);
const Color _accent = Color(0xFFF4A33D);
const Color _accentSoft = Color(0xFFFEF3E2);
const Color _green = Color(0xFF2E7A4F);
const Color _greenBg = Color(0xFFE8F5EE);
const Color _bgColor = Color(0xFFF2F7F8);

class ProgresSiswaScreen extends StatefulWidget {
  final String classId;
  final String className;
  final String section;
  final String subject;
  final String room;

  const ProgresSiswaScreen({
    super.key,
    required this.classId,
    required this.className,
    required this.section,
    required this.subject,
    required this.room,
  });

  @override
  State<ProgresSiswaScreen> createState() => _ProgresSiswaScreenState();
}

class _ProgresSiswaScreenState extends State<ProgresSiswaScreen> {
  int _selectedIndex = 2;
  int _selectedTab = 0;

  final List<Map<String, dynamic>> materiList = [
    {
      'name': 'Pengenalan Kalkulus',
      'sub': 'Dibaca 28 Mar · 100% selesai',
      'status': 'done',
    },
    {
      'name': 'Limit Fungsi',
      'sub': 'Dibaca 3 Apr · 100% selesai',
      'status': 'done',
    },
  ];

  final List<Map<String, dynamic>> tugasList = [
    {
      'name': 'Latihan Limit Fungsi',
      'sub': 'Dikumpul 5 Apr · Nilai: 90/100',
      'status': 'done',
      'badge': '90',
    },
  ];

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

    if (index == 2) {
      setState(() => _selectedIndex = 2);

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

  Widget _buildItem(Map<String, dynamic> item) {
    final status = item['status'];

    return ListTile(
      leading: Icon(
        status == 'done' ? Icons.check_circle : Icons.info_outline,
        color: status == 'done' ? _green : _accent,
      ),
      title: Text(item['name']),
      subtitle: Text(item['sub']),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,

      appBar: AppBar(title: Text(widget.className), backgroundColor: _teal),

      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: _teal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Progres Siswa",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                Text(
                  "${widget.subject} - ${widget.section}",
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Materi",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...materiList.map(_buildItem),

                  const SizedBox(height: 20),

                  const Text(
                    "Tugas",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...tugasList.map(_buildItem),
                ],
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: kBlue,
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
