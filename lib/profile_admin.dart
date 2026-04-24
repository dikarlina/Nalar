import 'package:flutter/material.dart';

class ProfileAdmin extends StatelessWidget {
  const ProfileAdmin({super.key});

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
            const Text(
              "Florecita Zulfa Nasifa",
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
                children: const [
                  Expanded(
                    child: Text(
                      "Florecita Zulfa Nasifa",
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                  Icon(Icons.edit, size: 18),
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
              child: const Text(
                "@florecitazulfa123",
                style: TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
