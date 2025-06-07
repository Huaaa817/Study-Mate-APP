// greeting_repo.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/services/fetch_chat.dart';
import '/repositories/personality.dart';

class GreetingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final PersonalityRepository _personalityRepo = PersonalityRepository();

  String? get currentUserId => _auth.currentUser?.uid;

  Future<String> generateGreeting() async {
    final userId = currentUserId;
    if (userId == null) throw Exception("User not logged in");

    // ✅ 改為從 PersonalityRepository 讀取 profile 文件
    final data = await _personalityRepo.getPersonalityById(userId, 'profile');

    final personality = data?['type'] ?? '可愛';

    return fetchGreeting(personality, userId);
  }
}
