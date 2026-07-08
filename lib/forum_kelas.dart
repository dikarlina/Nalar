import 'package:flutter/material.dart';
import 'constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Tambahkan import ini

import 'home_screen.dart';
import 'isi_kelas.dart';
import 'daftar_tugas.dart';
import 'anggota_kelas.dart';

// ── Transisi cepat khusus untuk pindah tab lewat bottom nav ──
// Fade tipis + durasi singkat, biar kerasa instan kayak switch tab
// pada umumnya, bukan slide penuh seperti Navigator.push biasa.
Route _tabRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (_, __, ___) => page,
    transitionDuration: const Duration(milliseconds: 160),
    reverseTransitionDuration: const Duration(milliseconds: 160),
    transitionsBuilder: (_, animation, __, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

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

  int _selectedIndex = 3;

  // Dapatkan user yang sedang login saat ini
  final User? currentUser = FirebaseAuth.instance.currentUser;

  CollectionReference get messagesRef => FirebaseFirestore.instance
      .collection('classes')
      .doc(widget.classId)
      .collection('messages');

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);

    if (index == 0) {
      Navigator.pushReplacement(context, _tabRoute(
        ClassDetailsScreen(
          classId: widget.classId, className: widget.className,
          section: widget.section, subject: widget.subject, room: widget.room,
        ),
      ));
    } else if (index == 1) {
      Navigator.pushReplacement(context, _tabRoute(
        DaftarTugasScreen(
          classId: widget.classId, className: widget.className,
          section: widget.section, subject: widget.subject, room: widget.room,
        ),
      ));
    } else if (index == 2) {
      Navigator.pushReplacement(context, _tabRoute(
        AnggotaKelasScreen(
          classId: widget.classId, className: widget.className,
          section: widget.section, subject: widget.subject, room: widget.room,
        ),
      ));
    }
  }

  void sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || currentUser == null) return;

    final String currentUid = currentUser!.uid;
    String senderName = 'Pengguna';

    try {
      // Ambil nama dari dokumen users berdasarkan UID saat ini
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUid)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        final userData = userDoc.data() as Map<String, dynamic>;
        senderName = userData['nama'] ?? 'Pengguna'; // field 'nama' dari Firebase kamu
      }
    } catch (e) {
      print("Error fetching user name: $e");
    }

    // Simpan pesan dengan senderId dan nama pengirim asli
    await messagesRef.add({
      'senderId': currentUid,
      'sender': senderName,
      'text': text,
      'time': DateTime.now().toString(),
    });

    _controller.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 1,
        shadowColor: Colors.black12,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          color: const Color(0xFF1A2D3D),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
            );
          },
        ),
        centerTitle: true,
        title: Column(
          children: [
            Text(
              widget.className,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A2D3D),
              ),
            ),
            const Text(
              'Forum Diskusi',
              style: TextStyle(fontSize: 11, color: Color(0xFF8FA3B0)),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: kBorder),
        ),
      ),
      body: Column(
        children: [
          // ── Messages List ─────────────────────────────────────────────
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: messagesRef.orderBy('time').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: kBlue),
                  );
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: kBlue.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.forum_outlined,
                              color: kBlue, size: 26),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Belum ada diskusi',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A2D3D),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Mulai diskusi dengan mengirim pesan',
                          style: TextStyle(
                              fontSize: 12, color: Color(0xFF8FA3B0)),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    
                    // PENENTUAN POSISI BUBBLE: Bandingkan senderId database dengan UID user saat ini
                    final bool isMe = (data['senderId'] == currentUser?.uid);

                    return _MessageBubble(
                      text: data['text'] ?? '',
                      sender: data['sender'] ?? 'Pengguna', 
                      time: data['time'] ?? '',
                      isMe: isMe,
                    );
                  },
                );
              },
            ),
          ),

          // ── Input Bar ─────────────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: kBorder)),
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    style: const TextStyle(
                        fontSize: 14, color: Color(0xFF1A2D3D)),
                    decoration: InputDecoration(
                      hintText: 'Tulis pesan...',
                      hintStyle: const TextStyle(
                          color: Color(0xFFB0BEC5), fontSize: 14),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      filled: true,
                      fillColor: kBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: kBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: kBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide:
                            const BorderSide(color: kBlue, width: 1.5),
                      ),
                    ),
                    onSubmitted: (_) => sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: sendMessage,
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: kBlue,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(Icons.send_rounded,
                        color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: kBorder)),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: kBlue,
          unselectedItemColor: const Color(0xFFB0BEC5),
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.class_outlined), label: 'Kelas'),
            BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), label: 'Tugas'),
            BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: 'Anggota'),
            BottomNavigationBarItem(icon: Icon(Icons.forum_outlined), label: 'Forum'),
          ],
        ),
      ),
    );
  }
}

// ─── Message Bubble ───────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  final String text;
  final String sender;
  final String time;
  final bool isMe;

  const _MessageBubble({
    required this.text,
    required this.sender,
    required this.time,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    String timeStr = '';
    try {
      final dt = DateTime.parse(time);
      timeStr =
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {}

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Menampilkan nama pengirim secara dinamis di atas bubble
            Padding(
              padding: const EdgeInsets.only(left: 4, right: 4, bottom: 4),
              child: Text(
                isMe ? "$sender (Anda)" : sender,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8FA3B0),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? kBlue : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
                border: isMe ? null : Border.all(color: kBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  color: isMe ? Colors.white : const Color(0xFF1A2D3D),
                  height: 1.4,
                ),
              ),
            ),
            if (timeStr.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 3, left: 4, right: 4),
                child: Text(
                  timeStr,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFFB0BEC5),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}