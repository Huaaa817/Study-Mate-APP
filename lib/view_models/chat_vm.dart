import 'package:flutter/material.dart';
import '/repositories/chat_repo.dart';
import 'package:flutter_app/services/fetch_chatting.dart';


class ChatViewModel extends ChangeNotifier {
  final ChatRepository _repository;

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
    _repository.getMessagesStream().listen((event) {
      _messages = event;
      notifyListeners();
    });
  }

  Future<void> sendMessage(String userMessage) async {
    if (userMessage.trim().isEmpty || _isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      // ✅ 儲存使用者訊息
      await _repository.saveMessage({
        'sender': 'user',
        'message': userMessage,
      });

      // ✅ 將歷史訊息轉換為「我：...」「她：...」格式
      final conversationHistory = _messages.map((msg) {
        final role = msg['sender'] == 'user' ? '我' : '她';
        return '$role：${msg['message']}';
      }).toList();

      // ✅ 加入當前這句使用者訊息
      conversationHistory.add('我：$userMessage');

      // ✅ 呼叫聊天 AI API
      final aiResponse = await fetchChattingResponse(
        _personality ?? '可愛',
        userMessage,
        conversationHistory,
      );

      // ✅ 儲存 AI 回覆
      await _repository.saveMessage({
        'sender': 'ai',
        'message': aiResponse,
      });
    } catch (e) {
      // ❌ 若發生錯誤則插入錯誤訊息
      _messages.add({
        'sender': 'ai',
        'message': '發生錯誤，請稍後再試',
        'timestamp': DateTime.now(),
      });
      notifyListeners();
    }

    _isLoading = false;
    notifyListeners();
  }
}

