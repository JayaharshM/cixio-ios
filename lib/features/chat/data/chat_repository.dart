import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/chat_session.dart';
import '../../../core/models/message.dart';
import 'chat_api_service.dart';

final Provider<ChatRepository> chatRepositoryProvider =
    Provider<ChatRepository>((ref) {
  return ChatRepository(ref.watch(chatApiServiceProvider));
});

class ChatRepository {
  const ChatRepository(this._apiService);

  final ChatApiService _apiService;

  Future<ChatSession> createSession() {
    return _apiService.createSession();
  }

  Future<List<ChatSession>> getSessions() {
    return _apiService.getSessions();
  }

  Future<void> deleteSession(String id) {
    return _apiService.deleteSession(id);
  }

  Future<ChatSession> togglePinSession(String id) {
    return _apiService.togglePinSession(id);
  }

  Future<List<Message>> getMessages(String sessionId) {
    return _apiService.getMessages(sessionId);
  }

  Stream<String> sendMessage({
    required String sessionId,
    required String content,
  }) {
    return _apiService.sendMessage(sessionId: sessionId, content: content);
  }
}
