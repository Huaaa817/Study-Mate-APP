import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/models/user.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:convert';

class UserRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  //final FirebaseStorage _storage = FirebaseStorage.instance;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  UserRepository({FirebaseFirestore? firestore, FirebaseStorage? storage})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _storage = storage ?? FirebaseStorage.instance;

  Stream<User?> streamUser(String userId) {
    return _db.collection('apps/study_mate/users').doc(userId).snapshots().map((
      snapshot,
    ) {
      return snapshot.data() == null
          ? null
          : User.fromMap(snapshot.data()!, snapshot.id);
    });
  }

  Future<void> createOrUpdateUser(User user) async {
    Map<String, dynamic> userMap = user.toMap();
    await _db.collection('apps/study_mate/users').doc(user.id).set(userMap);
  }

  Future<User?> getUserByEmail(String email) async {
    QuerySnapshot querySnapshot =
        await _db
            .collection('apps/study_mate/users')
            .where('email', isEqualTo: email)
            .get();

    if (querySnapshot.docs.isEmpty) {
      return null;
    }
    return User.fromMap(
      querySnapshot.docs.first.data() as Map<String, dynamic>,
      querySnapshot.docs.first.id,
    );
  }

  // Future<void> saveUserImage(String userId, String base64Image) async {
  //   try {
  //     final cleanBase64 =
  //         base64Image.contains(',') ? base64Image.split(',').last : base64Image;
  //     final imageData = base64Decode(cleanBase64);

  //     final ref = _storage.ref().child(
  //       'apps/study_mate/users/$userId/image.png',
  //     );

  //     final metadata = SettableMetadata(contentType: 'image/png');

  //     await ref.putData(imageData, metadata);
  //     final downloadUrl = await ref.getDownloadURL();

  //     final userRef = _db.collection('apps/study_mate/users').doc(userId);
  //     await userRef.set({'imageUrl': downloadUrl}, SetOptions(merge: true));

  //     print('✅ 成功儲存圖片並更新 Firestore imageUrl');
  //   } catch (e) {
  //     print('❌ 儲存圖片到 Storage 或更新 Firestore 失敗: $e');
  //     throw Exception('儲存圖片失敗: $e');
  //   }
  // }

  Future<void> saveUserImage(String userId, String base64Image) async {
    try {
      final cleanBase64 =
          base64Image.contains(',') ? base64Image.split(',').last : base64Image;
      final imageData = base64Decode(cleanBase64);
      final ref = _storage.ref().child(
        'apps/study_mate/users/$userId/image.png',
      );

      final metadata = SettableMetadata(contentType: 'image/png');

      await ref.putData(imageData, metadata);
      final downloadUrl = await ref.getDownloadURL();

      final userRef = _firestore
          .collection('apps/study_mate/users')
          .doc(userId);
      await userRef.set({'imageUrl': downloadUrl}, SetOptions(merge: true));

      print('✅ 成功儲存圖片並更新 Firestore imageUrl');
    } catch (e) {
      print('❌ 儲存圖片到 Storage 或更新 Firestore 失敗: $e');
      throw Exception('儲存圖片失敗: $e');
    }
  }

  // Future<String?> getUserImage(String userId) async {
  //   final doc = await _db.collection('apps/study_mate/users').doc(userId).get();
  //   return doc.data()?['imageUrl'] as String?;
  // }
  /// ✅ 新版：從 Firestore 讀取 image URL
  // Future<String?> getUserImage(String userId) async {
  //   final doc =
  //       await _firestore.collection('apps/study_mate/users').doc(userId).get();
  //   return doc.data()?['imageUrl'] as String?;
  // }
  Future<String?> getUserImage(String userId) async {
    try {
      final doc =
          await _firestore
              .collection('apps/study_mate/users')
              .doc(userId)
              .get();

      if (!doc.exists) {
        print('❗ User document not found for ID: $userId');
        return null;
      }

      final data = doc.data();
      if (data == null || !data.containsKey('imageUrl')) {
        print('❗ imageUrl field missing in user document: $userId');
        return null;
      }

      return data['imageUrl'] as String?;
    } catch (e, stackTrace) {
      print('❗ Error fetching user image for $userId: $e');
      print(stackTrace); // 可選：方便除錯時追蹤來源
      return null;
    }
  }
}
