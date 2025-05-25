// import 'package:flutter/material.dart';
// import '/repositories/chat_repo.dart';

// class ChatViewModel extends ChangeNotifier {
//   final ChatRepository _chatRepository = ChatRepository();

//   final String userId;
//   final String chatId;

//   ChatViewModel({required this.userId, required this.chatId});

//   Stream<List<Map<String, dynamic>>> get messagesStream {
//     return _chatRepository.getMessagesStream(userId, chatId);
//   }

//   Future<void> sendMessage(String message, {required bool fromUser}) async {
//     await _chatRepository.sendMessage(
//       userId: userId,
//       chatId: chatId,
//       sender: fromUser ? 'user' : 'ai',
//       message: message,
//     );
//   }
// }

import 'package:flutter/material.dart';
import '/repositories/chat_repo.dart';
import 'package:flutter_app/services/fetch_chatting.dart';

// class ChatViewModel extends ChangeNotifier {
//   final ChatRepository _repository;

//   ChatViewModel({ChatRepository? repository})
//       : _repository = repository ?? ChatRepository();

//   bool _isLoading = false;
//   bool get isLoading => _isLoading;

//   List<Map<String, dynamic>> _messages = [];
//   List<Map<String, dynamic>> get messages => List.unmodifiable(_messages);

//   String? _personality;

//   Future<void> init() async {
//     _personality = await _repository.fetchUserPersonality();
//     await loadMessages();
//   }

//   Future<void> loadMessages() async {
//     _messages = await _repository.fetchChatMessages();
//     notifyListeners();
//   }

//   Future<void> sendMessage(String userMessage) async {
//     if (userMessage.trim().isEmpty || _isLoading) return;

//     _messages.add({'sender': 'user', 'message': userMessage, 'timestamp': DateTime.now()});
//     notifyListeners();

//     _isLoading = true;
//     notifyListeners();

//     try {
//       final historyMsgs = await _repository.fetchChatMessages();
//       final conversationHistory = historyMsgs.map((m) => m['message'] as String).toList();
//       conversationHistory.add(userMessage);

//       final aiResponse = await fetchChattingResponse(
//         _personality ?? '可愛',
//         userMessage,
//         conversationHistory,
//       );

//       _messages.add({'sender': 'ai', 'message': aiResponse, 'timestamp': DateTime.now()});
//       notifyListeners();

//       await _repository.saveMessages([
//         {'sender': 'user', 'message': userMessage},
//         {'sender': 'ai', 'message': aiResponse},
//       ]);
//     } catch (e) {
//       _messages.add({'sender': 'ai', 'message': '發生錯誤，請稍後再試', 'timestamp': DateTime.now()});
//       notifyListeners();
//     }

//     _isLoading = false;
//     notifyListeners();
//   }
// }
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
      // 先存使用者訊息
      await _repository.saveMessage({
        'sender': 'user',
        'message': userMessage,
      });

      // 取得目前聊天紀錄(可用本地訊息轉純文字陣列)
      final conversationHistory =
          _messages.map((m) => m['message'] as String).toList();
      conversationHistory.add(userMessage);

      // 呼叫聊天 AI API
      final aiResponse = await fetchChattingResponse(
        _personality ?? '可愛',
        userMessage,
        conversationHistory,
      );

      // 儲存 AI 回覆
      await _repository.saveMessage({
        'sender': 'ai',
        'message': aiResponse,
      });
    } catch (e) {
      // 失敗時直接加入錯誤訊息
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

