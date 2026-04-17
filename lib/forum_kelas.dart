import 'package:flutter/material.dart';
import 'isi_kelas.dart';
import 'daftar_tugas.dart';
import 'anggota_kelas.dart';

class ForumKelasScreen extends StatefulWidget {
  const ForumKelasScreen({super.key});

  @override
  _ForumKelasScreenState createState() => _ForumKelasScreenState();
}

class _ForumKelasScreenState extends State<ForumKelasScreen> {
  int _selectedIndex = 3;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  static Color teal = Color(0xFF2E7D8C);

  final List<Map<String, dynamic>> messages = [
    {
      'sender': 'Andi Setiawan (creator)',
      'text':
          'Selamat siang kak, apa perbedaan mendasar antara integral tentu dengan integral tak tentu?',
      'time': '12.34',
      'isMe': false,
    },
    {
      'sender': 'Fernanda Dwi',
      'text': 'CMIIW, integral tak tentu nanti menghasilkan fungsi +C',
      'time': '13.09',
      'isMe': false,
    },
    {
      'sender': 'Me',
      'text':
          'Bener banget Fernanda! tambahan, integral tentu nantinya menghasilkan nilai luas di bawah kurva ya',
      'time': '16.17',
      'isMe': true,
    },
  ];

  void _onItemTapped(int index) {
    if (index == 3) {
      setState(() => _selectedIndex = 3);
    } else if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ClassDetailsScreen()),
      );
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
    }
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      messages.add({
        'sender': 'Me',
        'text': text,
        'time': TimeOfDay.now().format(context).replaceAll(':', '.'),
        'isMe': true,
      });
      _controller.clear();
    });
    Future.delayed(Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Column(
          children: const [
            Text(
              'Kalkulus',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
            Text(
              'Integral Tentu',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Colors.black54,
              ),
            ),
            Text(
              'Created on Oct 13, 2025, 12:29.',
              style: TextStyle(fontSize: 11, color: Colors.black38),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isMe = msg['isMe'] as bool;
                return _buildMessage(msg, isMe);
              },
            ),
          ),

          // Input bar
          Container(
            padding: EdgeInsets.fromLTRB(16, 10, 16, 6),
            color: Colors.white,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFF2F2F2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            hintText: 'Type your answer',
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      GestureDetector(
                        onTap: _sendMessage,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: teal,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.send,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Expires on Oct 20, 2025, 23:59',
                  style: TextStyle(fontSize: 11, color: Colors.black38),
                ),
                SizedBox(height: 4),
              ],
            ),
          ),
        ],
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

  Widget _buildMessage(Map<String, dynamic> msg, bool isMe) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          if (!isMe)
            Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Text(
                msg['sender'],
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: teal,
                ),
              ),
            ),
          Row(
            mainAxisAlignment: isMe
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMe)
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xFFF0F0F0),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                            bottomLeft: Radius.circular(4),
                          ),
                        ),
                        child: Text(
                          msg['text'],
                          style: TextStyle(fontSize: 13, color: Colors.black87),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        msg['time'],
                        style: TextStyle(fontSize: 11, color: Colors.black38),
                      ),
                    ],
                  ),
                )
              else
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: teal,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(4),
                          ),
                        ),
                        child: Text(
                          msg['text'],
                          style: TextStyle(fontSize: 13, color: Colors.white),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        msg['time'],
                        style: TextStyle(fontSize: 11, color: Colors.black38),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
