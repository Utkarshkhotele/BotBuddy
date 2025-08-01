import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class SendMessageEvent extends ChatEvent {
  final String userMessage;
  const SendMessageEvent(this.userMessage);

  @override
  List<Object?> get props => [userMessage];
}

class LoadChatHistoryEvent extends ChatEvent {
  final String chatId;
  const LoadChatHistoryEvent({required this.chatId});

  @override
  List<Object?> get props => [chatId];
}

class ClearChatHistoryEvent extends ChatEvent {
  const ClearChatHistoryEvent();
}

class NewChatEvent extends ChatEvent {
  const NewChatEvent();
}
