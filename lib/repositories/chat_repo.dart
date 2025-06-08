import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  Future<String> fetchUserPersonality() async {
    final userId = currentUserId;
    if (userId == null) throw Exception("User not logged in");

    try {
      final doc = await _firestore
          .collection('apps')
          .doc('study_mate')
          .collection('users')
          .doc(userId)
          .collection('personality')
          .doc('profile')
          .get();

      if (doc.exists && doc.data()?['type'] is String) {
        return doc.data()!['type'] as String;
      }
    } catch (e) {
      print('❌ 無法取得 personality: $e');
    }

    // ➤ 預設回傳值（例如 "可愛"）
    return '可愛';
  }


  Stream<List<Map<String, dynamic>>> getMessagesStream() {
    final userId = currentUserId;
    if (userId == null) return const Stream.empty();

    final chatId = 'defaultChat';

    return _firestore
        .collection('apps')
        .doc('study_mate')
        .collection('users')
        .doc(userId)
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<void> saveMessage(Map<String, dynamic> message) async {
    final userId = currentUserId;
    if (userId == null) throw Exception("User not logged in");

    final chatId = 'defaultChat';

    final docRef = _firestore
        .collection('apps')
        .doc('study_mate')
        .collection('users')
        .doc(userId)
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc();

    await docRef.set({
      'sender': message['sender'],
      'message': message['message'],
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}

