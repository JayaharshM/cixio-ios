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
      state = state.copyWith(todos: todos, isLoading: false);
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to load todos. Is the mock backend running?',
      );
    }
  }

  Future<void> createTodo({
    required String title,
    DateTime? dueDate,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _repository.createTodo(
        title: title,
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
    DateTime? dueDate,
  }) async {
    try {
      await _repository.updateTodo(id: id, title: title, dueDate: dueDate);
      final List<Todo> todos = await _repository.getTodos();
      state = state.copyWith(todos: todos, clearError: true);
    } catch (error) {
      state = state.copyWith(
        errorMessage: 'Unable to update todo.',
      );
    }
  }

  Future<void> toggleTodoComplete({required String id}) async {
    try {
      await _repository.toggleTodoComplete(id: id);
      final List<Todo> todos = await _repository.getTodos();
      state = state.copyWith(todos: todos, clearError: true);
    } catch (error) {
      state = state.copyWith(
        errorMessage: 'Unable to toggle todo completion.',
      );
    }
  }

  Future<void> deleteTodo({required String id}) async {
    try {
      await _repository.deleteTodo(id: id);
      final List<Todo> todos = await _repository.getTodos();
      state = state.copyWith(todos: todos, clearError: true);
    } catch (error) {
      state = state.copyWith(
        errorMessage: 'Unable to delete todo.',
      );
    }
  }

  Future<void> refreshTodos() async {
    try {
      final List<Todo> todos = await _repository.getTodos();
      state = state.copyWith(todos: todos, clearError: true);
    } catch (error) {
      state = state.copyWith(
        errorMessage: 'Unable to refresh todos.',
      );
    }
  }
}
