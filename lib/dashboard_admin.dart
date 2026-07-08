import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:our_app/profile_admin.dart';
import 'auth_screen.dart';

class DashboardAdmin extends StatefulWidget {
  const DashboardAdmin({super.key});

  @override
  State<DashboardAdmin> createState() => _DashboardAdminState();
}

class _DashboardAdminState extends State<DashboardAdmin> {
  int totalPengguna = 0;
  int penggunaAktif = 0;
  int login30Hari = 0;
  int totalKelas = 0;
  String adminName = "Loading...";
  String adminRole = "Loading...";

  List<FlSpot> growthSpots = [];
  List<String> growthLabels = [];

  @override
  void initState() {
    super.initState();
    loadAdminData();
    loadDashboardData();
  }

  // ── Sapaan kondisional berdasarkan jam saat ini ──
  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 11) return "Selamat Pagi,";
    if (hour >= 11 && hour < 15) return "Selamat Siang,";
    if (hour >= 15 && hour < 19) return "Selamat Sore,";
    return "Selamat Malam,";
  }

  Future<void> loadAdminData() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (doc.exists) {
        setState(() {
          adminName = doc['nama'] ?? 'Admin';
          adminRole = doc['role'] ?? 'admin';
        });
      }
    } catch (e) {
      print("ADMIN DATA ERROR: $e");
    }
  }

  Future<void> loadDashboardData() async {
    try {
      // ================= USERS =================
      final usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .get();

      totalPengguna = usersSnapshot.docs.length;

      penggunaAktif = usersSnapshot.docs.where((doc) {
        final data = doc.data();

        return data.containsKey('statusAktif') && data['statusAktif'] == true;
      }).length;

      // Login dalam 30 hari terakhir
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

      login30Hari = usersSnapshot.docs.where((doc) {
        final data = doc.data();

        if (!data.containsKey('lastLogin')) {
          return false;
        }

        final lastLogin = data['lastLogin'];

        if (lastLogin is! Timestamp) {
          return false;
        }

        return lastLogin.toDate().isAfter(thirtyDaysAgo);
      }).length;

      growthSpots.clear();
      growthLabels.clear();

      Map<String, int> userGrowthMap = {};
      int cumulativeUsers = 0;

      List<QueryDocumentSnapshot<Map<String, dynamic>>> sortedUsers = List.from(
        usersSnapshot.docs,
      );

      sortedUsers.sort((a, b) {
        Timestamp aCreated = a.data()['createdAt'];
        Timestamp bCreated = b.data()['createdAt'];

        return aCreated.compareTo(bCreated);
      });
      for (var doc in sortedUsers) {
        final data = doc.data();

        if (data['createdAt'] != null) {
          Timestamp createdAt = data['createdAt'];

          String dateLabel = DateFormat('d MMM').format(createdAt.toDate());

          cumulativeUsers++;

          // simpan total user terakhir pada tanggal tersebut
          userGrowthMap[dateLabel] = cumulativeUsers;
        }
      }
      int index = 0;

      userGrowthMap.forEach((date, totalUser) {
        growthSpots.add(FlSpot(index.toDouble(), totalUser.toDouble()));

        growthLabels.add(date);

        index++;
      });
      // ================= CLASSES =================
      final classesSnapshot = await FirebaseFirestore.instance
          .collection('classes')
          .get();

      totalKelas = classesSnapshot.docs.length;

      setState(() {});
    } catch (e) {
      print("DASHBOARD ERROR: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F9FB),

        /// DRAWER
        drawer: AdminDrawer(adminName: adminName, refreshDashboard: loadAdminData),

        /// HEADER
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.black12,
          scrolledUnderElevation: 1,
          titleSpacing: 16,
          iconTheme: const IconThemeData(color: Color(0xFF327CA0)),

          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _greeting,
                style: const TextStyle(fontSize: 12, color: Color(0xFF8FA3B0)),
              ),
              Text(
                adminName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A2D3D),
                ),
              ),
              Text(
                adminRole == "admin" ? "Super Admin" : adminRole,
                style: const TextStyle(fontSize: 10, color: Color(0xFF8FA3B0)),
              ),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: const Color(0xFFEEF2F5)),
          ),
        ),

        /// BODY
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              /// GRID
              GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.1,
                ),
                children: [
                  StatCard(
                    icon: Icons.group,
                    value: totalPengguna.toString(),
                    title: "Total Pengguna",
                    percent: "${totalPengguna} akun terdaftar",
                    isPositive: true,
                    accentColor: const Color(0xFF327CA0),
                  ),

                  StatCard(
                    icon: Icons.person,
                    value: penggunaAktif.toString(),
                    title: "Pengguna Aktif",
                    percent: "aktif dalam 30 hari",
                    isPositive: true,
                    accentColor: const Color(0xFF2E86AB),
                  ),

                  StatCard(
                    icon: Icons.layers,
                    value: totalKelas.toString(),
                    title: "Total Kelas",
                    percent: "kelas tersedia",
                    isPositive: true,
                    accentColor: const Color(0xFF1A6B8A),
                  ),

                  StatCard(
                    icon: Icons.login,
                    value: login30Hari.toString(),
                    title: "Login 30 Hari",
                    percent: "login dalam 30 hari",
                    isPositive: true,
                    accentColor: const Color(0xFF3D8FA6),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              /// CHART
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Pertumbuhan Pengguna (30 Hari Terakhir)",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Color(0xFF1A2D3D),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Juli 2026",
                      style: TextStyle(fontSize: 12, color: Color(0xFF8FA3B0)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      totalPengguna.toString(),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A2D3D),
                      ),
                    ),
                    const Text(
                      "total pengguna terdaftar",
                      style: TextStyle(fontSize: 11, color: Color(0xFF8FA3B0)),
                    ),
                    const SizedBox(height: 12),

                    SizedBox(
                      height: 140,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 1,
                                reservedSize: 32,
                                getTitlesWidget: (value, meta) {
                                  final index = value.toInt();

                                  if (index < 0 ||
                                      index >= growthLabels.length) {
                                    return const SizedBox();
                                  }

                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      growthLabels[index],
                                      style: const TextStyle(
                                        fontSize: 9,
                                        color: Color(0xFF8FA3B0),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          lineBarsData: [
                            LineChartBarData(
                              spots: growthSpots.isEmpty
                                  ? [const FlSpot(0, 0)]
                                  : growthSpots,
                              isCurved: true,
                              color: const Color(0xFF2ECC71),
                              barWidth: 3,
                              dotData: FlDotData(show: true),
                              belowBarData: BarAreaData(
                                show: true,
                                color: const Color(0x262ECC71),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ================= DRAWER =================
/// Style disamakan dengan _buildDrawer() di home_screen.dart:
/// header biru dengan avatar inisial, menu list dengan _drawerItem,
/// divider tipis, dan tombol Keluar merah di bagian bawah yang
/// benar-benar sign out + kembali ke AuthScreen.
class AdminDrawer extends StatelessWidget {
  final String adminName;
  final VoidCallback refreshDashboard;

  const AdminDrawer({
    super.key,
    required this.adminName,
    required this.refreshDashboard,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
            color: const Color(0xFF327CA0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar inisial
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.35),
                      width: 2,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    adminName.isNotEmpty
                        ? adminName
                            .trim()
                            .split(' ')
                            .map((w) => w.isNotEmpty ? w[0] : '')
                            .take(2)
                            .join()
                            .toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  adminName.isNotEmpty ? adminName : 'Admin',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  FirebaseAuth.instance.currentUser?.email ?? "",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.75),
                  ),
                ),
              ],
            ),
          ),

          // ── Scrollable menu area ─────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  _drawerItem(
                    icon: Icons.home_outlined,
                    label: "Beranda",
                    selected: true,
                    onTap: () => Navigator.pop(context),
                  ),

                  const SizedBox(height: 4),

                  _drawerItem(
                    icon: Icons.person_outline,
                    label: "User Profile",
                    onTap: () async {
                      Navigator.pop(context);
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProfileAdmin()),
                      );
                      refreshDashboard();
                    },
                  ),

                  const SizedBox(height: 8),

                  // Divider
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      height: 1,
                      color: const Color(0xFFF0F4F7),
                    ),
                  ),

                  const SizedBox(height: 4),
                ],
              ),
            ),
          ),

          // ── Keluar button ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                FirebaseAuth.instance.signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const AuthScreen()),
                  (route) => false,
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red.shade400, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      "Keluar",
                      style: TextStyle(
                        color: Colors.red.shade400,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String label,
    bool selected = false,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: ListTile(
        leading: Icon(
          icon,
          color: selected ? const Color(0xFF327CA0) : Colors.grey[500],
          size: 22,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: selected ? const Color(0xFF327CA0) : Colors.grey[700],
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        selected: selected,
        selectedTileColor: const Color(0xFF327CA0).withOpacity(0.07),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: onTap,
      ),
    );
  }
}

/// ================= CARD =================
class StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String title;
  final String percent;
  final bool isPositive;
  final Color accentColor;

  const StatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.title,
    required this.percent,
    required this.isPositive,
    this.accentColor = const Color(0xFF327CA0),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: accentColor),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A2D3D),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A2D3D),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            percent,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: isPositive ? const Color(0xFF2ECC71) : const Color(0xFFE05252),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}