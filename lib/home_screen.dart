import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_screen.dart';
import 'isi_kelas.dart';
import 'create_class_form.dart';
import 'join_class.dart';
import 'meeting_request.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  String selectedMenu = "beranda";
  final String? currentUid = FirebaseAuth.instance.currentUser?.uid;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // User profile
  String _userName = '';

  // FAB expand state
  bool _fabExpanded = false;
  late AnimationController _fabAnimController;
  late Animation<double> _fabRotation;
  late Animation<double> _fabScale;

  // Subject icons mapped by index
  final List<IconData> _subjectIcons = [
    Icons.calculate_outlined,
    Icons.science_outlined,
    Icons.biotech_outlined,
    Icons.functions_outlined,
    Icons.history_edu_outlined,
    Icons.public_outlined,
    Icons.menu_book_outlined,
    Icons.palette_outlined,
  ];

  // Accent colors per card (subtle, not all same)
  final List<Color> _accentColors = [
    const Color(0xFF327CA0),
    const Color(0xFF2E86AB),
    const Color(0xFF1A6B8A),
    const Color(0xFF3D8FA6),
    const Color(0xFF256E8A),
    const Color(0xFF327CA0),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _fabAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _fabRotation = Tween<double>(begin: 0, end: 0.375).animate(
      CurvedAnimation(parent: _fabAnimController, curve: Curves.easeInOut),
    );
    _fabScale = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fabAnimController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _fabAnimController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    if (currentUid == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUid)
        .get();
    if (doc.exists && mounted) {
      final data = doc.data()!;
      setState(() {
        _userName = data['nama'] ?? data['name'] ?? data['displayName'] ?? '';
      });
    }
  }

  Future<void> _editNama() async {
    final controller = TextEditingController(text: _userName);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Edit Nama',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: 'Masukkan nama lengkap',
            filled: true,
            fillColor: const Color(0xFFF7F9FB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: Color(0xFF327CA0), width: 1.5),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal',
                style: TextStyle(color: Color(0xFF8FA3B0))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF327CA0),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && currentUid != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUid)
          .update({'nama': result});
      if (mounted) setState(() => _userName = result);
    }
  }

  void _toggleFab() {
    setState(() => _fabExpanded = !_fabExpanded);
    if (_fabExpanded) {
      _fabAnimController.forward();
    } else {
      _fabAnimController.reverse();
    }
  }

  void _closeFab() {
    if (_fabExpanded) {
      setState(() => _fabExpanded = false);
      _fabAnimController.reverse();
    }
  }

  Color _accentOf(int index) => _accentColors[index % _accentColors.length];
  IconData _iconOf(int index) => _subjectIcons[index % _subjectIcons.length];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _closeFab,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F9FB),
        appBar: _buildAppBar(),
        drawer: _buildDrawer(),
        body: Stack(
          children: [
            _buildBody(),
            // dim overlay when FAB is expanded
            if (_fabExpanded)
              Positioned.fill(
                child: GestureDetector(
                  onTap: _closeFab,
                  child: AnimatedOpacity(
                    opacity: _fabExpanded ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(color: Colors.black.withOpacity(0.18)),
                  ),
                ),
              ),
          ],
        ),
        floatingActionButton: _buildExpandableFab(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black12,
      scrolledUnderElevation: 1,
      title: const Text(
        "NALAR",
        style: TextStyle(
          fontWeight: FontWeight.w900,
          color: Color(0xFF327CA0),
          letterSpacing: 3,
          fontSize: 20,
        ),
      ),
      iconTheme: const IconThemeData(color: Color(0xFF327CA0)),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: const Color(0xFFEEF2F5),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
            color: const Color(0xFF327CA0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar inisial
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.35),
                      width: 2,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _userName.isNotEmpty
                        ? _userName.trim().split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                // Nama — tap untuk edit
                GestureDetector(
                  onTap: _editNama,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          _userName.isNotEmpty ? _userName : 'Tambah Nama',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _userName.isNotEmpty
                                ? Colors.white
                                : Colors.white.withOpacity(0.55),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.edit_rounded,
                        size: 13,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  FirebaseAuth.instance.currentUser?.email ?? "",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.75),
                  ),
                ),
              ],
            ),
          ),

          // ── Scrollable menu area ─────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  // Beranda
                  _drawerItem(
                    icon: Icons.home_outlined,
                    label: "Beranda",
                    selected: selectedMenu == "beranda",
                    onTap: () {
                      setState(() => selectedMenu = "beranda");
                      Navigator.pop(context);
                    },
                  ),

                  const SizedBox(height: 8),

                  // ── Kelas saya ─────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                    child: Text(
                      "KELAS SAYA",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[400],
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),

                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('classes')
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Center(
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF327CA0),
                              ),
                            ),
                          ),
                        );
                      }

                      if (!snapshot.hasData ||
                          snapshot.data!.docs.isEmpty) {
                        return _drawerEmptyClasses();
                      }

                      return FutureBuilder<List<QueryDocumentSnapshot>>(
                        future: _filterMyClasses(snapshot.data!.docs),
                        builder: (context, filtered) {
                          if (!filtered.hasData) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Center(
                                child: SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFF327CA0),
                                  ),
                                ),
                              ),
                            );
                          }

                          final classes = filtered.data!;
                          if (classes.isEmpty) return _drawerEmptyClasses();

                          return Column(
                            children: List.generate(classes.length, (i) {
                              final data = classes[i].data()
                                  as Map<String, dynamic>;
                              final isOwner =
                                  data['createdBy'] == currentUid;
                              final accentColor =
                                  _accentColors[i % _accentColors.length];

                              return Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    16, 0, 16, 4),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () {
                                    Navigator.pop(context);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ClassDetailsScreen(
                                          classId: classes[i].id,
                                          className:
                                              data['className'] ?? '',
                                          section: data['section'] ?? '',
                                          subject: data['subject'] ?? '',
                                          room: data['room'] ?? '',
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      borderRadius:
                                          BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        // Color dot
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: accentColor,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                data['className'] ??
                                                    'Tanpa Nama',
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF1A2D3D),
                                                ),
                                                maxLines: 1,
                                                overflow:
                                                    TextOverflow.ellipsis,
                                              ),
                                              if ((data['subject'] ?? '')
                                                  .isNotEmpty)
                                                Text(
                                                  data['subject'] ?? '',
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    color: Color(0xFF8FA3B0),
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        // Badge: guru / anggota
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 7, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: isOwner
                                                ? accentColor.withOpacity(0.1)
                                                : Colors.grey.shade100,
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            isOwner ? "Guru" : "Anggota",
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: isOwner
                                                  ? accentColor
                                                  : Colors.grey[500],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                          );
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 8),

                  // Divider
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      height: 1,
                      color: const Color(0xFFF0F4F7),
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Join Kelas
                  _drawerItem(
                    icon: Icons.login_outlined,
                    label: "Join Kelas",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const JoinClassScreen()),
                      );
                    },
                  ),

const SizedBox(height: 4),

// Meeting Request (Sudah diperbaiki tanda kurungnya & hapus 'const')
_drawerItem(
  icon: Icons.calendar_today_outlined,
  label: "Meeting Request",
  selected: selectedMenu == "meeting_request",
  onTap: () {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MeetingRequestScreen()), 
    );
  },
), // <-- Tanda kurung penutup _drawerItem harus rapi seperti ini

const SizedBox(height: 8),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          // ── Keluar button ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                FirebaseAuth.instance.signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const AuthScreen()),
                  (route) => false,
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 14, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red.shade400, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      "Keluar",
                      style: TextStyle(
                        color: Colors.red.shade400,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerEmptyClasses() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      child: Text(
        "Belum ada kelas",
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[400],
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String label,
    bool selected = false,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: ListTile(
        leading: Icon(
          icon,
          color: selected ? const Color(0xFF327CA0) : Colors.grey[500],
          size: 22,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: selected ? const Color(0xFF327CA0) : Colors.grey[700],
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        selected: selected,
        selectedTileColor: const Color(0xFF327CA0).withOpacity(0.07),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: onTap,
      ),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Kelas Saya",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A2D3D),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      "Kelola dan akses kelas dengan mudah",
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8FA3B0),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Search bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: "Cari kelas...",
                hintStyle: const TextStyle(
                  color: Color(0xFFB0C4CE),
                  fontSize: 14,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Color(0xFF8FA3B0),
                  size: 20,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close,
                            size: 18, color: Color(0xFF8FA3B0)),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Class list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('classes')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF327CA0),
                      strokeWidth: 2,
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState();
                }

                return FutureBuilder<List<QueryDocumentSnapshot>>(
                  future: _filterMyClasses(snapshot.data!.docs),
                  builder: (context, filtered) {
                    if (!filtered.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF327CA0),
                          strokeWidth: 2,
                        ),
                      );
                    }

                    var classes = filtered.data!;

                    // apply search filter
                    if (_searchQuery.isNotEmpty) {
                      classes = classes.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final name =
                            (data['className'] ?? '').toString().toLowerCase();
                        final subject =
                            (data['subject'] ?? '').toString().toLowerCase();
                        return name.contains(_searchQuery) ||
                            subject.contains(_searchQuery);
                      }).toList();
                    }

                    if (classes.isEmpty) {
                      return _buildEmptyState();
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.only(bottom: 100),
                      itemCount: classes.length,
                      itemBuilder: (context, index) {
                        final data =
                            classes[index].data() as Map<String, dynamic>;
                        return _ClassCard(
                          classId: classes[index].id,
                          data: data,
                          accentColor: _accentOf(index),
                          icon: _iconOf(index),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFF327CA0).withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.class_outlined,
              size: 32,
              color: Color(0xFF327CA0),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Belum ada kelas",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A2D3D),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Buat kelas baru atau join\ndengan kode dari guru kamu",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF8FA3B0),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableFab() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Mini FAB: Join kelas
        ScaleTransition(
          scale: _fabScale,
          child: _MiniFabItem(
            icon: Icons.login_outlined,
            label: "Join Kelas",
            onTap: () {
              _closeFab();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const JoinClassScreen()),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        // Mini FAB: Buat kelas
        ScaleTransition(
          scale: _fabScale,
          child: _MiniFabItem(
            icon: Icons.add_box_outlined,
            label: "Buat Kelas",
            onTap: () {
              _closeFab();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateClassForm()),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        // Main FAB
        GestureDetector(
          onTap: _toggleFab,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0xFF327CA0),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF327CA0).withOpacity(0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: RotationTransition(
              turns: _fabRotation,
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            ),
          ),
        ),
      ],
    );
  }

  Future<List<QueryDocumentSnapshot>> _filterMyClasses(
    List<QueryDocumentSnapshot> allClasses,
  ) async {
    final result = <QueryDocumentSnapshot>[];

    for (final doc in allClasses) {
      final data = doc.data() as Map<String, dynamic>;

      if (data['createdBy'] == currentUid) {
        result.add(doc);
        continue;
      }

      final memberDoc =
          await doc.reference.collection('members').doc(currentUid).get();

      if (memberDoc.exists) {
        result.add(doc);
      }
    }

    return result;
  }
}

// ─── Class Card Widget ────────────────────────────────────────────────────────

class _ClassCard extends StatefulWidget {
  final String classId;
  final Map<String, dynamic> data;
  final Color accentColor;
  final IconData icon;

  const _ClassCard({
    required this.classId,
    required this.data,
    required this.accentColor,
    required this.icon,
  });

  @override
  State<_ClassCard> createState() => _ClassCardState();
}

class _ClassCardState extends State<_ClassCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ClassDetailsScreen(
              classId: widget.classId,
              className: widget.data['className'] ?? '',
              section: widget.data['section'] ?? '',
              subject: widget.data['subject'] ?? '',
              room: widget.data['room'] ?? '',
            ),
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        transform: Matrix4.identity()..scale(_pressed ? 0.97 : 1.0),
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_pressed ? 0.03 : 0.06),
              blurRadius: _pressed ? 4 : 12,
              offset: Offset(0, _pressed ? 1 : 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Accent bar
            Container(
              width: 5,
              height: 88,
              decoration: BoxDecoration(
                color: widget.accentColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.data['className'] ?? 'Tanpa Nama',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A2D3D),
                      ),
                    ),
                    const SizedBox(height: 4),
                    if ((widget.data['subject'] ?? '').isNotEmpty)
                      Text(
                        widget.data['subject'] ?? '',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF8FA3B0),
                        ),
                      ),
                    if (widget.data['classCode'] != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: widget.accentColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "Kode: ${widget.data['classCode']}",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: widget.accentColor,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            // Icon
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: widget.accentColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(widget.icon,
                    size: 22, color: widget.accentColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Mini FAB Item ────────────────────────────────────────────────────────────

class _MiniFabItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MiniFabItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Label chip
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A2D3D),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Icon button
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFF327CA0).withOpacity(0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child:
                Icon(icon, size: 20, color: const Color(0xFF327CA0)),
          ),
        ],
      ),
    );
  }
}