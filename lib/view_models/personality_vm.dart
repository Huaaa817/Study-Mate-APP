import 'package:cloud_firestore/cloud_firestore.dart';
import '/repositories/personality.dart';

class PersonalityViewModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final PersonalityRepository _repo = PersonalityRepository();

  /// 🔸 儲存 personality
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

  /// ✅ 取得指定 ID 的 personality
  Future<Map<String, dynamic>?> getPersonalityById({
    required String userId,
    required String docId,
  }) {
    return _repo.getPersonalityById(userId, docId);
  }
}
