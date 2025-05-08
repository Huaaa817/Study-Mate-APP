// import 'package:flutter/material.dart';
// import 'package:flutter_app/services/fetch_chatting.dart'; // 引入與 Firebase Functions 溝通的函式

// class ChatPage extends StatefulWidget {
//   final String userPersonality; // 使用者的個性

//   ChatPage({required this.userPersonality});

//   @override
//   _ChatPageState createState() => _ChatPageState();
// }

// class _ChatPageState extends State<ChatPage> {
//   final TextEditingController _controller = TextEditingController();
//   final List<Map<String, String>> messages = []; // 顯示用的訊息清單
//   final List<String> conversationHistory = []; // 傳給 AI 的對話歷史

//   void _sendMessage() async {
//     if (_controller.text.isEmpty) return;

//     final userMessage = _controller.text;

//     setState(() {
//       messages.add({'sender': 'user', 'message': userMessage});
//       _controller.clear();
//     });

//     // 加入對話歷史
//     conversationHistory.add("You: $userMessage");

//     // 從 Firebase Functions 取得回覆
//     final aiResponse = await fetchChattingResponse(
//       widget.userPersonality,
//       userMessage,
//       conversationHistory,
//     );

//     // 加入 AI 回覆進對話歷史與畫面
//     conversationHistory.add("AI: $aiResponse");

//     setState(() {
//       messages.add({'sender': 'ai', 'message': aiResponse});
//     });
//   }

//   @override
//   void dispose() {
//     _controller.dispose(); // 清理控制器資源
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Chat with AI")),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               itemCount: messages.length,
//               itemBuilder: (context, index) {
//                 final message = messages[index];
//                 return ListTile(
//                   title: Text(message['message'] ?? ''),
//                   subtitle: Text(message['sender'] == 'user' ? 'You' : 'AI'),
//                   tileColor: message['sender'] == 'user'
//                       ? Colors.blue[50]
//                       : Colors.green[50],
//                 );
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _controller,
//                     decoration: const InputDecoration(
//                       hintText: "Type a message",
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.send),
//                   onPressed: _sendMessage,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:flutter_app/services/fetch_chatting.dart';

// class ChatPage extends StatefulWidget {
//   final String userPersonality;

//   ChatPage({required this.userPersonality});

//   @override
//   _ChatPageState createState() => _ChatPageState();
// }

// class _ChatPageState extends State<ChatPage> {
//   final TextEditingController _controller = TextEditingController();
//   final List<Map<String, String>> messages = [];
//   final List<String> conversationHistory = [];

//   void _sendMessage() async {
//     if (_controller.text.isEmpty) return;

//     final userMessage = _controller.text;

//     setState(() {
//       messages.add({'sender': 'user', 'message': userMessage, 'time': DateTime.now().toString()});
//       _controller.clear();
//     });

//     conversationHistory.add("You: $userMessage");

//     final aiResponse = await fetchChattingResponse(
//       widget.userPersonality,
//       userMessage,
//       conversationHistory,
//     );

//     conversationHistory.add("AI: $aiResponse");

//     setState(() {
//       messages.add({'sender': 'ai', 'message': aiResponse, 'time': DateTime.now().toString()});
//     });
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Chat with StudyMate")),
//       body: Container(
//         decoration: const BoxDecoration(
//           image: DecorationImage(
//             image: NetworkImage('https://example.com/corridor.jpg'), // 替換為實際走廊圖片 URL
//             fit: BoxFit.cover,
//             colorFilter: ColorFilter.mode(Color.fromARGB(66, 255, 255, 255), BlendMode.darken),
//           ),
//         ),
//         child: Column(
//           children: [
//             Expanded(
//               child: ListView.builder(
//                 itemCount: messages.length,
//                 itemBuilder: (context, index) {
//                   final message = messages[index];
//                   final isUser = message['sender'] == 'user';
//                   return Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
//                     child: Align(
//                       alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
//                       child: Container(
//                         padding: const EdgeInsets.all(12.0),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(16.0),
//                           boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(message['message'] ?? '', style: TextStyle(fontSize: 16)),
//                             Text(
//                               message['time']?.split(' ')[1].split('.')[0] ?? '',
//                               style: TextStyle(fontSize: 12, color: Colors.grey),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: TextField(
//                       controller: _controller,
//                       decoration: const InputDecoration(
//                         hintText: "輸入訊息",
//                         border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
//                       ),
//                     ),
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.send),
//                     onPressed: _sendMessage,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter_app/services/fetch_chatting.dart';

// class ChatPage extends StatefulWidget {
//   final String userPersonality;

//   const ChatPage({super.key, required this.userPersonality});

//   @override
//   _ChatPageState createState() => _ChatPageState();
// }

// class _ChatPageState extends State<ChatPage> {
//   final TextEditingController _controller = TextEditingController();
//   final List<Map<String, String>> messages = [];
//   final List<String> conversationHistory = [];

//   void _sendMessage() async {
//     if (_controller.text.isEmpty) return;

//     final userMessage = _controller.text;

//     setState(() {
//       messages.add({'sender': 'user', 'message': userMessage, 'time': DateTime.now().toString()});
//       _controller.clear();
//     });

//     conversationHistory.add("You: $userMessage");

//     final aiResponse = await fetchChattingResponse(
//       widget.userPersonality,
//       userMessage,
//       conversationHistory,
//     );

//     conversationHistory.add("AI: $aiResponse");

//     setState(() {
//       messages.add({'sender': 'ai', 'message': aiResponse, 'time': DateTime.now().toString()});
//     });
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Chat with StudyMate"),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () {
//             Navigator.pop(context); // 返回主畫面
//           },
//         ),
//       ),
//       body: Container(
//         decoration: const BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage('assets/img/corridor.jpg'), // 使用本地資產圖片
//             fit: BoxFit.cover,
//             colorFilter: ColorFilter.mode(Colors.black26, BlendMode.darken),
//           ),
//         ),
//         child: Column(
//           children: [
//             Expanded(
//               child: ListView.builder(
//                 itemCount: messages.length,
//                 itemBuilder: (context, index) {
//                   final message = messages[index];
//                   final isUser = message['sender'] == 'user';
//                   return Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
//                     child: Align(
//                       alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
//                       child: Container(
//                         padding: const EdgeInsets.all(12.0),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(16.0),
//                           boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(message['message'] ?? '', style: TextStyle(fontSize: 16)),
//                             Text(
//                               message['time']?.split(' ')[1].split('.')[0] ?? '',
//                               style: TextStyle(fontSize: 12, color: Colors.grey),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: TextField(
//                       controller: _controller,
//                       decoration: const InputDecoration(
//                         hintText: "輸入訊息",
//                         border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
//                       ),
//                     ),
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.send),
//                     onPressed: _sendMessage,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter_app/services/fetch_chatting.dart';
// import 'package:go_router/go_router.dart'; // 確保有匯入這個
// import 'package:intl/intl.dart';


// class ChatPage extends StatefulWidget {
//   final String userPersonality;

//   const ChatPage({super.key, required this.userPersonality});

//   @override
//   _ChatPageState createState() => _ChatPageState();
// }

// class _ChatPageState extends State<ChatPage> {
//   final TextEditingController _controller = TextEditingController();
//   final List<Map<String, String>> messages = [];
//   final List<String> conversationHistory = [];

//   void _sendMessage() async {
//     if (_controller.text.isEmpty) return;

//     final userMessage = _controller.text;

//     setState(() {
//       messages.add({'sender': 'user', 'message': userMessage, 'time': DateTime.now().toString()});
//       _controller.clear();
//     });

//     conversationHistory.add("You: $userMessage");

//     final aiResponse = await fetchChattingResponse(
//       widget.userPersonality,
//       userMessage,
//       conversationHistory,
//     );

//     conversationHistory.add("AI: $aiResponse");

//     setState(() {
//       messages.add({'sender': 'ai', 'message': aiResponse, 'time': DateTime.now().toString()});
//     });
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         context.go('/home'); // 返回 /home
//         return false; // 阻止預設返回行為
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text("Chat with StudyMate"),
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back),
//             onPressed: () {
//               context.go('/home'); // 點返回鍵時導回 home
//             },
//           ),
//         ),
//         body: Container(
//           decoration: const BoxDecoration(
//             image: DecorationImage(
//               image: AssetImage('assets/img/corridor.jpg'),
//               fit: BoxFit.cover,
//               colorFilter: ColorFilter.mode(Colors.black26, BlendMode.darken),
//             ),
//           ),
//           child: Column(
//             children: [
//               Expanded(
//                 child: ListView.builder(
//                   itemCount: messages.length,
//                   itemBuilder: (context, index) {
//                     final message = messages[index];
//                     final isUser = message['sender'] == 'user';
//                     return Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
//                       child: Align(
//                         alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
//                         child: Container(
//                           padding: const EdgeInsets.all(12.0),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(16.0),
//                             boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(message['message'] ?? '', style: const TextStyle(fontSize: 16)),
//                               Text(
//                                 message['time']?.split(' ')[1].split('.')[0] ?? '',
//                                 style: const TextStyle(fontSize: 12, color: Colors.grey),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: TextField(
//                         controller: _controller,
//                         decoration: const InputDecoration(
//                           hintText: "輸入訊息",
//                           border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
//                         ),
//                       ),
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.send),
//                       onPressed: _sendMessage,
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_app/services/fetch_chatting.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  final String userPersonality;

  const ChatPage({super.key, required this.userPersonality});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> messages = [];
  final List<String> conversationHistory = [];

  void _sendMessage() async {
    if (_controller.text.isEmpty) return;

    final userMessage = _controller.text;

    setState(() {
      messages.add({
        'sender': 'user',
        'message': userMessage,
        'time': DateTime.now().toIso8601String()
      });
      _controller.clear();
    });

    conversationHistory.add("You: $userMessage");

    final aiResponse = await fetchChattingResponse(
      widget.userPersonality,
      userMessage,
      conversationHistory,
    );

    conversationHistory.add("AI: $aiResponse");

    setState(() {
      messages.add({
        'sender': 'ai',
        'message': aiResponse,
        'time': DateTime.now().toIso8601String()
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        context.go('/home');
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Chat with StudyMate"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              context.go('/home');
            },
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/img/corridor.jpg'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(Colors.black26, BlendMode.darken),
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isUser = message['sender'] == 'user';
                    final parsedTime = DateTime.tryParse(message['time'] ?? '');
                    final formattedTime = parsedTime != null
                        ? DateFormat.jm().format(parsedTime)
                        : '';

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                      child: Align(
                        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.0),
                            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(message['message'] ?? '', style: const TextStyle(fontSize: 16)),
                              Text(
                                formattedTime,
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
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
                          hintText: "輸入訊息",
                          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
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
        ),
      ),
    );
  }
}
