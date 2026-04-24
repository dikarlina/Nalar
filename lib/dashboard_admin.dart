import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:our_app/profile_admin.dart';

class DashboardAdmin extends StatelessWidget {
  const DashboardAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFFEAF3F7),

        /// DRAWER
        drawer: const AdminDrawer(),

        /// HEADER
        appBar: AppBar(
          backgroundColor: const Color(0xFF3A7CA5),
          elevation: 0,
          titleSpacing: 16,
          iconTheme: const IconThemeData(color: Colors.white),

          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Selamat pagi,",
                style: TextStyle(fontSize: 12, color: Colors.white),
              ),
              Text(
                "Dinda Karlina",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                "Super Admin",
                style: TextStyle(fontSize: 10, color: Colors.white70),
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
                children: const [
                  StatCard(
                    icon: Icons.group,
                    value: "1.410",
                    title: "Total Pengguna",
                    percent: "+12% bulan ini",
                    isPositive: true,
                  ),
                  StatCard(
                    icon: Icons.person,
                    value: "803",
                    title: "Pengguna Aktif",
                    percent: "+8% bulan ini",
                    isPositive: true,
                  ),
                  StatCard(
                    icon: Icons.layers,
                    value: "254",
                    title: "Kelas Aktif",
                    percent: "+5% bulan ini",
                    isPositive: true,
                  ),
                  StatCard(
                    icon: Icons.error,
                    value: "21",
                    title: "Laporan Masalah",
                    percent: "+2 belum ditangani",
                    isPositive: false,
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
                      "Aktivitas Login (1 bulan)",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text("Desember", style: TextStyle(fontSize: 12)),
                    const SizedBox(height: 4),
                    const Text(
                      "12",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
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
                                getTitlesWidget: (value, meta) {
                                  switch (value.toInt()) {
                                    case 0:
                                      return const Text(
                                        "week 1",
                                        style: TextStyle(fontSize: 10),
                                      );
                                    case 3:
                                      return const Text(
                                        "week 2",
                                        style: TextStyle(fontSize: 10),
                                      );
                                    case 6:
                                      return const Text(
                                        "week 3",
                                        style: TextStyle(fontSize: 10),
                                      );
                                  }
                                  return const SizedBox();
                                },
                              ),
                            ),
                          ),
                          lineBarsData: [
                            LineChartBarData(
                              isCurved: true,
                              color: const Color(0xFF2ECC71),
                              barWidth: 3,
                              dotData: FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color: const Color(
                                  0xFF2ECC71,
                                ).withOpacity(0.15),
                              ),
                              spots: const [
                                FlSpot(0, 70),
                                FlSpot(1, 65),
                                FlSpot(2, 68),
                                FlSpot(3, 50),
                                FlSpot(4, 45),
                                FlSpot(5, 55),
                                FlSpot(6, 40),
                              ],
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
  const AdminDrawer({super.key});

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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProfileAdmin()),
                      );
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
