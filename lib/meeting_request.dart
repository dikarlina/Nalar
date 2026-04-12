import 'package:flutter/material.dart';

class MeetingRequestScreen extends StatelessWidget {
  const MeetingRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meeting Request')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pending',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            MeetingRequestItem(
              name: 'Florecita Zulfa',
              topic: 'Regression Analysis',
              date: 'Requested: Oct 20, 2025, 14:00',
              expireTime: 'Expire on 23.59',
              isPending: true,
            ),
            const SizedBox(height: 20),
            const Text(
              'Scheduled',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            MeetingRequestItem(
              name: 'Karmila Jihan',
              topic: 'Regression Analysis',
              date: 'Requested: Oct 20, 2025, 14:00',
              isPending: false,
            ),
            MeetingRequestItem(
              name: 'Dinda Karolina',
              topic: 'Regression Analysis',
              date: 'Requested: Oct 20, 2025, 14:00',
              isPending: false,
            ),
            const SizedBox(height: 20),
            const Text(
              'Completed',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            MeetingRequestItem(
              name: 'Dinda Karolina',
              topic: 'Regression Analysis',
              date: 'Requested: Oct 20, 2025, 14:00',
              isPending: false,
              isCompleted: true,
            ),
          ],
        ),
      ),
    );
  }
}

class MeetingRequestItem extends StatelessWidget {
  final String name;
  final String topic;
  final String date;
  final String? expireTime;
  final bool isPending;
  final bool isCompleted;

  const MeetingRequestItem({
    super.key,
    required this.name,
    required this.topic,
    required this.date,
    this.expireTime,
    this.isPending = false,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Topic: $topic'),
            Text(date),
            if (expireTime != null) Text(expireTime!),
          ],
        ),
        trailing: isPending
            ? ElevatedButton(
                onPressed: () {
                  // Accept action logic
                },
                child: const Text('Accept'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Corrected to backgroundColor
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              )
            : null,
        tileColor: isCompleted
            ? Colors.grey[300]
            : isPending
            ? Colors.amber[100]
            : Colors.blue[50],
      ),
    );
  }
}
