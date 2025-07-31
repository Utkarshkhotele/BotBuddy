import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import 'chat_event.dart';
import 'chat_state.dart';
import '../../models/message_model.dart';
import '../../services/api_service.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final Box<MessageModel> _chatBox = Hive.box<MessageModel>('chatBox');
  String _currentChatId = const Uuid().v4(); // 🔑 Unique ID for current session

  ChatBloc() : super(ChatState.initial()) {
    on<LoadChatHistoryEvent>(_onLoadHistory);
    on<SendMessageEvent>(_onSendMessage);
    on<ClearChatHistoryEvent>(_onClearHistory);
    on<NewChatEvent>(_onNewChat);

    // 🔄 Load messages for initial chat session
    add(LoadChatHistoryEvent(chatId: _currentChatId));
  }

  // ✅ Load chat history for a specific session
  Future<void> _onLoadHistory(
      LoadChatHistoryEvent event,
      Emitter<ChatState> emit,
      ) async {
    _currentChatId = event.chatId;
    final history = _chatBox.values
        .where((msg) => msg.chatId == _currentChatId)
        .toList();
    emit(state.copyWith(messages: history));
  }

  // ✅ Send message and save to Hive (first message gets title)
  Future<void> _onSendMessage(
      SendMessageEvent event,
      Emitter<ChatState> emit,
      ) async {
    final isFirstMessage = state.messages.isEmpty;

    final userMsg = MessageModel(
      text: event.userMessage,
      isUser: true,
      time: DateTime.now(), // ✅ FIXED: use DateTime, not String
      chatId: _currentChatId,
      title: isFirstMessage ? event.userMessage : null,
    );

    await _chatBox.add(userMsg);

    final typingState = [...state.messages, userMsg];

    emit(state.copyWith(
      messages: typingState,
      responseText: 'Thinking...',
      isTyping: true,
    ));

    final replyText =
    await GooglleApiService.getApiResponse(event.userMessage);

    final botMsg = MessageModel(
      text: replyText,
      isUser: false,
      time: DateTime.now(), // ✅ FIXED
      chatId: _currentChatId,
    );

    await _chatBox.add(botMsg);

    emit(state.copyWith(
      messages: [...typingState, botMsg],
      responseText: replyText,
      isTyping: false,
    ));
  }

  // ✅ Clear all messages and reset session
  Future<void> _onClearHistory(
      ClearChatHistoryEvent event,
      Emitter<ChatState> emit,
      ) async {
    await _chatBox.clear();
    _currentChatId = const Uuid().v4();
    emit(ChatState.initial());
  }

  // ✅ Start a new chat session
  Future<void> _onNewChat(
      NewChatEvent event,
      Emitter<ChatState> emit,
      ) async {
    _currentChatId = const Uuid().v4();
    emit(ChatState.initial());
  }

  // 🧠 Optional: Access current chat session ID
  String get currentChatId => _currentChatId;
}


