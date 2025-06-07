import 'package:cloud_firestore/cloud_firestore.dart';

class PersonalityViewModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> savePersonality({
    required String userId,
    required String personality,
  }) async {
    try {
      final docRef = _firestore
          .collection('apps')
          .doc('study_mate')
          .collection('users')
          .doc(userId)
          .collection('personality')
          .doc('profile'); // 用固定 ID 只保留一筆資料

      await docRef.set({'type': personality, 'updatedAt': Timestamp.now()});

      print('✅ Personality saved for user $userId');
    } catch (e) {
      print('❌ Failed to save personality: $e');
      rethrow;
    }
  }
}
