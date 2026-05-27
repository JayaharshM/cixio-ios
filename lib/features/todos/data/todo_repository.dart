import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/todo.dart';
import '../../../core/models/todo_section.dart';
import 'todo_api_service.dart';

final Provider<TodoRepository> todoRepositoryProvider =
    Provider<TodoRepository>((ref) {
  return TodoRepository(ref.watch(todoApiServiceProvider));
});

class TodoRepository {
  const TodoRepository(this._apiService);

  final TodoApiService _apiService;

  Future<List<TodoSection>> getSections() => _apiService.getSections();

  Future<TodoSection> createSection(String title) =>
      _apiService.createSection(title);

  Future<void> deleteSection(String id) => _apiService.deleteSection(id);

  Future<TodoSection> togglePinSection(String id) =>
      _apiService.togglePinSection(id);

  Future<List<Todo>> getTodos(String sectionId, {bool? completed}) {
    return _apiService.getTodos(sectionId, completed: completed);
  }

  Future<Todo> createTodo({
    required String sectionId,
    required String title,
    String? description,
    DateTime? dueDate,
  }) {
    return _apiService.createTodo(
      sectionId: sectionId,
      title: title,
      description: description,
      dueDate: dueDate,
    );
  }

  Future<Todo> updateTodo({
    required String id,
    String? title,
    String? description,
    DateTime? dueDate,
  }) {
    return _apiService.updateTodo(
      id: id,
      title: title,
      description: description,
      dueDate: dueDate,
    );
  }

  Future<Todo> toggleTodoComplete({required String id}) {
    return _apiService.toggleTodoComplete(id: id);
  }

  Future<void> deleteTodo({required String id}) {
    return _apiService.deleteTodo(id: id);
  }

  Future<Todo> toggleTodoPin({required String id}) {
    return _apiService.toggleTodoPin(id: id);
  }
}
