import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/message_model.dart';
import '../blocs/chat/chat_bloc.dart';
import '../blocs/chat/chat_event.dart';
import 'chat_screen.dart';

class ChatHistoryScreen extends StatelessWidget {
  const ChatHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Box<MessageModel> chatBox = Hive.box<MessageModel>('chatBox');
    final messages = chatBox.values.toList();

    // 🧠 Group messages by chatId (keep latest per chat)
    final Map<String, MessageModel> chatSessions = {};
    for (final msg in messages) {
      chatSessions[msg.chatId] = msg;
    }

    final sessionList = chatSessions.values.toList()
      ..sort((a, b) => b.time.compareTo(a.time)); // Newest first

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat History'),
      ),
      body: sessionList.isEmpty
          ? const Center(
        child: Text(
          "No chat history found.",
          style: TextStyle(fontSize: 16),
        ),
      )
          : ListView.separated(
        itemCount: sessionList.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final msg = sessionList[index];

          return ListTile(
            leading: const Icon(Icons.chat_bubble_outline),
            title: Text(msg.title ?? 'Chat'),
            subtitle: Text("Last at ${msg.time}"),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Rename',
              onPressed: () async {
                final controller =
                TextEditingController(text: msg.title ?? '');
                final newTitle = await showDialog<String>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Rename Chat'),
                    content: TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        hintText: 'Enter new title',
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () =>
                            Navigator.pop(context), // Cancel
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(
                            context, controller.text.trim()),
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                );

                if (newTitle != null && newTitle.isNotEmpty) {
                  final sessionMessages = chatBox.values
                      .where((m) => m.chatId == msg.chatId)
                      .toList();

                  for (var m in sessionMessages) {
                    final updated = MessageModel(
                      text: m.text,
                      isUser: m.isUser,
                      time: m.time,
                      chatId: m.chatId,
                      title: newTitle,
                    );
                    await chatBox.put(m.key, updated);
                  }

                  // 🔁 Refresh UI
                  (context as Element).reassemble();
                }
              },
            ),
            onTap: () {
              context
                  .read<ChatBloc>()
                  .add(LoadChatHistoryEvent(chatId: msg.chatId));
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ChatScreen(),
                ),
              );
            },
            onLongPress: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Delete Chat?'),
                  content: const Text(
                      'This will delete the entire chat session.'),
                  actions: [
                    TextButton(
                        onPressed: () =>
                            Navigator.pop(context, false),
                        child: const Text('Cancel')),
                    TextButton(
                        onPressed: () =>
                            Navigator.pop(context, true),
                        child: const Text('Delete')),
                  ],
                ),
              );

              if (confirm == true) {
                final toDelete = chatBox.values
                    .where((m) => m.chatId == msg.chatId)
                    .toList();
                for (final m in toDelete) {
                  await chatBox.delete(m.key);
                }

                (context as Element).reassemble(); // Refresh
              }
            },
          );
        },
      ),
    );
  }
}


