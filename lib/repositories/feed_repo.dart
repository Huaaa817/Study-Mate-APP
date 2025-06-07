import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class FeedRepository {
  final FirebaseFirestore _firestore;

  FeedRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> incrementFeedCount(String userId) async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final docRef = _firestore
        .collection('apps')
        .doc('study_mate')
        .collection('users')
        .doc(userId)
        .collection('study_logs')
        .doc(today);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);

      if (snapshot.exists) {
        final currentFeed = snapshot.data()?['feed'] ?? 0;
        transaction.update(docRef, {'feed': currentFeed + 1});
      } else {
        transaction.set(docRef, {
          'feed': 1,
          'mood': 2,
          'seconds': 0,
        });
      }
    });
  }
}
