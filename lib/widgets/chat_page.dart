// import 'package:flutter/material.dart';
// import 'package:flutter_app/services/fetch_chatting.dart';
// import 'package:go_router/go_router.dart';
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
//       messages.add({
//         'sender': 'user',
//         'message': userMessage,
//         'time': DateTime.now().toIso8601String(),
//       });
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
//       messages.add({
//         'sender': 'ai',
//         'message': aiResponse,
//         'time': DateTime.now().toIso8601String(),
//       });
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
//         context.go('/home');
//         return false;
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text("Chat with StudyMate"),
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back),
//             onPressed: () {
//               context.go('/home');
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
//                     final parsedTime = DateTime.tryParse(message['time'] ?? '');
//                     final formattedTime =
//                         parsedTime != null
//                             ? DateFormat.jm().format(parsedTime)
//                             : '';

//                     return Padding(
//                       padding: const EdgeInsets.symmetric(
//                         vertical: 4.0,
//                         horizontal: 8.0,
//                       ),
//                       child: Align(
//                         alignment:
//                             isUser
//                                 ? Alignment.centerRight
//                                 : Alignment.centerLeft,
//                         child: Container(
//                           padding: const EdgeInsets.all(12.0),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(16.0),
//                             boxShadow: [
//                               BoxShadow(color: Colors.black26, blurRadius: 5),
//                             ],
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 message['message'] ?? '',
//                                 style: const TextStyle(fontSize: 16),
//                               ),
//                               Text(
//                                 formattedTime,
//                                 style: const TextStyle(
//                                   fontSize: 12,
//                                   color: Colors.grey,
//                                 ),
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
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.all(Radius.circular(20)),
//                           ),
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


// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '/view_models/chat_vm.dart';

// class ChatPage extends StatelessWidget {
//   const ChatPage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     // 將 ViewModel 放在 Provider，並且初始化一次
//     return ChangeNotifierProvider(
//       create: (_) {
//         final vm = ChatViewModel();
//         // 你的 ChatViewModel 在建構子就做 _init() 了，所以這邊不用再呼叫 init()
//         return vm;
//       },
//       child: Scaffold(
//         appBar: AppBar(title: const Text('聊天頁面')),
//         body: const ChatViewBody(),
//       ),
//     );
//   }
// }

// class ChatViewBody extends StatefulWidget {
//   const ChatViewBody({Key? key}) : super(key: key);

//   @override
//   State<ChatViewBody> createState() => _ChatViewBodyState();
// }

// class _ChatViewBodyState extends State<ChatViewBody> {
//   final TextEditingController _controller = TextEditingController();

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<ChatViewModel>(
//       builder: (context, vm, child) {
//         return Column(
//           children: [
//             Expanded(
//               child: ListView.builder(
//                 reverse: true,
//                 itemCount: vm.messages.length,
//                 itemBuilder: (context, index) {
//                   final msg = vm.messages[vm.messages.length - 1 - index];
//                   final isUser = msg['sender'] == 'user';
//                   return Container(
//                     margin:
//                         const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
//                     alignment:
//                         isUser ? Alignment.centerRight : Alignment.centerLeft,
//                     child: Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: isUser ? Colors.blue[200] : Colors.grey[300],
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Text(msg['message'] ?? '',
//                           style: const TextStyle(fontSize: 16)),
//                     ),
//                   );
//                 },
//               ),
//             ),
//             if (vm.isLoading) const LinearProgressIndicator(),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: TextField(
//                       controller: _controller,
//                       decoration: const InputDecoration(
//                         hintText: '輸入訊息...',
//                       ),
//                       onSubmitted: (text) => _sendMessage(vm),
//                     ),
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.send),
//                     onPressed: vm.isLoading ? null : () => _sendMessage(vm),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _sendMessage(ChatViewModel vm) {
//     final text = _controller.text.trim();
//     if (text.isEmpty) return;

//     vm.sendMessage(text);
//     _controller.clear();
//   }
// }

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '/view_models/chat_vm.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final vm = ChatViewModel();
        return vm;
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('聊天頁面')),
        body: const ChatViewBody(),
      ),
    );
  }
}

class ChatViewBody extends StatefulWidget {
  const ChatViewBody({Key? key}) : super(key: key);

  @override
  State<ChatViewBody> createState() => _ChatViewBodyState();
}

class _ChatViewBodyState extends State<ChatViewBody> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatViewModel>(
      builder: (context, vm, child) {
        return Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/img/corridor.jpg'), // 背景圖路徑
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(Colors.black26, BlendMode.darken),
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  reverse: false, // 讓最舊訊息在上方，最新訊息在下方
                  itemCount: vm.messages.length,
                  itemBuilder: (context, index) {
                    final msg = vm.messages[index];
                    final isUser = msg['sender'] == 'user';
                    final parsedTime =
                        DateTime.tryParse(msg['time'] ?? '') ?? DateTime.now();
                    final formattedTime = DateFormat.jm().format(parsedTime);

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4.0, horizontal: 8.0),
                      child: Align(
                        alignment:
                            isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.0),
                            boxShadow: const [
                              BoxShadow(color: Colors.black26, blurRadius: 5),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                msg['message'] ?? '',
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                formattedTime,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (vm.isLoading) const LinearProgressIndicator(),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: '輸入訊息...',
                          border: const OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(20.0)),
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.9),
                        ),
                        onSubmitted: (text) => _sendMessage(vm),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: vm.isLoading ? null : () => _sendMessage(vm),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _sendMessage(ChatViewModel vm) {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    vm.sendMessage(text);
    _controller.clear();
  }
}
