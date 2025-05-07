import 'package:flutter/material.dart';
import 'package:flutter_app/services/fetch_chatting.dart';  // 引入 fetch_chatting.dart 用來與 Firebase Functions 互動

class ChatPage extends StatefulWidget {
  final String userPersonality; // 使用者的個性

  ChatPage({required this.userPersonality});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController _controller = TextEditingController();
  List<Map<String, String>> messages = []; // 儲存訊息

  // 用來處理使用者的訊息與回應
  void _sendMessage() async {
    if (_controller.text.isEmpty) return;

    String userMessage = _controller.text;

    // 將使用者訊息加入畫面
    setState(() {
      messages.add({'sender': 'user', 'message': userMessage});
      _controller.clear();
    });

    // 呼叫 Firebase Functions 來取得 AI 回應
    String aiResponse = await fetchChattingResponse(widget.userPersonality, userMessage);

    // 顯示 AI 回應
    setState(() {
      messages.add({'sender': 'ai', 'message': aiResponse});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chat with AI")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(messages[index]['message'] ?? ''),
                  subtitle: Text(messages[index]['sender'] == 'user' ? 'You' : 'AI'),
                  tileColor: messages[index]['sender'] == 'user' ? Colors.blue[50] : Colors.green[50],
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
                    decoration: InputDecoration(
                      hintText: "Type a message",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
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
