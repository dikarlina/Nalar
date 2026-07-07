import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileAdmin extends StatefulWidget {
  const ProfileAdmin({super.key});

  @override
  State<ProfileAdmin> createState() => _ProfileAdminState();
}

class _ProfileAdminState extends State<ProfileAdmin> {
  String adminName = "Loading...";
  String adminEmail = "Loading...";
  String adminRole = "Loading...";

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (doc.exists) {
        setState(() {
          adminName = doc['nama'] ?? '-';
          adminEmail = doc['email'] ?? '-';
          adminRole = doc['role'] ?? '-';
        });
      }
    } catch (e) {
      print("PROFILE ERROR : $e");
    }
  }
    Future<void> editNama() async {
  final controller = TextEditingController(text: adminName);

  final result = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Ubah Nama"),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(
          hintText: "Masukkan nama baru",
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Batal"),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(
              context,
              controller.text.trim(),
            );
          },
          child: const Text("Simpan"),
        ),
      ],
    ),
  );

  if (result == null || result.isEmpty) return;

  try {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({
      'nama': result,
    });

    setState(() {
      adminName = result;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Nama berhasil diperbarui"),
      ),
    );
  } catch (e) {
    print(e);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF3F7),

      /// HEADER
      appBar: AppBar(
        backgroundColor: const Color(0xFF3A7CA5),
        elevation: 0,
        title: const Text(
          "NALAR",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
      ),

      /// BODY
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),

            /// PROFILE ICON
            Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                color: Color(0xFF9FB7C3),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, size: 40),
            ),

            const SizedBox(height: 12),

            /// NAME
            Text(
              adminName,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),

            const SizedBox(height: 30),

            /// USERNAME LABEL
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Username", style: TextStyle(fontSize: 12)),
            ),

            const SizedBox(height: 8),

            /// USERNAME FIELD
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 45,
              decoration: BoxDecoration(
                color: const Color(0xFF9FB7C3),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      adminName,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  IconButton(
  onPressed: editNama,
  icon: const Icon(
    Icons.edit,
    size: 18,
  ),
),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// EMAIL LABEL
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Email", style: TextStyle(fontSize: 12)),
            ),

            const SizedBox(height: 8),

            /// EMAIL FIELD
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 45,
              decoration: BoxDecoration(
                color: const Color(0xFF9FB7C3),
                borderRadius: BorderRadius.circular(25),
              ),
              alignment: Alignment.centerLeft,
              child: Text(
                adminEmail,
                style: TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
