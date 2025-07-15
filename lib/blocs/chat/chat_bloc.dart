import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';

import 'chat_event.dart';
import 'chat_state.dart';
import '../../models/message_model.dart';
import '../../services/api_service.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {

  final Box<MessageModel> _chatBox = Hive.box<MessageModel>('chatBox');

  ChatBloc() : super(ChatState.initial()) {
    on<LoadChatHistoryEvent>(_onLoadHistory);
    on<SendMessageEvent>(_onSendMessage);
    on<ClearChatHistoryEvent>(_onClearHistory);

    add(LoadChatHistoryEvent());
  }

  Future<void> _onLoadHistory(
      LoadChatHistoryEvent event,
      Emitter<ChatState> emit,
      ) async {
    final history = _chatBox.values.toList();
    emit(state.copyWith(messages: history));
  }

  Future<void> _onSendMessage(
      SendMessageEvent event,
      Emitter<ChatState> emit,
      ) async {
    final userMsg = MessageModel(
      text: event.userMessage,
      isUser: true,
      time: DateFormat('hh:mm a').format(DateTime.now()),
    );
    await _chatBox.add(userMsg);

    final typingState = [...state.messages, userMsg];
    emit(state.copyWith(
      messages: typingState,
      responseText: 'Thinking...',
      isTyping: true,
    ));

    final replyText = await GooglleApiService.getApiResponse(event.userMessage);

    final botMsg = MessageModel(
      text: replyText,
      isUser: false,
      time: DateFormat('hh:mm a').format(DateTime.now()),
    );
    await _chatBox.add(botMsg);

    emit(state.copyWith(
      messages: [...typingState, botMsg],
      responseText: replyText,
      isTyping: false,
    ));
  }

  Future<void> _onClearHistory(
      ClearChatHistoryEvent event,
      Emitter<ChatState> emit,
      ) async {
    await _chatBox.clear();
    add(LoadChatHistoryEvent());
  }
}


