import 'package:flutter/material.dart';
import 'dart:math';
import 'isi_kelas.dart';
import 'daftar_tugas.dart';
import 'forum_kelas.dart';

const Color kBlue = Color(0xFF327BA1);

// ─── Warna internal ───────────────────────────────────────
const Color _teal = Color(0xFF327BA1);
const Color _tealLight = Color(0xFF3D9BAD);
const Color _tealBg = Color(0xFFEAF4F6);
const Color _accent = Color(0xFFF4A33D);
const Color _accentSoft = Color(0xFFFEF3E2);
const Color _green = Color(0xFF2E7A4F);
const Color _greenBg = Color(0xFFE8F5EE);
const Color _bgColor = Color(0xFFF2F7F8);

// ─── Screen utama ─────────────────────────────────────────
class ProgresSiswaScreen extends StatefulWidget {
  const ProgresSiswaScreen({super.key});

  @override
  State<ProgresSiswaScreen> createState() => _ProgresSiswaScreenState();
}

class _ProgresSiswaScreenState extends State<ProgresSiswaScreen> {
  int _selectedIndex = 2;
  int _selectedTab = 0; // 0 = Materi, 1 = Tugas

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
    {
      'name': 'Turunan Fungsi Trigonometri',
      'sub': 'Terakhir dibuka kemarin · 60% selesai',
      'status': 'partial',
    },
    {'name': 'Integral Dasar', 'sub': 'Belum dibuka', 'status': 'undone'},
  ];

  final List<Map<String, dynamic>> tugasList = [
    {
      'name': 'Latihan Limit Fungsi',
      'sub': 'Dikumpul 5 Apr · Nilai: 90/100',
      'status': 'done',
      'badge': '90',
    },
    {
      'name': 'Kuis Bab 1',
      'sub': 'Dikumpul 2 Apr · Nilai: 78/100',
      'status': 'done',
      'badge': '78',
    },
    {
      'name': 'Soal Integral Dasar',
      'sub': 'Belum dikumpul · Deadline 14 Apr',
      'status': 'partial',
      'badge': 'Pending',
    },
  ];

  void _onItemTapped(int index) {
    if (index == 2) {
      setState(() => _selectedIndex = 2);
      return;
    }
    setState(() => _selectedIndex = index);
    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ClassDetailsScreen()),
      );
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const DaftarTugasScreen()),
      );
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ForumKelasScreen()),
      );
    }
  }

  Widget _buildStatusIcon(String status) {
    late Color bg;
    late Color iconColor;
    late IconData icon;

    switch (status) {
      case 'done':
        bg = _greenBg;
        iconColor = _green;
        icon = Icons.check;
        break;
      case 'partial':
        bg = _accentSoft;
        iconColor = _accent;
        icon = Icons.info_outline;
        break;
      default:
        bg = const Color(0xFFF0F0F0);
        iconColor = Colors.grey;
        icon = Icons.remove_circle_outline;
    }

    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: iconColor, size: 18),
    );
  }

  Widget _buildBadge(String status, String label) {
    late Color bg;
    late Color textColor;

    switch (status) {
      case 'done':
        bg = _greenBg;
        textColor = _green;
        break;
      case 'partial':
        bg = _accentSoft;
        textColor = _accent;
        break;
      default:
        bg = const Color(0xFFF0F0F0);
        textColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item) {
    final status = item['status'] as String;
    final badge =
        item['badge'] as String? ??
        (status == 'done'
            ? 'Selesai'
            : status == 'partial'
            ? 'Sebagian'
            : 'Belum');

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: _teal.withOpacity(0.07),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            _buildStatusIcon(status),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'],
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item['sub'],
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF6B8A90),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _buildBadge(status, badge),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isActive = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? _teal : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isActive ? _teal : const Color(0xFF6B8A90),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: Column(
        children: [
          // ── HERO ──
          Container(
            color: _teal,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back + judul
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Progres Siswa',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Kalkulus · Kelas XII IPA',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Student info
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 3,
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'AR',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Andi Ramadhan',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'andi.ramadhan@siswa.sch.id',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                            Text(
                              'Bergabung 1 Maret 2026',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Score cards
                    Row(
                      children: [
                        _buildScoreCard('88%', 'Overall'),
                        const SizedBox(width: 12),
                        _buildScoreCard('90%', 'Materi'),
                        const SizedBox(width: 12),
                        _buildScoreCard('83%', 'Tugas'),
                        const SizedBox(width: 12),
                        _buildScoreCard('85', 'Rata Nilai'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── BODY ──
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ring card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: _teal.withOpacity(0.1),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: CustomPaint(
                            painter: _RingPainter(
                              progress: 0.88,
                              trackColor: _tealBg,
                              progressColor: _teal,
                            ),
                            child: const Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '88%',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                      color: _teal,
                                    ),
                                  ),
                                  Text(
                                    'progres',
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: Color(0xFF6B8A90),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Perkembangan Baik 🎉',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Andi telah menyelesaikan sebagian besar materi dan tugas. Perlu perhatian lebih di materi Integral.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B8A90),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tabs
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(color: _tealBg, width: 2),
                      ),
                    ),
                    child: Row(
                      children: [_buildTab('Materi', 0), _buildTab('Tugas', 1)],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Tab content
                  if (_selectedTab == 0)
                    ...materiList.map(_buildItemCard)
                  else
                    ...tugasList.map(_buildItemCard),
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
        backgroundColor: Colors.white,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            activeIcon: Icon(Icons.menu_book),
            label: 'Material',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: 'Assignment',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Members',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none_outlined),
            activeIcon: Icon(Icons.notifications),
            label: 'Meetings',
          ),
        ],
      ),
    );
  }
}

// ─── Custom painter untuk progress ring ───────────────────
class _RingPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;

  _RingPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 10) / 2;
    const strokeWidth = 10.0;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    final sweepAngle = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
