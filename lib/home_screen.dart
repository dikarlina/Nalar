import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_screen.dart';
import 'isi_kelas.dart';
import 'create_class_form.dart';
import 'join_class.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedMenu = "beranda";
  final String? currentUid = FirebaseAuth.instance.currentUser?.uid;

  Color getColor(String title) {
    final colors = [
      const Color(0xFF327CA0),
      const Color(0xFF327CA0),
      const Color(0xFF327CA0),
      const Color(0xFF327CA0),
    ];
    return colors[title.length % colors.length];
  }

  IconData getIcon(int index) {
    final icons = [
      Icons.calculate,
      Icons.science,
      Icons.biotech,
      Icons.functions,
    ];
    return icons[index % icons.length];
  }

  @override
  Widget build(BuildContext context) {
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

      // ================= FAB: create + join =================
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // join class
          FloatingActionButton.small(
            heroTag: "join",
            backgroundColor: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const JoinClassScreen()),
              );
            },
            child: const Icon(Icons.login, color: Color(0xFF327CA0)),
          ),
          const SizedBox(height: 8),
          // create class
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF327CA0), width: 2.5),
            ),
            child: IconButton(
              icon: const Icon(Icons.add, color: Color(0xFF327CA0), size: 30),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateClassForm()),
                );
              },
            ),
          ),
        ],
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
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Beranda"),
              selected: selectedMenu == "beranda",
              selectedColor: const Color(0xFF327CA0),
              onTap: () {
                setState(() => selectedMenu = "beranda");
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text("Join Kelas"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const JoinClassScreen()),
                );
              },
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Keluar'),
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const AuthScreen()),
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

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                // tampilkan kelas yang dibuat user ATAU kelas yang di-join user
                stream: FirebaseFirestore.instance
                    .collection('classes')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("Belum ada kelas"));
                  }

                  // filter: hanya tampilkan kelas yang dibuat atau di-join user
                  final allClasses = snapshot.data!.docs;

                  return FutureBuilder<List<QueryDocumentSnapshot>>(
                    future: _filterMyClasses(allClasses),
                    builder: (context, filtered) {
                      if (!filtered.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final classes = filtered.data!;

                      if (classes.isEmpty) {
                        return const Center(
                          child: Text(
                            "Belum ada kelas.\nBuat kelas baru atau join dengan kode!",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: classes.length,
                        itemBuilder: (context, index) {
                          final data = classes[index].data() as Map<String, dynamic>;

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ClassDetailsScreen(
                                    classId: classes[index].id,
                                    className: data['className'] ?? '',
                                    section: data['section'] ?? '',
                                    subject: data['subject'] ?? '',
                                    room: data['room'] ?? '',
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 20),
                              height: 130,
                              decoration: BoxDecoration(
                                color: getColor(data['className'] ?? ''),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          data['className'] ?? 'No Name',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        // tampilkan kode kelas
                                        if (data['classCode'] != null)
                                          Text(
                                            "Kode: ${data['classCode']}",
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 13,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
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
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // filter kelas: yang dibuat sendiri ATAU sudah join
  Future<List<QueryDocumentSnapshot>> _filterMyClasses(
    List<QueryDocumentSnapshot> allClasses,
  ) async {
    final result = <QueryDocumentSnapshot>[];

    for (final doc in allClasses) {
      final data = doc.data() as Map<String, dynamic>;

      // kelas yang dibuat sendiri
      if (data['createdBy'] == currentUid) {
        result.add(doc);
        continue;
      }

      // kelas yang sudah di-join
      final memberDoc = await doc.reference
          .collection('members')
          .doc(currentUid)
          .get();

      if (memberDoc.exists) {
        result.add(doc);
      }
    }

    return result;
  }
}