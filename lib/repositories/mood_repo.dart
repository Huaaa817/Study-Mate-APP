import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app/models/mood_status.dart';
import 'package:flutter/foundation.dart';


class MoodRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  Future<void> saveMood(MoodStatus status) async {
    final userId = currentUserId;
    if (userId == null) return;

    await _firestore
      .collection('apps')
      .doc('study_mate')
      .collection('users')
      .doc(userId)
      .set({
        'moodStatus': status.toJson(),
      }, SetOptions(merge: true));

  }

  Future<MoodStatus?> loadMood() async {
    final userId = currentUserId;
    if (userId == null) return null;

    final doc = await _firestore
      .collection('apps')
      .doc('study_mate')
      .collection('users')
      .doc(userId)
      .get();

    final data = doc.data()?['moodStatus'];
    if (data != null) {
      return MoodStatus.fromJson(Map<String, dynamic>.from(data));
    }
    return null;
  }

  Future<bool> checkIfUserChattedToday() async {
    final userId = currentUserId;
    if (userId == null) 
    { 
      debugPrint('❌ 使用者尚未登入，無法判斷是否聊天');
      return false;
    }

    try {
      final snapshot = await _firestore
          .collection('apps')
          .doc('study_mate')
          .collection('users')
          .doc(userId)
          .collection('chats')
          .doc('defaultChat')
          .collection('messages')
          .where('sender', isEqualTo: 'user')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        debugPrint('Chat沒有找到使用者訊息');
        return false;
      }

      final lastMsg = snapshot.docs.first;
      final timestamp = lastMsg.data()['timestamp'] as Timestamp?;
      debugPrint('🕒 最後一則使用者訊息 timestamp: $timestamp');

      if (timestamp == null) return false;

      final msgDate = timestamp.toDate();
      final now = DateTime.now();
      debugPrint('📅 訊息時間: $msgDate，現在時間: $now');

      // 判斷是否是今天
      return msgDate.year == now.year &&
             msgDate.month == now.month &&
             msgDate.day == now.day;
    } catch (e) {
      print('Firestore query error: $e');
      return false;
    }
  }

  Future<int> getDailyStudySeconds(String userId, String date) async {

    final doc = await _firestore
        .collection('apps')
        .doc('study_mate')
        .collection('users')
        .doc(userId)
        .collection('study_logs')
        .doc(date)
        .get();

    if (!doc.exists) return 0;

    final data = doc.data();
    if (data != null && data.containsKey('seconds')) {
      return data['seconds'] as int? ?? 0;
    }
    return 0;
  }
}
