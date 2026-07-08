import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ProfileAdmin extends StatefulWidget {
  const ProfileAdmin({super.key});

  @override
  State<ProfileAdmin> createState() => _ProfileAdminState();
}

class _ProfileAdminState extends State<ProfileAdmin> {
  String adminName = "Loading...";
  String adminEmail = "Loading...";
  String adminRole = "Loading...";
  bool statusAktif = false;
  String joinedLabel = "-";

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
        final data = doc.data() as Map<String, dynamic>;

        String formattedJoined = "-";
        if (data['createdAt'] != null && data['createdAt'] is Timestamp) {
          final createdAt = (data['createdAt'] as Timestamp).toDate();
          formattedJoined = DateFormat('d MMM yyyy').format(createdAt);
        }

        setState(() {
          adminName = data['nama'] ?? '-';
          adminEmail = data['email'] ?? '-';
          adminRole = data['role'] ?? '-';
          statusAktif = data['statusAktif'] == true;
          joinedLabel = formattedJoined;
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Ubah Nama",
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: "Masukkan nama baru",
            filled: true,
            fillColor: const Color(0xFFF7F9FB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF327CA0), width: 1.5),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(color: Color(0xFF8FA3B0))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF327CA0),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(context, controller.text.trim());
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
        SnackBar(
          content: const Text("Nama berhasil diperbarui"),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: const Color(0xFF327CA0),
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),

      /// HEADER
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black12,
        scrolledUnderElevation: 1,
        iconTheme: const IconThemeData(color: Color(0xFF327CA0)),
        title: const Text(
          "Profil Admin",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A2D3D),
            fontSize: 16,
          ),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFEEF2F5)),
        ),
      ),

      /// BODY
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 6),

            /// PROFILE ICON + NAME
            Center(
              child: Column(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: const Color(0xFF327CA0).withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF327CA0).withOpacity(0.25),
                        width: 2,
                      ),
                    ),
                    child: const Icon(Icons.person, size: 40, color: Color(0xFF327CA0)),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    adminName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A2D3D),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    adminRole == "admin" ? "Super Admin" : adminRole,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF8FA3B0)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// INFO CARDS: Status & Bergabung Sejak
            Row(
              children: [
                Expanded(
                  child: _InfoCard(
                    icon: statusAktif ? Icons.check_circle : Icons.remove_circle_outline,
                    value: statusAktif ? "Aktif" : "Nonaktif",
                    title: "Status Akun",
                    accentColor: statusAktif ? const Color(0xFF2ECC71) : const Color(0xFFE05252),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InfoCard(
                    icon: Icons.calendar_today,
                    value: joinedLabel,
                    title: "Bergabung Sejak",
                    accentColor: const Color(0xFF327CA0),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            /// USERNAME LABEL
            const Text(
              "Username",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF8FA3B0),
              ),
            ),
            const SizedBox(height: 8),

            /// USERNAME FIELD
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      adminName,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF1A2D3D)),
                    ),
                  ),
                  IconButton(
                    onPressed: editNama,
                    icon: const Icon(Icons.edit, size: 18, color: Color(0xFF327CA0)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// EMAIL LABEL
            const Text(
              "Email",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF8FA3B0),
              ),
            ),
            const SizedBox(height: 8),

            /// EMAIL FIELD
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              alignment: Alignment.centerLeft,
              child: Text(
                adminEmail,
                style: const TextStyle(fontSize: 13, color: Color(0xFF1A2D3D)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ================= INFO CARD =================
/// Mengikuti gaya StatCard/_ClassCard di home_screen & dashboard_admin:
/// card putih dengan shadow tipis, ikon dalam kotak translucent,
/// nilai besar/bold, label kecil muted di bawahnya.
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String title;
  final Color accentColor;

  const _InfoCard({
    required this.icon,
    required this.value,
    required this.title,
    required this.accentColor,
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
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A2D3D),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: Color(0xFF8FA3B0)),
          ),
        ],
      ),
    );
  }
}