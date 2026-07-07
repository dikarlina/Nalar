import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:our_app/profile_admin.dart';

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

      print("TOTAL USER     : $totalPengguna");
      print("PENGGUNA AKTIF : $penggunaAktif");
      print("LOGIN 30 HARI  : $login30Hari");
      print("TOTAL KELAS    : $totalKelas");
      print("JUMLAH SPOTS = ${growthSpots.length}");
      print(growthLabels);

      setState(() {});
    } catch (e) {
      print("DASHBOARD ERROR: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFFEAF3F7),

        /// DRAWER
        drawer: AdminDrawer(refreshDashboard: loadAdminData),

        /// HEADER
        appBar: AppBar(
          backgroundColor: const Color(0xFF3A7CA5),
          elevation: 0,
          titleSpacing: 16,
          iconTheme: const IconThemeData(color: Colors.white),

          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Selamat pagi,",
                style: TextStyle(fontSize: 12, color: Colors.white),
              ),
              Text(
                adminName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                adminRole == "admin" ? "Super Admin" : adminRole,
                style: const TextStyle(fontSize: 10, color: Colors.white70),
              ),
            ],
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
                  ),

                  StatCard(
                    icon: Icons.person,
                    value: penggunaAktif.toString(),
                    title: "Pengguna Aktif",
                    percent: "aktif dalam 30 hari",
                    isPositive: true,
                  ),

                  StatCard(
                    icon: Icons.layers,
                    value: totalKelas.toString(),
                    title: "Total Kelas",
                    percent: "kelas tersedia",
                    isPositive: true,
                  ),

                  StatCard(
                    icon: Icons.login,
                    value: login30Hari.toString(),
                    title: "Login 30 Hari",
                    percent: "login dalam 30 hari",
                    isPositive: true,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              /// CHART
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF3F7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Pertumbuhan Pengguna (30 Hari Terakhir)",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Juli 2026",
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      totalPengguna.toString(),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      "total pengguna terdaftar",
                      style: TextStyle(fontSize: 11, color: Colors.black54),
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
                                      style: const TextStyle(fontSize: 9),
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
class AdminDrawer extends StatelessWidget {
  final VoidCallback refreshDashboard;

  const AdminDrawer({super.key, required this.refreshDashboard});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            /// HEADER
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                "NALAR",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: Color(0xFF3A7CA5),
                ),
              ),
            ),

            const Divider(),

            /// MENU
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  /// ACTIVE
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF9FB7C3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.home),
                      title: const Text("Beranda"),
                      onTap: () {},
                    ),
                  ),

                  const SizedBox(height: 10),

                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text("User Profile"),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProfileAdmin()),
                      );

                      refreshDashboard();
                    },
                  ),
                ],
              ),
            ),

            const Spacer(),

            /// LOGOUT
            Padding(
              padding: const EdgeInsets.all(12),
              child: ListTile(
                leading: const Icon(Icons.logout),
                title: const Text("Keluar"),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
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

  const StatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.title,
    required this.percent,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF9FB7C3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(title, style: const TextStyle(fontSize: 11)),
          const SizedBox(height: 4),
          Text(
            percent,
            style: TextStyle(
              fontSize: 10,
              color: isPositive ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
