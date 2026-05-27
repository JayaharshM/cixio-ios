import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/todo.dart';
import '../../../core/models/todo_section.dart';
import '../../../core/network/api_client.dart';

final Provider<TodoApiService> todoApiServiceProvider =
    Provider<TodoApiService>((ref) {
  return TodoApiService(ref.watch(apiClientProvider));
});

class TodoApiService {
  const TodoApiService(this._dio);

  final Dio _dio;

  Future<List<TodoSection>> getSections() async {
    final Response<Object?> response = await _dio.get<Object?>('/todos/sections');
    final Object? data = response.data;
    final List<dynamic> sections = data is List<dynamic>
        ? data
        : _asMap(data)['sections'] as List<dynamic>? ?? <dynamic>[];

    return sections
        .map((section) => TodoSection.fromJson(_asMap(section)))
        .toList();
  }

  Future<TodoSection> createSection(String title) async {
    final Response<Object?> response = await _dio.post<Object?>(
      '/todos/sections',
      data: <String, dynamic>{'title': title},
    );
    return TodoSection.fromJson(_asMap(response.data));
  }

  Future<void> deleteSection(String id) async {
    await _dio.delete<void>('/todos/sections/$id');
  }

  Future<TodoSection> togglePinSection(String id) async {
    final Response<Object?> response = await _dio.post<Object?>(
      '/todos/sections/$id/toggle_pin',
    );
    return TodoSection.fromJson(_asMap(response.data));
  }

  Future<List<Todo>> getTodos(String sectionId, {bool? completed}) async {
    final Response<Object?> response = await _dio.get<Object?>(
      '/todos/sections/$sectionId/todos',
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
    required String sectionId,
    required String title,
    String? description,
    DateTime? dueDate,
  }) async {
    final Response<Object?> response = await _dio.post<Object?>(
      '/todos/sections/$sectionId/todos',
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

  Future<Todo> toggleTodoPin({
    required String id,
  }) async {
    final Response<Object?> response = await _dio.post<Object?>(
      '/todos/$id/toggle_pin',
    );
    return Todo.fromJson(_asMap(response.data));
  }

  Map<String, dynamic> _asMap(Object? data) {
    return data is Map<String, dynamic> ? data : <String, dynamic>{};
  }
}
