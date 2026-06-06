import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ForumKelasScreen extends StatefulWidget {
  final String classId;
  final String className;
  final String section;
  final String subject;
  final String room;

  const ForumKelasScreen({
    super.key,
    required this.classId,
    required this.className,
    required this.section,
    required this.subject,
    required this.room,
  });

  @override
  State<ForumKelasScreen> createState() => _ForumKelasScreenState();
}

class _ForumKelasScreenState extends State<ForumKelasScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final Color teal = const Color(0xFF2E7D8C);

  CollectionReference get messagesRef => FirebaseFirestore.instance
      .collection('classes')
      .doc(widget.classId)
      .collection('messages');

  void sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    await messagesRef.add({
      'sender': 'Me',
      'text': text,
      'time': DateTime.now().toString(),
      'isMe': true,
    });

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.className)),

      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: messagesRef.orderBy('time').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;

                    final isMe = data['isMe'] ?? false;

                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isMe ? teal : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!isMe)
                              Text(
                                data['sender'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            Text(
                              data['text'],
                              style: TextStyle(
                                color: isMe ? Colors.white : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(hintText: 'Type message'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: sendMessage,
                  color: teal,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
