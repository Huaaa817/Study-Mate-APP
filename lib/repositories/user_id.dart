// import 'package:cloud_firestore/cloud_firestore.dart';

// class UserRepository {
//   final FirebaseFirestore _firestore;

//   UserRepository({FirebaseFirestore? firestore})
//     : _firestore = firestore ?? FirebaseFirestore.instance;

//   /// 回傳 true 表示是新使用者（需要進入 generate_page）
//   /// 回傳 false 表示是舊使用者（可直接進入 home_page）
//   Future<bool> checkAndCreateUserIfNotExists(String userId) async {
//     final userRef = _firestore.collection('users').doc(userId);
//     final doc = await userRef.get();

//     if (!doc.exists) {
//       // 預設使用者資料，將由 generate_page 來填寫補全
//       await userRef.set({
//         'createdAt': FieldValue.serverTimestamp(),
//         'personality': '',
//         'hairLength': '',
//         'skinColor': '',
//       });
//       return true; // 是新使用者
//     }
//     return false; // 舊使用者
//   }

//   /// 儲存使用者的個人設定（從 generate_page 傳入）
//   Future<void> updateUserProfile({
//     required String userId,
//     required String personality,
//     required String hairLength,
//     required String skinColor,
//   }) async {
//     final userRef = _firestore.collection('users').doc(userId);
//     await userRef.update({
//       'personality': personality,
//       'hairLength': hairLength,
//       'skinColor': skinColor,
//     });
//   }

//   /// 取得使用者設定資料（可用於後續顯示）
//   Future<Map<String, dynamic>?> getUserProfile(String userId) async {
//     final doc = await _firestore.collection('users').doc(userId).get();
//     return doc.data();
//   }
// }import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:convert';

class UserRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  UserRepository({FirebaseFirestore? firestore, FirebaseStorage? storage})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _storage = storage ?? FirebaseStorage.instance;

  Future<bool> checkAndCreateUserIfNotExists(String userId) async {
    final userRef = _firestore.collection('users').doc(userId);
    final doc = await userRef.get();

    if (!doc.exists) {
      await userRef.set({
        'createdAt': FieldValue.serverTimestamp(),
        'personality': '',
        'hairLength': '',
        'skinColor': '',
        'imageUrl': '', // 改成儲存下載連結
      });
      return true;
    }
    return false;
  }

  Future<void> updateUserProfile({
    required String userId,
    required String personality,
    required String hairLength,
    required String skinColor,
  }) async {
    final userRef = _firestore.collection('users').doc(userId);
    await userRef.update({
      'personality': personality,
      'hairLength': hairLength,
      'skinColor': skinColor,
    });
  }

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    return doc.data();
  }

  /// ✅ 新版：將 base64 圖片存到 Firebase Storage，再把下載連結存在 Firestore
  Future<void> saveUserImage(String userId, String base64Image) async {
    try {
      final cleanBase64 =
          base64Image.contains(',') ? base64Image.split(',').last : base64Image;
      final imageData = base64Decode(cleanBase64);
      final ref = _storage.ref().child('users/$userId/image.png');

      final metadata = SettableMetadata(contentType: 'image/png');

      await ref.putData(imageData, metadata);
      final downloadUrl = await ref.getDownloadURL();

      final userRef = _firestore.collection('users').doc(userId);
      await userRef.set({'imageUrl': downloadUrl}, SetOptions(merge: true));

      print('✅ 成功儲存圖片並更新 Firestore imageUrl');
    } catch (e) {
      print('❌ 儲存圖片到 Storage 或更新 Firestore 失敗: $e');
      throw Exception('儲存圖片失敗: $e');
    }
  }

  /// ✅ 新版：從 Firestore 讀取 image URL
  Future<String?> getUserImage(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    return doc.data()?['imageUrl'] as String?;
  }
}
