import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart'; // needed for listenable()
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../models/message_model.dart';
import '../blocs/chat/chat_bloc.dart';
import '../blocs/chat/chat_event.dart';
import 'chat_screen.dart';

class ChatHistoryScreen extends StatelessWidget {
  const ChatHistoryScreen({super.key});

  String _formatTimestamp(DateTime dt) {
    return DateFormat('hh:mm a, dd MMM yyyy').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final Box<MessageModel> chatBox = Hive.box<MessageModel>('chatBox');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat History'),
      ),
      body: ValueListenableBuilder<Box<MessageModel>>(
        valueListenable: chatBox.listenable(),
        builder: (context, Box<MessageModel> box, _) {
          if (box.values.isEmpty) {
            return const Center(
              child: Text(
                "No chat history found.",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          // Group messages by chatId
          final Map<String, List<MessageModel>> grouped = {};
          for (final msg in box.values) {
            grouped.putIfAbsent(msg.chatId, () => []).add(msg);
          }

          final List<_SessionSummary> sessions = grouped.entries.map((e) {
            final msgs = e.value;
            msgs.sort((a, b) => a.time.compareTo(b.time)); // ascending

            // First user message for title & timestamp; fallback to first message
            final firstUser = msgs.firstWhere(
                  (m) => m.isUser,
              orElse: () => msgs.first,
            );
            final title = firstUser.title?.isNotEmpty == true
                ? firstUser.title!
                : (firstUser.isUser ? firstUser.text : 'Chat');
            final timestamp = firstUser.time;

            return _SessionSummary(
              chatId: e.key,
              title: title,
              askedAt: timestamp,
            );
          }).toList();

          // Sort by the time of the first question (newest first)
          sessions.sort((a, b) => b.askedAt.compareTo(a.askedAt));

          return ListView.separated(
            itemCount: sessions.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final session = sessions[index];
              return ListTile(
                leading: const Icon(Icons.chat_bubble_outline),
                title: Text(session.title),
                subtitle: Text("Asked at ${_formatTimestamp(session.askedAt)}"),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Rename',
                  onPressed: () async {
                    final controller = TextEditingController(text: session.title);
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
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, controller.text.trim()),
                            child: const Text('Save'),
                          ),
                        ],
                      ),
                    );

                    if (newTitle != null && newTitle.isNotEmpty) {
                      final sessionMessages = box.values.where((m) => m.chatId == session.chatId).toList();
                      for (var m in sessionMessages) {
                        m.title = newTitle;
                        await m.save();
                      }
                    }
                  },
                ),
                onTap: () {
                  context.read<ChatBloc>().add(LoadChatHistoryEvent(chatId: session.chatId));
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ChatScreen()),
                  );
                },
                onLongPress: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Delete Chat?'),
                      content: const Text('This will delete the entire chat session.'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                        TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    final toDelete = box.values.where((m) => m.chatId == session.chatId).toList();
                    for (final m in toDelete) {
                      await box.delete(m.key);
                    }
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _SessionSummary {
  final String chatId;
  final String title;
  final DateTime askedAt;

  _SessionSummary({
    required this.chatId,
    required this.title,
    required this.askedAt,
  });
}



