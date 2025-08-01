import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import 'chat_event.dart';
import 'chat_state.dart';
import '../../models/message_model.dart';
import '../../services/api_service.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final Box<MessageModel> _chatBox;
  String _currentChatId = const Uuid().v4();

  ChatBloc({Box<MessageModel>? injectedBox})
      : _chatBox = injectedBox ?? Hive.box<MessageModel>('chatBox'),
        super(ChatState.initial()) {
    on<LoadChatHistoryEvent>(_onLoadHistory);
    on<SendMessageEvent>(_onSendMessage);
    on<ClearChatHistoryEvent>(_onClearHistory);
    on<NewChatEvent>(_onNewChat);

    // Initial load for the fresh session
    add(LoadChatHistoryEvent(chatId: _currentChatId));
  }

  Future<void> _onLoadHistory(
      LoadChatHistoryEvent event,
      Emitter<ChatState> emit,
      ) async {
    _currentChatId = event.chatId;

    try {
      final history = _chatBox.values
          .where((msg) => msg.chatId == _currentChatId)
          .toList();
      emit(state.copyWith(messages: history));
    } catch (e) {
      // In case something goes wrong with box access, fall back gracefully.
      emit(state.copyWith(messages: []));
    }
  }

  Future<void> _onSendMessage(
      SendMessageEvent event,
      Emitter<ChatState> emit,
      ) async {
    final isFirstMessage = state.messages.isEmpty;

    final userMsg = MessageModel(
      text: event.userMessage,
      isUser: true,
      time: DateTime.now(),
      chatId: _currentChatId,
      title: isFirstMessage ? event.userMessage : null,
    );

    await _chatBox.add(userMsg);

    final updatedMessages = [...state.messages, userMsg];
    emit(state.copyWith(
      messages: updatedMessages,
      responseText: 'Thinking...',
      isTyping: true,
    ));

    final replyText =
    await GooglleApiService.getApiResponse(event.userMessage);

    final botMsg = MessageModel(
      text: replyText,
      isUser: false,
      time: DateTime.now(),
      chatId: _currentChatId,
    );

    await _chatBox.add(botMsg);

    emit(state.copyWith(
      messages: [...updatedMessages, botMsg],
      responseText: replyText,
      isTyping: false,
    ));
  }

  /// Clears only the current session's messages (keeps other sessions intact)
  Future<void> _onClearHistory(
      ClearChatHistoryEvent event,
      Emitter<ChatState> emit,
      ) async {
    final toDelete = _chatBox.values
        .where((msg) => msg.chatId == _currentChatId)
        .toList();

    for (final m in toDelete) {
      await _chatBox.delete(m.key);
    }

    // Start a fresh session
    _currentChatId = const Uuid().v4();
    emit(ChatState.initial());
    add(LoadChatHistoryEvent(chatId: _currentChatId));
  }

  Future<void> _onNewChat(
      NewChatEvent event,
      Emitter<ChatState> emit,
      ) async {
    _currentChatId = const Uuid().v4();
    emit(ChatState.initial());
    add(LoadChatHistoryEvent(chatId: _currentChatId));
  }

  String get currentChatId => _currentChatId;
}



