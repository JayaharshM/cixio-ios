import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/chat_session.dart';
import '../../../core/models/message.dart';
import '../data/chat_repository.dart';

final StateNotifierProvider<ChatNotifier, ChatState> chatProvider =
    StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier(ref.watch(chatRepositoryProvider))..initialize();
});

class ChatState {
  const ChatState({
    this.sessions = const <ChatSession>[],
    this.messages = const <Message>[],
    this.activeSession,
    this.isLoading = false,
    this.isStreaming = false,
    this.errorMessage,
  });

  final List<ChatSession> sessions;
  final List<Message> messages;
  final ChatSession? activeSession;
  final bool isLoading;
  final bool isStreaming;
  final String? errorMessage;

  ChatState copyWith({
    List<ChatSession>? sessions,
    List<Message>? messages,
    ChatSession? activeSession,
    bool clearActiveSession = false,
    bool? isLoading,
    bool? isStreaming,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ChatState(
      sessions: sessions ?? this.sessions,
      messages: messages ?? this.messages,
      activeSession:
          clearActiveSession ? null : activeSession ?? this.activeSession,
      isLoading: isLoading ?? this.isLoading,
      isStreaming: isStreaming ?? this.isStreaming,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier(this._repository) : super(const ChatState());

  final ChatRepository _repository;
  bool _didInitialize = false;

  Future<void> initialize() async {
    if (_didInitialize) {
      return;
    }

    _didInitialize = true;
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      List<ChatSession> sessions = await _repository.getSessions();
      ChatSession activeSession;

      if (sessions.isEmpty) {
        activeSession = await _repository.createSession();
        sessions = await _repository.getSessions();
      } else {
        activeSession = sessions.first;
      }

      final List<Message> messages =
          await _repository.getMessages(activeSession.id);

      state = state.copyWith(
        sessions: sessions,
        activeSession: activeSession,
        messages: messages,
        isLoading: false,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to load chat. Is the mock backend running?',
      );
    }
  }

  Future<void> selectSession(ChatSession session) async {
    if (state.activeSession?.id == session.id) {
      return;
    }

    state = state.copyWith(
      activeSession: session,
      messages: const <Message>[],
      isLoading: true,
      clearError: true,
    );

    try {
      final List<Message> messages = await _repository.getMessages(session.id);
      state = state.copyWith(messages: messages, isLoading: false);
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to load this chat session.',
      );
    }
  }

  Future<void> createNewSession() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final ChatSession session = await _repository.createSession();
      final List<ChatSession> sessions = await _repository.getSessions();
      final List<Message> messages = await _repository.getMessages(session.id);

      state = state.copyWith(
        sessions: sessions,
        activeSession: session,
        messages: messages,
        isLoading: false,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to create a new chat session.',
      );
    }
  }

  Future<void> deleteSession(String id) async {
    final ChatSession? activeSession = state.activeSession;

    try {
      await _repository.deleteSession(id);
      List<ChatSession> sessions = await _repository.getSessions();

      if (sessions.isEmpty) {
        final ChatSession session = await _repository.createSession();
        sessions = await _repository.getSessions();
        final List<Message> messages =
            await _repository.getMessages(session.id);

        state = state.copyWith(
          sessions: sessions,
          activeSession: session,
          messages: messages,
          clearError: true,
        );
        return;
      }

      final ChatSession nextSession = activeSession?.id == id
          ? sessions.first
          : activeSession ?? sessions.first;
      final List<Message> messages =
          await _repository.getMessages(nextSession.id);

      state = state.copyWith(
        sessions: sessions,
        activeSession: nextSession,
        messages: messages,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(errorMessage: 'Unable to delete chat session.');
    }
  }

  Future<void> sendMessage(String content) async {
    final String trimmedContent = content.trim();
    final ChatSession? session = state.activeSession;

    if (trimmedContent.isEmpty || session == null || state.isStreaming) {
      return;
    }

    final Message userMessage = Message(
      id: 'local-user-${DateTime.now().microsecondsSinceEpoch}',
      role: MessageRole.user,
      content: trimmedContent,
      timestamp: DateTime.now(),
    );
    final Message assistantMessage = Message(
      id: 'local-ai-${DateTime.now().microsecondsSinceEpoch}',
      role: MessageRole.assistant,
      content: '',
      timestamp: DateTime.now(),
      isStreaming: true,
    );

    state = state.copyWith(
      messages: <Message>[
        ...state.messages,
        userMessage,
        assistantMessage,
      ],
      isStreaming: true,
      clearError: true,
    );

    try {
      String streamedContent = '';

      await for (final String token in _repository.sendMessage(
        sessionId: session.id,
        content: trimmedContent,
      )) {
        streamedContent += token;
        _replaceLastAssistantMessage(
          assistantMessage.copyWith(
            content: streamedContent,
            isStreaming: true,
          ),
        );
      }

      _replaceLastAssistantMessage(
        assistantMessage.copyWith(
          content: streamedContent,
          isStreaming: false,
        ),
      );

      state = state.copyWith(isStreaming: false);
    } catch (error) {
      _replaceLastAssistantMessage(
        assistantMessage.copyWith(
          content: 'I could not reach the SmartHub AI service.',
          isStreaming: false,
        ),
      );
      state = state.copyWith(
        isStreaming: false,
        errorMessage: 'Message failed. Please try again.',
      );
    }
  }

  void _replaceLastAssistantMessage(Message replacement) {
    final List<Message> messages = <Message>[...state.messages];
    final int index = messages.lastIndexWhere((message) {
      return message.role == MessageRole.assistant &&
          message.id == replacement.id;
    });

    if (index == -1) {
      return;
    }

    messages[index] = replacement;
    state = state.copyWith(messages: messages);
  }
}
