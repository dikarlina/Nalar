import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  static String? get currentUid => FirebaseAuth.instance.currentUser?.uid;

  // cek apakah user adalah guru di kelas tertentu
  static Future<bool> isGuruDiKelas(String classId) async {
    final uid = currentUid;
    if (uid == null) return false;

    final doc = await FirebaseFirestore.instance
        .collection('classes')
        .doc(classId)
        .get();

    return doc.data()?['createdBy'] == uid;
  }
}