import 'package:flutter/material.dart';
import 'isi_kelas.dart';
import 'anggota_kelas.dart';
import 'forum_kelas.dart';

class DaftarTugasScreen extends StatefulWidget {
  const DaftarTugasScreen({super.key});

  @override
  _DaftarTugasScreenState createState() => _DaftarTugasScreenState();
}

class _DaftarTugasScreenState extends State<DaftarTugasScreen> {
  int _selectedIndex = 1;

  final List<Map<String, dynamic>> assignments = [
    {'title': 'Tugas baru: Post-test Integral Tentu', 'date': '11 April 2026'},
    {'title': 'Tugas baru: Pre-test Integral Tentu', 'date': '11 April 2026'},
  ];

  void _onItemTapped(int index) {
    if (index == 1) {
      setState(() {
        _selectedIndex = 1;
      });
    } else if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ClassDetailsScreen()),
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Kalkulus',
          style: TextStyle(
            color: Color(0xFF2196F3),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: assignments.isEmpty
          ? Center(
              child: Text(
                'Belum ada tugas.',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: assignments.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final assignment = assignments[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.assignment, color: Colors.grey),
                  ),
                  title: Text(
                    assignment['title'],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    assignment['date'],
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.more_vert, color: Colors.grey),
                    onPressed: () {
                      _showOptionsMenu(context, index);
                    },
                  ),
                  onTap: () {
                    // Logic untuk detail tugas
                  },
                );
              },
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 8,
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

  void _showOptionsMenu(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.edit, color: Colors.blue),
                title: Text('Edit Tugas'),
                onTap: () {
                  Navigator.pop(context);
                  // Logic edit tugas
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Hapus Tugas'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    assignments.removeAt(index);
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
