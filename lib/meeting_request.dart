import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MeetingRequestScreen extends StatefulWidget {
  const MeetingRequestScreen({super.key});

  @override
  State<MeetingRequestScreen> createState() => _MeetingRequestScreenState();
}

class _MeetingRequestScreenState extends State<MeetingRequestScreen> {
  final String currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

  // State untuk form request baru (Sebagai Pelajar)
  String? selectedClassId;
  String? selectedClassName;
  String? selectedTeacherId;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  final _topicController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitLoading = false;

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  // Fungsi memunculkan Modal Bottom Sheet Form Request
  void _showRequestMeetingSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Form
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFF327CA0).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.video_call_outlined, color: Color(0xFF327CA0), size: 22),
                            ),
                            const SizedBox(width: 12),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Ajukan Pertemuan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A2D3D))),
                                Text("Ajukan ke pengajar kelasmu", style: TextStyle(fontSize: 12, color: Color(0xFF8FA3B0))),
                              ],
                            )
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Dropdown Pilih Kelas
                        const Text("Pilih Kelas *", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF5A7080))),
                        const SizedBox(height: 6),
                        FutureBuilder<List<Map<String, dynamic>>>(
                          future: _fetchJoinedClasses(),
                          builder: (context, classSnapshot) {
                            if (classSnapshot.connectionState == ConnectionState.waiting) {
                              return const LinearProgressIndicator(color: Color(0xFF327CA0));
                            }
                            
                            var classes = classSnapshot.data ?? [];

                            if (classes.isEmpty) {
                              return Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                                decoration: _boxDecorationStyle(),
                                child: const Text(
                                  "Kamu belum bergabung di kelas manapun sebagai siswa",
                                  style: TextStyle(fontSize: 12, color: Color(0xFF8FA3B0), fontWeight: FontWeight.w500),
                                ),
                              );
                            }

                            return DropdownButtonFormField<String>(
                              decoration: _inputDecoration("Pilih Kelas"),
                              value: selectedClassId,
                              items: classes.map((c) {
                                return DropdownMenuItem<String>(
                                  value: c['id'],
                                  child: Text(c['name']),
                                  onTap: () {
                                    selectedClassName = c['name'];
                                    selectedTeacherId = c['createdBy'];
                                  },
                                );
                              }).toList(),
                              onChanged: (val) => setModalState(() => selectedClassId = val),
                              validator: (v) => v == null ? 'Silakan pilih kelas' : null,
                            );
                          },
                        ),
                        const SizedBox(height: 16),

                        // Input Topik Pembahasan
                        const Text("Topik Pembahasan *", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF5A7080))),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _topicController,
                          decoration: _inputDecoration("Contoh: Analisis Regresi Linear"),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Topik tidak boleh kosong' : null,
                        ),
                        const SizedBox(height: 16),

                        // Pilih Tanggal & Jam
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Tanggal *", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF5A7080))),
                                  const SizedBox(height: 6),
                                  InkWell(
                                    onTap: () async {
                                      DateTime? picked = await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime.now(),
                                        lastDate: DateTime.now().add(const Duration(days: 30)),
                                      );
                                      if (picked != null) setModalState(() => selectedDate = picked);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                                      decoration: _boxDecorationStyle(),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(selectedDate == null ? "Pilih" : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}", style: const TextStyle(fontSize: 14)),
                                          const Icon(Icons.calendar_today, size: 16, color: Color(0xFF327CA0)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Jam *", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF5A7080))),
                                  const SizedBox(height: 6),
                                  InkWell(
                                    onTap: () async {
                                      TimeOfDay? picked = await showTimePicker(
                                        context: context,
                                        initialTime: TimeOfDay.now(),
                                      );
                                      if (picked != null) setModalState(() => selectedTime = picked);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                                      decoration: _boxDecorationStyle(),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(selectedTime == null ? "Pilih" : selectedTime!.format(context), style: const TextStyle(fontSize: 14)),
                                          const Icon(Icons.access_time, size: 16, color: Color(0xFF327CA0)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),

                        // Tombol Kirim Request
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isSubmitLoading ? null : () => _submitMeetingRequest(setModalState),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF327CA0),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              elevation: 0,
                            ),
                            child: _isSubmitLoading
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                                : const Text('Send Request', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Mengambil kelas di mana user terdaftar sebagai anggota di subkoleksi 'members'
  Future<List<Map<String, dynamic>>> _fetchJoinedClasses() async {
    List<Map<String, dynamic>> classesList = [];
    try {
      var snapshot = await FirebaseFirestore.instance.collection('classes').get();

      for (var doc in snapshot.docs) {
        var data = doc.data();
        
        if (data['createdBy'] == currentUid) {
          continue;
        }

        var memberSnap = await doc.reference.collection('members').doc(currentUid).get();

        if (memberSnap.exists) {
          classesList.add({
            'id': doc.id,
            'name': data['className'] ?? 'Kelas',
            'createdBy': data['createdBy'] ?? '',
          });
        }
      }
    } catch (e) {
      print("Error fetching joined classes: $e");
    }
    return classesList;
  }

  // Submit ke Firebase Koleksi 'meeting_requests'
  Future<void> _submitMeetingRequest(StateSetter setModalState) async {
    if (!_formKey.currentState!.validate() || selectedDate == null || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lengkapi semua field termasuk Tanggal & Jam!")));
      return;
    }

    setModalState(() => _isSubmitLoading = true);

    final requestDateTime = DateTime(selectedDate!.year, selectedDate!.month, selectedDate!.day, selectedTime!.hour, selectedTime!.minute);
    final currentUserName = FirebaseAuth.instance.currentUser?.displayName ?? 'Siswa';

    try {
      await FirebaseFirestore.instance.collection('meeting_requests').add({
        'studentId': currentUid,
        'studentName': currentUserName,
        'teacherId': selectedTeacherId,
        'classId': selectedClassId,
        'className': selectedClassName,
        'topic': _topicController.text.trim(),
        'requestedAt': Timestamp.fromDate(requestDateTime),
        'expireTime': 'Valid until schedule',
        'status': 'pending',
      });

      Navigator.pop(context);
      _topicController.clear();
      setState(() {
        selectedClassId = null; selectedDate = null; selectedTime = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Request meeting berhasil dikirim!"),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal mengirim request: $e")));
    } finally {
      setModalState(() => _isSubmitLoading = false);
    }
  }

  // ⭐ FUNGSI BARU: Cek dan update otomatis meeting yang sudah lewat waktu
  Future<void> _autoCompleteExpiredMeetings(List<QueryDocumentSnapshot> docs) async {
    final now = DateTime.now();
    
    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final status = data['status'] ?? '';
      
      // Hanya proses yang statusnya 'pending' atau 'scheduled'
      if (status == 'pending' || status == 'scheduled') {
        final requestedAt = data['requestedAt'] as Timestamp?;
        
        if (requestedAt != null) {
          final meetingTime = requestedAt.toDate();
          
          // Jika waktu meeting sudah lewat, update ke 'completed'
          if (meetingTime.isBefore(now)) {
            await doc.reference.update({'status': 'completed'});
            print('✅ Meeting ${doc.id} otomatis di-completed karena sudah lewat waktu');
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A2D3D)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Meeting Request',
          style: TextStyle(color: Color(0xFF1A2D3D), fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showRequestMeetingSheet,
        backgroundColor: const Color(0xFF327CA0),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Minta Pertemuan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('meeting_requests').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF327CA0), strokeWidth: 2.5));
          }

          final allDocs = snapshot.data?.docs ?? [];
          
          // ⭐ PENTING: Panggil fungsi auto-complete sebelum filter
          // Tapi karena ini async, kita panggil tanpa menunggu (fire and forget)
          // Biar tidak nge-block UI
          _autoCompleteExpiredMeetings(allDocs);
          
          // Filter data lokal: Data akan muncul jika Kamu adalah Pelajar Pemohon ATAU Kamu adalah Pengajar Penerima
          final userDocs = allDocs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['studentId'] == currentUid || data['teacherId'] == currentUid;
          }).toList();

          // ⭐ MODIFIKASI: Setelah auto-complete, filter ulang berdasarkan status terbaru
          final pendingDocs = userDocs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['status'] == 'pending';
          }).toList();
          
          final scheduledDocs = userDocs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            // Cek juga apakah masih belum lewat waktu
            final requestedAt = data['requestedAt'] as Timestamp?;
            if (requestedAt != null) {
              final meetingTime = requestedAt.toDate();
              // Hanya tampilkan di scheduled jika waktu belum lewat
              if (meetingTime.isBefore(DateTime.now())) {
                return false; // Sembunyikan dari scheduled karena sudah lewat
              }
            }
            return data['status'] == 'scheduled';
          }).toList();
          
          final completedDocs = userDocs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            // Termasuk yang statusnya scheduled tapi sudah lewat waktu
            if (data['status'] == 'scheduled') {
              final requestedAt = data['requestedAt'] as Timestamp?;
              if (requestedAt != null) {
                final meetingTime = requestedAt.toDate();
                if (meetingTime.isBefore(DateTime.now())) {
                  return true; // Tampilkan di completed jika sudah lewat
                }
              }
            }
            return data['status'] == 'completed';
          }).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Pending Request (Masuk)', const Color(0xFFE2B93B)),
                const SizedBox(height: 12),
                if (pendingDocs.isEmpty) _buildEmptyState('Tidak ada permohonan baru masuk') else ...pendingDocs.map((doc) => _buildItem(doc, context)),
                
                const SizedBox(height: 28),
                _buildSectionHeader('Scheduled (Disetujui)', const Color(0xFF327CA0)),
                const SizedBox(height: 12),
                if (scheduledDocs.isEmpty) _buildEmptyState('Belum ada pertemuan terjadwal') else ...scheduledDocs.map((doc) => _buildItem(doc, context)),
                
                const SizedBox(height: 28),
                _buildSectionHeader('Completed (Selesai)', const Color(0xFF8FA3B0)),
                const SizedBox(height: 12),
                if (completedDocs.isEmpty) _buildEmptyState('Belum ada riwayat riil') else ...completedDocs.map((doc) => _buildItem(doc, context)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color indicatorColor) {
    return Row(
      children: [
        Container(width: 6, height: 6, decoration: BoxDecoration(color: indicatorColor, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF1A2D3D))),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE8EFF4))),
      child: Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Color(0xFF8FA3B0), fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildItem(QueryDocumentSnapshot doc, BuildContext context) {
    final data = doc.data() as Map<String, dynamic>;
    String formattedDate = 'Requested: -';
    if (data['requestedAt'] != null) {
      final DateTime dateTime = (data['requestedAt'] as Timestamp).toDate();
      formattedDate = 'Jadwal: ${dateTime.day}/${dateTime.month}/${dateTime.year} jam ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }

    // Validasi Hak Akses Tombol Aksi: Hanya bernilai true jika Kamu adalah GURU/PENGAJAR di kelas ini
    final bool isTeacherOfThisClass = (data['teacherId'] == currentUid);
    
    // Cek apakah meeting sudah lewat waktu
    final bool isExpired = (data['requestedAt'] as Timestamp?)?.toDate().isBefore(DateTime.now()) ?? false;

    return MeetingRequestItem(
      docId: doc.id,
      name: "${data['studentName']} (${data['className'] ?? 'Kelas'})",
      topic: data['topic'] ?? '-',
      date: formattedDate,
      expireTime: data['expireTime'],
      isPending: data['status'] == 'pending' && !isExpired,
      isCompleted: data['status'] == 'completed' || (data['status'] == 'scheduled' && isExpired),
      showActionButtons: isTeacherOfThisClass && !isExpired, // Sembunyikan tombol aksi jika sudah expired
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFB8CCDA), fontSize: 13),
      filled: true,
      fillColor: const Color(0xFFF7F9FB),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE8EFF4))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF327CA0), width: 1.6)),
    );
  }

  BoxDecoration _boxDecorationStyle() {
    return BoxDecoration(
      color: const Color(0xFFF7F9FB),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFE8EFF4)),
    );
  }
}

class MeetingRequestItem extends StatefulWidget {
  final String docId;
  final String name;
  final String topic;
  final String date;
  final String? expireTime;
  final bool isPending;
  final bool isCompleted;
  final bool showActionButtons;

  const MeetingRequestItem({
    super.key, 
    required this.docId, 
    required this.name, 
    required this.topic, 
    required this.date, 
    this.expireTime, 
    required this.isPending, 
    required this.isCompleted,
    required this.showActionButtons,
  });

  @override
  State<MeetingRequestItem> createState() => _MeetingRequestItemState();
}

class _MeetingRequestItemState extends State<MeetingRequestItem> {
  bool _isActionLoading = false;

  Future<void> _updateStatus(String newStatus) async {
    setState(() => _isActionLoading = true);
    try {
      await FirebaseFirestore.instance.collection('meeting_requests').doc(widget.docId).update({'status': newStatus});
    } catch (e) {
      // handle error
    } finally {
      if (mounted) setState(() => _isActionLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Color leftBarColor = const Color(0xFF327CA0);
    if (widget.isPending) leftBarColor = const Color(0xFFE2B93B);
    if (widget.isCompleted) leftBarColor = const Color(0xFFB8CCDA);

    return Container(
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE8EFF4))),
      child: Row(
        children: [
          Container(width: 5, height: 90, decoration: BoxDecoration(color: leftBarColor, borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)))),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A2D3D))),
                  const SizedBox(height: 4),
                  Text('Topic: ${widget.topic}', style: const TextStyle(fontSize: 12, color: Color(0xFF5A7080), fontWeight: FontWeight.w500)),
                  const SizedBox(height: 3),
                  Text(widget.date, style: const TextStyle(fontSize: 11, color: Color(0xFF8FA3B0))),
                ],
              ),
            ),
          ),
          
          // KONTROL AKSES: Tombol Accept dan Done hanya dirender jika showActionButtons bernilai TRUE
          if (widget.showActionButtons) ...[
            if (widget.isPending)
              Padding(
                padding: const EdgeInsets.only(right: 14),
                child: ElevatedButton(
                  onPressed: _isActionLoading ? null : () => _updateStatus('scheduled'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF327CA0),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: const Size(74, 36),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _isActionLoading 
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Accept', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                ),
              ),
            if (!widget.isPending && !widget.isCompleted)
              IconButton(
                icon: const Icon(Icons.check_circle_outline, color: Color(0xFF327CA0)),
                onPressed: _isActionLoading ? null : () => _updateStatus('completed'),
              )
          ],
        ],
      ),
    );
  }
}