import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/todo.dart';
import '../../../core/models/todo_section.dart';
import '../data/todo_repository.dart';

final StateNotifierProvider<TodoNotifier, TodoState> todoProvider =
    StateNotifierProvider<TodoNotifier, TodoState>((ref) {
  return TodoNotifier(ref.watch(todoRepositoryProvider))..initialize();
});

class TodoState {
  const TodoState({
    this.sections = const <TodoSection>[],
    this.todos = const <Todo>[],
    this.activeSection,
    this.isLoading = false,
    this.errorMessage,
  });

  final List<TodoSection> sections;
  final List<Todo> todos;
  final TodoSection? activeSection;
  final bool isLoading;
  final String? errorMessage;

  TodoState copyWith({
    List<TodoSection>? sections,
    List<Todo>? todos,
    TodoSection? activeSection,
    bool clearActiveSection = false,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TodoState(
      sections: sections ?? this.sections,
      todos: todos ?? this.todos,
      activeSection:
          clearActiveSection ? null : activeSection ?? this.activeSection,
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
      final List<TodoSection> sections = await _repository.getSections();
      state = state.copyWith(
        sections: sections,
        clearActiveSection: true,
        todos: const <Todo>[],
        isLoading: false,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to load todo sections. Is the mock backend running?',
      );
    }
  }

  Future<void> selectSection(TodoSection section) async {
    if (state.activeSection?.id == section.id) {
      return;
    }

    state = state.copyWith(
      activeSection: section,
      todos: const <Todo>[],
      isLoading: true,
      clearError: true,
    );

    try {
      final List<Todo> todos = await _repository.getTodos(section.id);
      _setTodosAndLoading(todos, false);
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to load this todo list.',
      );
    }
  }

  Future<void> createSection(String title) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final TodoSection section = await _repository.createSection(title);
      final List<TodoSection> sections = await _repository.getSections();
      final List<Todo> todos = await _repository.getTodos(section.id);

      state = state.copyWith(
        sections: sections,
        activeSection: section,
        todos: todos,
        isLoading: false,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to create a new todo list.',
      );
    }
  }

  Future<void> deleteSection(String id) async {
    final TodoSection? activeSection = state.activeSection;

    try {
      await _repository.deleteSection(id);
      List<TodoSection> sections = await _repository.getSections();

      if (sections.isEmpty) {
        state = state.copyWith(
          sections: sections,
          clearActiveSection: true,
          todos: const <Todo>[],
          clearError: true,
        );
        return;
      }

      if (activeSection?.id == id) {
        state = state.copyWith(
          sections: sections,
          clearActiveSection: true,
          todos: const <Todo>[],
          clearError: true,
        );
      } else {
        state = state.copyWith(
          sections: sections,
          clearError: true,
        );
      }
    } catch (error) {
      state = state.copyWith(errorMessage: 'Unable to delete todo list.');
    }
  }

  Future<void> togglePinSection(String id) async {
    try {
      await _repository.togglePinSection(id);
      List<TodoSection> sections = await _repository.getSections();
      
      state = state.copyWith(
        sections: sections,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(errorMessage: 'Unable to pin/unpin todo list.');
    }
  }

  void clearActiveSection() {
    state = state.copyWith(
      clearActiveSection: true,
      todos: const <Todo>[],
      clearError: true,
    );
  }

  Future<void> createTodo({
    required String title,
    String? description,
    DateTime? dueDate,
  }) async {
    final TodoSection? section = state.activeSection;
    if (section == null) return;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _repository.createTodo(
        sectionId: section.id,
        title: title,
        description: description,
        dueDate: dueDate,
      );
      final List<Todo> todos = await _repository.getTodos(section.id);
      _setTodosAndLoading(todos, false);
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
    final TodoSection? section = state.activeSection;
    if (section == null) return;

    try {
      final List<Todo> todos = await _repository.getTodos(section.id);
      _setTodosAndLoading(todos, null);
    } catch (error) {
      state = state.copyWith(
        errorMessage: 'Unable to refresh todos.',
      );
    }
  }

  Future<void> toggleTodoPin({required String id}) async {
    final TodoSection? section = state.activeSection;
    if (section == null) return;

    try {
      await _repository.toggleTodoPin(id: id);
      final List<Todo> todos = await _repository.getTodos(section.id);
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
