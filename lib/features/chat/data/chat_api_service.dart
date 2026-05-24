import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/chat_session.dart';
import '../../../core/models/message.dart';
import '../../../core/network/api_client.dart';

final Provider<ChatApiService> chatApiServiceProvider =
    Provider<ChatApiService>((ref) {
  return ChatApiService(ref.watch(apiClientProvider));
});

class ChatApiService {
  const ChatApiService(this._dio);

  final Dio _dio;

  Future<ChatSession> createSession() async {
    final Response<Object?> response = await _dio.post<Object?>(
      '/chat/sessions',
    );

    return ChatSession.fromJson(_asMap(response.data));
  }

  Future<List<ChatSession>> getSessions() async {
    final Response<Object?> response = await _dio.get<Object?>(
      '/chat/sessions',
    );
    final Object? data = response.data;
    final List<dynamic> sessions = data is List<dynamic>
        ? data
        : _asMap(data)['sessions'] as List<dynamic>? ?? <dynamic>[];

    return sessions
        .map((session) => ChatSession.fromJson(_asMap(session)))
        .toList();
  }

  Future<void> deleteSession(String id) async {
    await _dio.delete<void>('/chat/sessions/$id');
  }

  Future<List<Message>> getMessages(String sessionId) async {
    final Response<Object?> response = await _dio.get<Object?>(
      '/chat/sessions/$sessionId/messages',
    );
    final Object? data = response.data;
    final List<dynamic> messages = data is List<dynamic>
        ? data
        : _asMap(data)['messages'] as List<dynamic>? ?? <dynamic>[];

    return messages
        .map((message) => Message.fromJson(_asMap(message)))
        .toList();
  }

  Stream<String> sendMessage({
    required String sessionId,
    required String content,
  }) async* {
    final Response<ResponseBody> response = await _dio.post<ResponseBody>(
      '/chat/sessions/$sessionId/messages',
      data: <String, String>{'content': content},
      options: Options(
        responseType: ResponseType.stream,
        headers: const <String, String>{
          Headers.acceptHeader: 'text/event-stream',
        },
      ),
    );

    final ResponseBody? body = response.data;
    if (body == null) {
      return;
    }

    final Stream<String> lines = body.stream
        .map<List<int>>((chunk) => chunk)
        .transform(utf8.decoder)
        .transform(const LineSplitter());

    await for (final String line in lines) {
      if (!line.startsWith('data:')) {
        continue;
      }

      final String rawData = line.substring(5).trim();
      if (rawData.isEmpty) {
        continue;
      }

      final Object? decoded = jsonDecode(rawData);
      if (decoded is! Map<String, dynamic>) {
        continue;
      }

      if (decoded['done'] == true) {
        return;
      }

      final Object? token = decoded['token'];
      if (token is String) {
        yield token;
      }
    }
  }

  Map<String, dynamic> _asMap(Object? value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return <String, dynamic>{};
  }
}
