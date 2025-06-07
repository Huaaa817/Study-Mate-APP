import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app/models/mood_status.dart';

class MoodRepository {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> saveMood(MoodStatus status) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _firestore.collection('users').doc(uid).set({
      'moodStatus': status.toJson(),
    }, SetOptions(merge: true));
  }

  Future<MoodStatus?> loadMood() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    final doc = await _firestore.collection('users').doc(uid).get();
    final data = doc.data()?['moodStatus'];
    if (data != null) {
      return MoodStatus.fromJson(Map<String, dynamic>.from(data));
    }
    return null;
  }

  Future<bool> checkIfUserChattedToday() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return false;

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('messages')
        .where('sender', isEqualTo: 'user')
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('timestamp', isLessThan: Timestamp.fromDate(endOfDay))
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

}

