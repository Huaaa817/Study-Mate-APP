import 'package:flutter/material.dart';
import 'package:flutter_app/services/fetch_chatting.dart'; // 引入與 Firebase Functions 溝通的函式

class ChatPage extends StatefulWidget {
  final String userPersonality; // 使用者的個性

  ChatPage({required this.userPersonality});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> messages = []; // 顯示用的訊息清單
  final List<String> conversationHistory = []; // 傳給 AI 的對話歷史

  void _sendMessage() async {
    if (_controller.text.isEmpty) return;

    final userMessage = _controller.text;

    setState(() {
      messages.add({'sender': 'user', 'message': userMessage});
      _controller.clear();
    });

    // 加入對話歷史
    conversationHistory.add("You: $userMessage");

    // 從 Firebase Functions 取得回覆
    final aiResponse = await fetchChattingResponse(
      widget.userPersonality,
      userMessage,
      conversationHistory,
    );

    // 加入 AI 回覆進對話歷史與畫面
    conversationHistory.add("AI: $aiResponse");

    setState(() {
      messages.add({'sender': 'ai', 'message': aiResponse});
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // 清理控制器資源
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chat with AI")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return ListTile(
                  title: Text(message['message'] ?? ''),
                  subtitle: Text(message['sender'] == 'user' ? 'You' : 'AI'),
                  tileColor: message['sender'] == 'user'
                      ? Colors.blue[50]
                      : Colors.green[50],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Type a message",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
