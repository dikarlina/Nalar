import 'package:flutter/material.dart';

class ClassDetailsScreen extends StatefulWidget {
  const ClassDetailsScreen({super.key});

  @override
  _ClassDetailsScreenState createState() => _ClassDetailsScreenState();
}

class _ClassDetailsScreenState extends State<ClassDetailsScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalkulus'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Logic for editing class
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              // Logic for deleting class
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Class Information Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
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
            const SizedBox(height: 20),

            // Buttons for creating material and assignment
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Navigate to create material screen
                  },
                  child: const Text('Create Material'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to create assignment screen
                  },
                  child: const Text('Create Assignment'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Assignments Section
            const Text(
              'Assignments',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: assignments.length,
                itemBuilder: (context, index) {
                  final assignment = assignments[index];
                  return ListTile(
                    leading: Icon(assignment['icon'], color: Colors.blue),
                    title: Text(assignment['title']),
                    subtitle: Text(assignment['date']),
                    trailing: const Icon(Icons.more_vert),
                    onTap: () {
                      // Logic for assignment details
                    },
                  );
                },
              ),
            ),

            // Materials Section
            const Text(
              'Materials',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: materials.length,
                itemBuilder: (context, index) {
                  final material = materials[index];
                  return ListTile(
                    leading: Icon(material['icon'], color: Colors.green),
                    title: Text(material['title']),
                    subtitle: Text(material['date']),
                    trailing: const Icon(Icons.more_vert),
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
    );
  }
}
