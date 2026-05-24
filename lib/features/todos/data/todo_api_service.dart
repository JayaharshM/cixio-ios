import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/todo.dart';
import '../../../core/network/api_client.dart';

final Provider<TodoApiService> todoApiServiceProvider =
    Provider<TodoApiService>((ref) {
  return TodoApiService(ref.watch(apiClientProvider));
});

class TodoApiService {
  const TodoApiService(this._dio);

  final Dio _dio;

  Future<List<Todo>> getTodos({
    bool? completed,
  }) async {
    final Response<Object?> response = await _dio.get<Object?>(
      '/todos',
      queryParameters: <String, dynamic>{
        if (completed != null) 'completed': completed,
      },
    );

    final Object? data = response.data;
    final List<dynamic> todos = data is List<dynamic>
        ? data
        : _asMap(data)['todos'] as List<dynamic>? ?? <dynamic>[];

    return todos.map((todo) => Todo.fromJson(_asMap(todo))).toList();
  }

  Future<Todo> createTodo({
    required String title,
    String? description,
    DateTime? dueDate,
  }) async {
    final Response<Object?> response = await _dio.post<Object?>(
      '/todos',
      data: <String, dynamic>{
        'title': title,
        if (description != null) 'description': description,
        if (dueDate != null) 'due_date': dueDate.toIso8601String(),
      },
    );

    return Todo.fromJson(_asMap(response.data));
  }

  Future<Todo> updateTodo({
    required String id,
    String? title,
    String? description,
    DateTime? dueDate,
  }) async {
    final Response<Object?> response = await _dio.put<Object?>(
      '/todos/$id',
      data: <String, dynamic>{
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (dueDate != null) 'due_date': dueDate.toIso8601String(),
      },
    );

    return Todo.fromJson(_asMap(response.data));
  }

  Future<Todo> toggleTodoComplete({
    required String id,
  }) async {
    final Response<Object?> response = await _dio.put<Object?>(
      '/todos/$id/complete',
    );

    return Todo.fromJson(_asMap(response.data));
  }

  Future<void> deleteTodo({
    required String id,
  }) async {
    await _dio.delete<void>('/todos/$id');
  }

  Map<String, dynamic> _asMap(Object? data) {
    return data is Map<String, dynamic> ? data : <String, dynamic>{};
  }
}
