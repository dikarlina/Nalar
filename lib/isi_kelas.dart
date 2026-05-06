import 'package:flutter/material.dart';
import 'daftar_tugas.dart';
import 'anggota_kelas.dart';
import 'forum_kelas.dart';
import 'setting_kelas.dart';

class ClassDetailsScreen extends StatefulWidget {
  const ClassDetailsScreen({super.key});

  @override
  _ClassDetailsScreenState createState() => _ClassDetailsScreenState();
}

class _ClassDetailsScreenState extends State<ClassDetailsScreen> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> assignments = [
    {
      'title': 'Tugas baru: Post-test Integral Tentu',
      'date': '11 April 2026',
      'icon': Icons.assignment,
    },
    {
      'title': 'Tugas baru: Pre-test Integral Tentu',
      'date': '11 April 2026',
      'icon': Icons.assignment,
    },
  ];

  final List<Map<String, dynamic>> materials = [
    {
      'title': 'Materi baru: Integral Tentu',
      'date': '11 April 2026',
      'icon': Icons.library_books,
    },
  ];

  void _onItemTapped(int index) {
    if (index == 0) {
      setState(() {
        _selectedIndex = 0;
      });
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DaftarTugasScreen()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AnggotaKelasScreen()),
      );
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ForumKelasScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kalkulus'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              // Navigate to ClassSettingsScreen when the button is pressed
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ClassSettingsScreen(), // Navigate to the ClassSettingsScreen
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              // Logic for deleting class
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Class Information Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Created by Zahra Mufida',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  'Kalkulus',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Buttons for creating material and assignment
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Navigate to create material screen
                  },
                  child: Text('Create Material'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to create assignment screen
                  },
                  child: Text('Create Assignment'),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Assignments Section
            Text(
              'Assignments',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: assignments.length,
                itemBuilder: (context, index) {
                  final assignment = assignments[index];
                  return ListTile(
                    leading: Icon(assignment['icon'], color: Colors.blue),
                    title: Text(assignment['title']),
                    subtitle: Text(assignment['date']),
                    trailing: Icon(Icons.more_vert),
                    onTap: () {
                      // Logic for assignment details
                    },
                  );
                },
              ),
            ),

            // Materials Section
            Text(
              'Materials',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: materials.length,
                itemBuilder: (context, index) {
                  final material = materials[index];
                  return ListTile(
                    leading: Icon(material['icon'], color: Colors.green),
                    title: Text(material['title']),
                    subtitle: Text(material['date']),
                    trailing: Icon(Icons.more_vert),
                    onTap: () {
                      // Logic for material details
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.class_), label: 'Kelas'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Tugas'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Anggota'),
          BottomNavigationBarItem(
            icon: Icon(Icons.forum),
            label: 'Forum Kelas',
          ),
        ],
      ),
    );
  }
}
