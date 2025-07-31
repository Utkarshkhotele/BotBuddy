abstract class ChatEvent {}

class SendMessageEvent extends ChatEvent {
  final String userMessage;
  SendMessageEvent(this.userMessage);
}

class LoadChatHistoryEvent extends ChatEvent {
  final String chatId;
  LoadChatHistoryEvent({required this.chatId});
}

class ClearChatHistoryEvent extends ChatEvent {}

class NewChatEvent extends ChatEvent {} // 👈 For starting new chat session
