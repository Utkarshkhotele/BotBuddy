import 'package:equatable/equatable.dart';
import '../../models/message_model.dart';

class ChatState extends Equatable {
  final List<MessageModel> messages;
  final String responseText;
  final bool isTyping;

  const ChatState({
    required this.messages,
    required this.responseText,
    required this.isTyping,
  });

  factory ChatState.initial() => const ChatState(
    messages: [],
    responseText: '',
    isTyping: false,
  );

  ChatState copyWith({
    List<MessageModel>? messages,
    String? responseText,
    bool? isTyping,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      responseText: responseText ?? this.responseText,
      isTyping: isTyping ?? this.isTyping,
    );
  }

  @override
  List<Object?> get props => [messages, responseText, isTyping];
}
