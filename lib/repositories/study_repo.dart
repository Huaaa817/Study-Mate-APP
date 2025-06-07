import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class StudyRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 將使用者本次專注的秒數加總到今日的紀錄
  Future<void> addStudyDuration(String userId, int seconds) async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final docRef = _firestore
        .collection('apps/study_mate/users')
        .doc(userId)
        .collection('study_logs')
        .doc(today);

    await _firestore.runTransaction((tx) async {
      final snapshot = await tx.get(docRef);
      final currentSeconds = snapshot.exists ? snapshot['seconds'] as int : 0;
      tx.set(docRef, {
        'seconds': currentSeconds + seconds,
      }, SetOptions(merge: true));
    });
  }

  /// 讀取最近 7 天的每日累積秒數（key = yyyy-MM-dd, value = 秒數）
  Future<Map<String, int>> getDailyStudyLog(String userId) async {
    final snapshot =
        await _firestore
            .collection('apps/study_mate/users')
            .doc(userId)
            .collection('study_logs')
            .orderBy(FieldPath.documentId, descending: true)
            .limit(7)
            .get();

    return {
      for (var doc in snapshot.docs)
        doc.id: (doc.data()['seconds'] ?? 0) as int,
    };
  }

  Future<Map<String, int>> fetchLogByDate(String userId, String date) async {
    final doc = await _firestore
      .collection('apps/study_mate/users')
      .doc(userId)
      .collection('study_logs')
      .doc(date)
      .get();

    if (!doc.exists) return {};

    final data = doc.data()!;
    return {
      'seconds': data['seconds'] as int? ?? 0,
      'mood': data['mood'] as int? ?? 0,
      'feed': data['feed'] as int? ?? 0,
    };
  }


}
