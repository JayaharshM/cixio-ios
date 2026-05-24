import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/todo.dart';
import 'todo_api_service.dart';

final Provider<TodoRepository> todoRepositoryProvider =
    Provider<TodoRepository>((ref) {
  return TodoRepository(ref.watch(todoApiServiceProvider));
});

class TodoRepository {
  const TodoRepository(this._apiService);

  final TodoApiService _apiService;

  Future<List<Todo>> getTodos({bool? completed}) {
    return _apiService.getTodos(completed: completed);
  }

  Future<Todo> createTodo({
    required String title,
    String? description,
    DateTime? dueDate,
  }) {
    return _apiService.createTodo(title: title, description: description, dueDate: dueDate);
  }

  Future<Todo> updateTodo({
    required String id,
    String? title,
    String? description,
    DateTime? dueDate,
  }) {
    return _apiService.updateTodo(id: id, title: title, description: description, dueDate: dueDate);
  }

  Future<Todo> toggleTodoComplete({required String id}) {
    return _apiService.toggleTodoComplete(id: id);
  }

  Future<void> deleteTodo({required String id}) {
    return _apiService.deleteTodo(id: id);
  }
}
