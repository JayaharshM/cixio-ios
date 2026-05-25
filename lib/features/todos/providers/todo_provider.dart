import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/todo.dart';
import '../data/todo_repository.dart';

final StateNotifierProvider<TodoNotifier, TodoState> todoProvider =
    StateNotifierProvider<TodoNotifier, TodoState>((ref) {
  return TodoNotifier(ref.watch(todoRepositoryProvider))..initialize();
});

class TodoState {
  const TodoState({
    this.todos = const <Todo>[],
    this.isLoading = false,
    this.errorMessage,
  });

  final List<Todo> todos;
  final bool isLoading;
  final String? errorMessage;

  TodoState copyWith({
    List<Todo>? todos,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TodoState(
      todos: todos ?? this.todos,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class TodoNotifier extends StateNotifier<TodoState> {
  TodoNotifier(this._repository) : super(const TodoState());

  final TodoRepository _repository;
  bool _didInitialize = false;

  Future<void> initialize() async {
    if (_didInitialize) {
      return;
    }

    _didInitialize = true;
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final List<Todo> todos = await _repository.getTodos();
      _setTodosAndLoading(todos, false);
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to load todos. Is the mock backend running?',
      );
    }
  }

  Future<void> createTodo({
    required String title,
    String? description,
    DateTime? dueDate,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _repository.createTodo(
        title: title,
        description: description,
        dueDate: dueDate,
      );
      final List<Todo> todos = await _repository.getTodos();
      state = state.copyWith(todos: todos, isLoading: false);
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to create todo.',
      );
    }
  }

  Future<void> updateTodo({
    required String id,
    required String title,
    String? description,
    DateTime? dueDate,
  }) async {
    try {
      final Todo updatedTodo = await _repository.updateTodo(id: id, title: title, description: description, dueDate: dueDate);
      final List<Todo> newTodos = state.todos.map((t) => t.id == id ? updatedTodo : t).toList();
      state = state.copyWith(todos: newTodos, clearError: true);
    } catch (error) {
      state = state.copyWith(
        errorMessage: 'Unable to update todo.',
      );
    }
  }

  Future<void> toggleTodoComplete({required String id}) async {
    try {
      final Todo updatedTodo = await _repository.toggleTodoComplete(id: id);
      final List<Todo> newTodos = state.todos.map((t) => t.id == id ? updatedTodo : t).toList();
      state = state.copyWith(todos: newTodos, clearError: true);
    } catch (error) {
      state = state.copyWith(
        errorMessage: 'Unable to toggle todo completion.',
      );
    }
  }

  Future<void> deleteTodo({required String id}) async {
    try {
      await _repository.deleteTodo(id: id);
      final List<Todo> newTodos = state.todos.where((t) => t.id != id).toList();
      state = state.copyWith(todos: newTodos, clearError: true);
    } catch (error) {
      state = state.copyWith(
        errorMessage: 'Unable to delete todo.',
      );
    }
  }

  Future<void> refreshTodos() async {
    try {
      final List<Todo> todos = await _repository.getTodos();
      _setTodosAndLoading(todos, null);
    } catch (error) {
      state = state.copyWith(
        errorMessage: 'Unable to refresh todos.',
      );
    }
  }

  Future<void> toggleTodoPin({required String id}) async {
    try {
      await _repository.toggleTodoPin(id: id);
      final List<Todo> todos = await _repository.getTodos();
      _setTodosAndLoading(todos, null);
    } catch (error) {
      state = state.copyWith(
        errorMessage: 'Unable to pin/unpin todo.',
      );
    }
  }

  void _setTodosAndLoading(List<Todo> todos, bool? isLoading) {
    todos.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.createdAt.compareTo(a.createdAt);
    });
    
    state = state.copyWith(
      todos: todos,
      isLoading: isLoading ?? state.isLoading,
      clearError: true,
    );
  }

  void reorderTodos(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final List<Todo> newTodos = List.of(state.todos);
    final Todo item = newTodos.removeAt(oldIndex);
    newTodos.insert(newIndex, item);
    state = state.copyWith(todos: newTodos);
  }
}
