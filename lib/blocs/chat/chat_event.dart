
abstract class ChatEvent {}


class SendMessageEvent extends ChatEvent {
  final String userMessage;
  SendMessageEvent(this.userMessage);
}


class LoadChatHistoryEvent extends ChatEvent {}

class ClearChatHistoryEvent extends ChatEvent {}

