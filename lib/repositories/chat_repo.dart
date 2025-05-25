// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class ChatRepository {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   // 🔁 取得訊息串流
//   Stream<List<Map<String, dynamic>>> getMessagesStream(String userId, String chatId) {
//     return _firestore
//         .collection('apps')
//         .doc('study_mate')
//         .collection('users')
//         .doc(userId)
//         .collection('chats')
//         .doc(chatId)
//         .collection('messages')
//         .orderBy('timestamp', descending: true)
//         .snapshots()
//         .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
//   }

//   // 📨 發送訊息
//   Future<void> sendMessage({
//     required String userId,
//     required String chatId,
//     required String sender, // 'user' 或 'ai'
//     required String message,
//   }) async {
//     await _firestore
//         .collection('apps')
//         .doc('study_mate')
//         .collection('users')
//         .doc(userId)
//         .collection('chats')
//         .doc(chatId)
//         .collection('messages')
//         .add({
//       'sender': sender,
//       'message': message,
//       'timestamp': FieldValue.serverTimestamp(),
//     });
//   }
// }

// class ChatRepository {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   String get currentUserId {
//     final user = _auth.currentUser;
//     if (user == null) throw Exception('User not logged in');
//     return user.uid;
//   }

//   Stream<List<Map<String, dynamic>>> getMessagesStream(String chatId) {
//     final userId = currentUserId;
//     return _firestore
//         .collection('apps')
//         .doc('study_mate')
//         .collection('users')
//         .doc(userId)
//         .collection('chats')
//         .doc(chatId)
//         .collection('messages')
//         .orderBy('timestamp', descending: true)
//         .snapshots()
//         .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
//   }

//   Future<void> sendMessage({
//     required String chatId,
//     required String sender,
//     required String message,
//   }) async {
//     final userId = currentUserId;

//     await _firestore
//         .collection('apps')
//         .doc('study_mate')
//         .collection('users')
//         .doc(userId)
//         .collection('chats')
//         .doc(chatId)
//         .collection('messages')
//         .add({
//       'sender': sender,
//       'message': message,
//       'timestamp': FieldValue.serverTimestamp(),
//     });
//   }

//   Future<String> getUserPersonality() async {
//     final userId = currentUserId;
//     final userDoc = await _firestore
//         .collection('apps')
//         .doc('study_mate')
//         .collection('users')
//         .doc(userId)
//         .get();

//     return userDoc.data()?['personality'] ?? '可愛';
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// class ChatRepository {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   // 直接從 FirebaseAuth 取得目前 userId
//   String? get currentUserId => _auth.currentUser?.uid;

//   Future<String> fetchUserPersonality() async {
//     final userId = currentUserId;
//     if (userId == null) throw Exception("User not logged in");

//     final doc = await _firestore.collection('users').doc(userId).get();
//     return doc.data()?['personality'] ?? '可愛';
//   }

//   Future<List<Map<String, dynamic>>> fetchChatMessages() async {
//     final userId = currentUserId;
//     if (userId == null) throw Exception("User not logged in");

//     // 假設 chatId 也存在 users 下的某個預設子集合，例如 'defaultChat'
//     final chatId = 'defaultChat';

//     final snapshot = await _firestore
//         .collection('apps')
//         .doc('study_mate')
//         .collection('users')
//         .doc(userId)
//         .collection('chats')
//         .doc(chatId)
//         .collection('messages')
//         .orderBy('timestamp')
//         .get();

//     return snapshot.docs.map((doc) {
//       final data = doc.data();
//       return {
//         'sender': data['sender'],
//         'message': data['message'],
//         'timestamp': data['timestamp'],
//       };
//     }).toList();
//   }

//   Future<void> saveMessages(List<Map<String, dynamic>> messages) async {
//     final userId = currentUserId;
//     if (userId == null) throw Exception("User not logged in");

//     final chatId = 'defaultChat';

//     final batch = _firestore.batch();

//     for (var msg in messages) {
//       final docRef = _firestore
//           .collection('apps')
//           .doc('study_mate')
//           .collection('users')
//           .doc(userId)
//           .collection('chats')
//           .doc(chatId)
//           .collection('messages')
//           .doc();
//       batch.set(docRef, {
//         'sender': msg['sender'],
//         'message': msg['message'],
//         'timestamp': FieldValue.serverTimestamp(),
//       });
//     }

//     await batch.commit();
//   }
// }
class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  Future<String> fetchUserPersonality() async {
    final userId = currentUserId;
    if (userId == null) throw Exception("User not logged in");

    final doc = await _firestore.collection('users').doc(userId).get();
    return doc.data()?['personality'] ?? '可愛';
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

