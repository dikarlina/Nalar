import 'package:flutter/material.dart';
import 'auth_screen.dart';
import 'isi_kelas.dart';
import 'create_class_form.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ================= STATE =================
  String selectedMenu = "beranda";

  final List<Map<String, dynamic>> classes = [
    {'title': 'Kalkulus', 'isTaught': true, 'hasTask': true},
    {'title': 'Biologi', 'isTaught': false, 'hasTask': true},
    {'title': 'Fisika', 'isTaught': true, 'hasTask': false},
    {'title': 'Aljabar', 'isTaught': false, 'hasTask': false},
  ];

  // ================= FILTER =================
  List<Map<String, dynamic>> getFilteredClasses() {
    if (selectedMenu == "beranda") {
      return classes;
    } else if (selectedMenu == "diperiksa") {
      return classes.where((c) => c['isTaught'] == true).toList();
    } else if (selectedMenu == "tugas") {
      return classes.where((c) => c['hasTask'] == true).toList();
    }
    return classes;
  }

  // ================= COLOR GENERATOR =================
  Color getColor(String title) {
    final colors = [
      Color(0xFF327CA0),
      Color(0xFF327CA0),
      Color(0xFF327CA0),
      Color(0xFF327CA0),
    ];
    return colors[title.length % colors.length];
  }

  // ================= ICON GENERATOR =================
  IconData getIcon(int index) {
    final icons = [
      Icons.calculate,
      Icons.science,
      Icons.biotech,
      Icons.functions,
    ];
    return icons[index % icons.length];
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    final filteredClasses = getFilteredClasses();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "NALAR",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF327CA0),
            letterSpacing: 2,
          ),
        ),
      ),

      // ================= FAB =================
      floatingActionButton: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: Color(0xFF327CA0), width: 2.5),
        ),
        child: IconButton(
          icon: const Icon(Icons.add, color: Color(0xFF327CA0), size: 30),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CreateClassForm()),
            );
          },
        ),
      ),

      // ================= DRAWER =================
      drawer: Drawer(
        child: Column(
          children: [
            const DrawerHeader(
              child: Center(
                child: Text(
                  "NALAR",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF327CA0),
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),

            // Beranda
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Beranda"),
              selected: selectedMenu == "beranda",
              selectedColor: const Color(0xFF327CA0),
              iconColor: Colors.black,
              onTap: () {
                setState(() => selectedMenu = "beranda");
                Navigator.pop(context);
              },
            ),

            // Mengajar
            ExpansionTile(
              leading: const Icon(Icons.people),
              title: const Text("Mengajar"),
              children: [
                ListTile(
                  title: const Text("Untuk Diperiksa"),
                  selectedColor: const Color(0xFF327CA0),
                  iconColor: Colors.black,
                  onTap: () {
                    setState(() => selectedMenu = "diperiksa");
                    Navigator.pop(context);
                  },
                ),
              ],
            ),

            // Terdaftar
            ExpansionTile(
              leading: const Icon(Icons.book),
              title: const Text("Terdaftar"),
              children: [
                ListTile(
                  title: const Text("Tugas Saya"),
                  selectedColor: const Color(0xFF327CA0),
                  iconColor: Colors.black,
                  onTap: () {
                    setState(() => selectedMenu = "tugas");
                    Navigator.pop(context);
                  },
                ),
              ],
            ),

            const Spacer(),

            ListTile(
              leading: const Icon(
                Icons.logout,
                color: Color.fromARGB(255, 184, 12, 0),
              ),
              title: const Text('Keluar'),
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const AuthScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),

      // ================= BODY =================
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Kelas Saya",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            // Search
            TextField(
              decoration: InputDecoration(
                hintText: "Search",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // LIST KELAS
            Expanded(
              child: ListView.builder(
                itemCount: filteredClasses.length,
                itemBuilder: (context, index) {
                  final item = filteredClasses[index];

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ClassDetailsScreen(),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      height: 130,
                      decoration: BoxDecoration(
                        color: getColor(item['title']),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Stack(
                        children: [
                          // Judul
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              item['title'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          // Icon kanan bawah
                          Positioned(
                            right: 20,
                            bottom: 20,
                            child: Icon(
                              getIcon(index),
                              size: 50,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
