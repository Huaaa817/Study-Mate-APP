import 'package:cloud_firestore/cloud_firestore.dart';

class PersonalityRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🔸 取得某位使用者的 personality 資料夾
  CollectionReference<Map<String, dynamic>> getUserPersonalityRef(
    String userId,
  ) {
    return _firestore
        .collection('apps')
        .doc('study_mate')
        .collection('users')
        .doc(userId)
        .collection('personality');
  }

  /// 🔸 新增一筆 personality 資料
  Future<void> addPersonality({
    required String userId,
    required Map<String, dynamic> personality,
  }) async {
    await getUserPersonalityRef(userId).add(personality);
  }

  /// 🔸 取得單一 personality 文件
  Future<Map<String, dynamic>?> getPersonalityById(
    String userId,
    String docId,
  ) async {
    final doc = await getUserPersonalityRef(userId).doc(docId).get();
    return doc.exists ? doc.data() : null;
  }
}
