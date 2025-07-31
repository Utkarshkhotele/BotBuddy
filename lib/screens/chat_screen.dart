import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:hive/hive.dart';

import '../blocs/chat/chat_bloc.dart';
import '../blocs/chat/chat_event.dart';
import '../blocs/chat/chat_state.dart';
import '../models/message_model.dart';
import '../theme/theme_provider.dart';
import 'chat_history_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatBloc>().stream.listen((state) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 2,
        centerTitle: true,
        title: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('BotBuddy', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text('Online', style: TextStyle(color: Colors.green, fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => themeProvider.toggleTheme(),
          ),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Chat History',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatHistoryScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'New Chat',
            onPressed: () => context.read<ChatBloc>().add(NewChatEvent()),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share Chat',
            onPressed: () {
              final messages = context.read<ChatBloc>().state.messages;
              final text = messages.map((m) => "${m.isUser ? 'You' : 'Bot'}: ${m.text}").join('\n\n');
              Share.share(text, subject: 'Chat with BotBuddy');
            },
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Theme.of(context).iconTheme.color),
            onSelected: (value) {
              if (value == 'clear') {
                context.read<ChatBloc>().add(ClearChatHistoryEvent());
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Chat history cleared")),
                );
              }
            },
            itemBuilder: (BuildContext context) => const [
              PopupMenuItem(value: 'clear', child: Text('Clear Chat History')),
            ],
          ),
        ],
      ),
      body: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  itemCount: state.messages.length,
                  itemBuilder: (context, index) {
                    final message = state.messages[index];
                    final isUser = message.isUser;

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                      children: [
                        if (!isUser) ...[
                          const CircleAvatar(
                            backgroundImage: AssetImage('assets/logo.png'),
                            radius: 14,
                          ),
                          const SizedBox(width: 8),
                        ],
                        Flexible(
                          child: GestureDetector(
                            onLongPress: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Delete Message?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                final box = Hive.box<MessageModel>('chatBox');
                                await box.delete(message.key);
                                context.read<ChatBloc>().add(
                                  LoadChatHistoryEvent(chatId: context.read<ChatBloc>().currentChatId),
                                );
                              }
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: isUser ? const Color(0xFFEDEDED) : Theme.of(context).cardColor,
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(16),
                                  topRight: const Radius.circular(16),
                                  bottomLeft: Radius.circular(isUser ? 16 : 0),
                                  bottomRight: Radius.circular(isUser ? 0 : 16),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: isUser
                                  ? Text(
                                message.text,
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 15,
                                  height: 1.4,
                                ),
                              )
                                  : MarkdownBody(
                                data: message.text,
                                styleSheet: MarkdownStyleSheet(
                                  p: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context).textTheme.bodyLarge?.color,
                                    height: 1.5,
                                  ),
                                  strong: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (isUser) const SizedBox(width: 8),
                      ],
                    );
                  },
                ),
              ),
              if (state.isTyping)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'BotBuddy is typing...',
                      style: TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: messageController,
                        textInputAction: TextInputAction.send,
                        onFieldSubmitted: (value) {
                          if (value.trim().isNotEmpty) {
                            context.read<ChatBloc>().add(SendMessageEvent(value.trim()));
                            messageController.clear();
                          }
                        },
                        decoration: InputDecoration(
                          hintText: "How can I help you today?",
                          filled: true,
                          fillColor: Theme.of(context).cardColor,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.emoji_emotions_outlined),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    FloatingActionButton(
                      heroTag: 'send_btn',
                      onPressed: () {
                        if (messageController.text.trim().isNotEmpty) {
                          context.read<ChatBloc>().add(
                            SendMessageEvent(messageController.text.trim()),
                          );
                          messageController.clear();
                        }
                      },
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      mini: true,
                      child: Icon(
                        Icons.send,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}














