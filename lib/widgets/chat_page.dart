import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '/view_models/chat_vm.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/view_models/me_wm.dart';

class ChatPage extends StatelessWidget {
  final MeViewModel meViewModel;
  const ChatPage({Key? key, required this.meViewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final vm = ChatViewModel();
        return vm;
      },
      child: ChatViewBody(viewModel: meViewModel),
    );
  }
}

class ChatViewBody extends StatefulWidget {
  final MeViewModel viewModel;
  const ChatViewBody({Key? key, required this.viewModel}) : super(key: key);

  @override
  State<ChatViewBody> createState() => _ChatViewBodyState();
}

class _ChatViewBodyState extends State<ChatViewBody> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Color appBarColor = Colors.transparent; // 初始為透明
  bool _hasInitialScrolled = false; // 追蹤是否已經初次滾動過

  @override
  void initState() {
    super.initState();
    
    // 添加滾動監聽器
    _scrollController.addListener(_scrollListener);

    // 頁面載入完畢後自動滾動到底部
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<ChatViewModel>();
      if (vm.messages.isNotEmpty && !_hasInitialScrolled) {
        _scrollToBottom();
        _hasInitialScrolled = true;
      }
    });
  }

  void _scrollListener() {
    print("Scroll offset: ${_scrollController.offset}");
    final newColor =
        _scrollController.offset > 10
            ? Theme.of(context).colorScheme.primary
            //: Colors.transparent.withOpacity(0.1);
            : Theme.of(context).colorScheme.secondary;

    if (newColor != appBarColor) {
      setState(() {
        appBarColor = newColor;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MeViewModel>();
    final image_studymate = viewModel.userImageUrl;
    
    print("AppBar background color: $appBarColor");
    
    return Consumer<ChatViewModel>(
      builder: (context, vm, child) {
        // 只在初次進入時自動滾動到底部
        if (!_hasInitialScrolled && vm.messages.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToBottom();
            _hasInitialScrolled = true;
          });
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Chat'),
            backgroundColor: appBarColor,
            foregroundColor: appBarColor == Colors.transparent 
                ? Theme.of(context).colorScheme.onSurface 
                : Theme.of(context).colorScheme.onPrimary,
            elevation: appBarColor == Colors.transparent ? 0 : 4,
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
                    controller: _scrollController,
                    reverse: false,
                    itemCount: vm.messages.length,
                    itemBuilder: (context, index) {
                      final msg = vm.messages[index];
                      final isUser = msg['sender'] == 'user';

                      DateTime parsedTime;
                      final rawTime = msg['timestamp'];
                      if (rawTime is Timestamp) {
                        parsedTime = rawTime.toDate();
                      } else if (rawTime is String) {
                        parsedTime = DateTime.tryParse(rawTime) ?? DateTime.now();
                      } else {
                        parsedTime = DateTime.now();
                      }
                      final formattedTime = DateFormat.jm().format(parsedTime);

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 4.0,
                          horizontal: 8.0,
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Align(
                              alignment:
                                  isUser
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.all(12.0),
                                decoration: BoxDecoration(
                                  color:
                                      isUser
                                          ? Colors.white
                                          : Theme.of(
                                            context,
                                          ).colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(16.0),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 5,
                                    ),
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

                            if (!isUser)
                              Positioned(
                                top: -37,
                                left: -5,
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: ClipOval(
                                    child: ClipRect(
                                      child: Transform.translate(
                                        offset: Offset(-15, -2),
                                        child: Align(
                                          alignment: Alignment(-0.25, -0.25),
                                          widthFactor: 0.25,
                                          heightFactor: 0.25,
                                          child: Transform.scale(
                                            scale: 4.0,
                                            alignment: Alignment.topLeft,
                                            child: Image.network(
                                              image_studymate ?? '',
                                              fit: BoxFit.cover,
                                              width: 128,
                                              height: 128,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            hintText: '輸入訊息...',
                            border: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(20.0),
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.9),
                          ),
                          onSubmitted: (text) => _sendMessage(vm),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        color:
                            vm.isLoading
                                ? Colors.grey
                                : Theme.of(context).colorScheme.secondary,
                        onPressed: vm.isLoading ? null : () => _sendMessage(vm),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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