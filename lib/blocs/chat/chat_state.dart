import '../../models/message_model.dart';

class ChatState {
  final List<MessageModel> messages;
  final String responseText;
  final bool isTyping;
  final String currentChatId; // 👈 New field

  ChatState({
    required this.messages,
    required this.responseText,
    required this.isTyping,
    required this.currentChatId,
  });

  factory ChatState.initial() => ChatState(
    messages: [],
    responseText: '',
    isTyping: false,
    currentChatId: DateTime.now().millisecondsSinceEpoch.toString(), // 👈 default
  );

  ChatState copyWith({
    List<MessageModel>? messages,
    String? responseText,
    bool? isTyping,
    String? currentChatId,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      responseText: responseText ?? this.responseText,
      isTyping: isTyping ?? this.isTyping,
      currentChatId: currentChatId ?? this.currentChatId,
    );
  }
}
