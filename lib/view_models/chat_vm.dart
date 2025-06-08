import 'dart:async';
import 'package:flutter/material.dart';
import '/repositories/chat_repo.dart';
import 'package:flutter_app/services/fetch_chatting.dart';

class ChatViewModel extends ChangeNotifier {
  final ChatRepository _repository;
  StreamSubscription? _messageSubscription;

  ChatViewModel({ChatRepository? repository})
      : _repository = repository ?? ChatRepository() {
    _init();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Map<String, dynamic>> _messages = [];
  List<Map<String, dynamic>> get messages => List.unmodifiable(_messages);

  String? _personality;

  void _init() async {
    _personality = await _repository.fetchUserPersonality();
    debugPrint('🧠 使用者的 personality: $_personality');

    _messageSubscription = _repository.getMessagesStream().listen((event) {
      _messages = event;
      notifyListeners(); // 若 ViewModel 已被 dispose，就會爆錯，因此需取消訂閱
    });
  }

  @override
  void dispose() {
    _messageSubscription?.cancel(); // ✅ 安全取消 Firestore stream 訂閱
    super.dispose();
  }

  Future<void> sendMessage(String userMessage) async {
    if (userMessage.trim().isEmpty || _isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _repository.saveMessage({
        'sender': 'user',
        'message': userMessage,
      });

      final conversationHistory = _messages.map((msg) {
        final role = msg['sender'] == 'user' ? '我' : '她';
        return '$role:${msg['message']}';
      }).toList();

      conversationHistory.add('我：$userMessage');

      final aiResponse = await fetchChattingResponse(
        _personality ?? '可愛',
        userMessage,
        conversationHistory,
      );

      await _repository.saveMessage({
        'sender': 'ai',
        'message': aiResponse,
      });
    } catch (e) {
      _messages.add({
        'sender': 'ai',
        'message': '發生錯誤，請稍後再試',
      });
      notifyListeners();
    }

    _isLoading = false;
    notifyListeners();
  }
}
