import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/todo.dart';
import '../providers/todo_provider.dart';

class TodoScreen extends ConsumerStatefulWidget {
  const TodoScreen({super.key});

  @override
  ConsumerState<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends ConsumerState<TodoScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _scrollController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showAddTodoDialog() {
    _titleController.clear();
    _descriptionController.clear();
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1F21),
          title: const Text(
            'Add Todo',
            style: TextStyle(color: Color(0xFFE9E5F5)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                style: const TextStyle(color: Color(0xFFE9E5F5)),
                decoration: InputDecoration(
                  hintText: 'Enter todo title',
                  hintStyle: const TextStyle(color: Color(0xFF6B7077)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF2A2F32)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF3F484D)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                style: const TextStyle(color: Color(0xFFE9E5F5)),
                decoration: InputDecoration(
                  hintText: 'Enter description (optional)',
                  hintStyle: const TextStyle(color: Color(0xFF6B7077)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF2A2F32)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF3F484D)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFFD3CEE2)),
              ),
            ),
            TextButton(
              onPressed: () {
                if (_titleController.text.isNotEmpty) {
                  ref.read(todoProvider.notifier).createTodo(
                        title: _titleController.text,
                        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
                      );
                  Navigator.pop(context);
                }
              },
              child: const Text(
                'Add',
                style: TextStyle(color: Color(0xFFD9D4FF)),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final TodoState state = ref.watch(todoProvider);
    final List<Todo> filteredTodos = _searchController.text.isEmpty
        ? state.todos
        : state.todos
            .where((todo) => todo.title
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()))
            .toList();

    return Scaffold(
      key: _scaffoldKey,
      drawer: _TodoDrawer(),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              Color(0xFF101415),
              Color(0xFF070A12),
            ],
          ),
        ),
        child: Column(
          children: <Widget>[
            _TodoHeader(
              onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Color(0xFFE9E5F5)),
                onChanged: (value) {
                  setState(() {});
                },
                decoration: InputDecoration(
                  hintText: 'Search todos',
                  hintStyle: const TextStyle(color: Color(0xFF6B7077)),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF6B7077),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF2A2F32)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF2A2F32)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF3F484D)),
                  ),
                ),
              ),
            ),
            Expanded(
              child: state.isLoading && state.todos.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: () =>
                          ref.read(todoProvider.notifier).refreshTodos(),
                      child: filteredTodos.isEmpty
                          ? ListView(
                              controller: _scrollController,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(32),
                                  child: Center(
                                    child: Text(
                                      'No todos yet',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            color: const Color(0xFF6B7077),
                                          ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.fromLTRB(8, 8, 8, 20),
                              itemCount: filteredTodos.length,
                              itemBuilder: (context, index) {
                                return _TodoItem(
                                  todo: filteredTodos[index],
                                );
                              },
                            ),
                    ),
            ),
            if (state.errorMessage != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  state.errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTodoDialog,
        backgroundColor: const Color(0xFFD9D4FF),
        child: const Icon(
          Icons.add,
          color: Color(0xFF101415),
        ),
      ),
    );
  }
}

class _TodoHeader extends StatelessWidget {
  const _TodoHeader({required this.onMenuTap});

  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        height: 66,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: const BoxDecoration(
          color: Color(0xFF151819),
          border: Border(
            bottom: BorderSide(color: Color(0xFF2A2F32)),
          ),
        ),
        child: Row(
          children: <Widget>[
            GestureDetector(
              onTap: onMenuTap,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF2B3033)),
                ),
                child: const Icon(
                  Icons.checklist_outlined,
                  color: Color(0xFFD9D4FF),
                  size: 19,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'My Todos',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Color(0xFFE9E5F5),
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodoItem extends ConsumerWidget {
  const _TodoItem({required this.todo});

  final Todo todo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color:
            todo.completed ? const Color(0xFF0F1213) : const Color(0xFF1A1F21),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: todo.completed
              ? const Color(0xFF2A2F32)
              : const Color(0xFF2A2F32),
        ),
      ),
      child: ListTile(
        leading: Checkbox(
          value: todo.completed,
          onChanged: (value) {
            ref.read(todoProvider.notifier).toggleTodoComplete(id: todo.id);
          },
          fillColor: MaterialStateProperty.all(
            todo.completed ? const Color(0xFF4CAF50) : const Color(0xFF2A2F32),
          ),
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            color: todo.completed
                ? const Color(0xFF6B7077)
                : const Color(0xFFE9E5F5),
            decoration: todo.completed ? TextDecoration.lineThrough : null,
            fontSize: 14,
          ),
        ),
        subtitle: (todo.description != null && todo.description!.isNotEmpty) || todo.dueDate != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (todo.description != null && todo.description!.isNotEmpty)
                    Text(
                      todo.description!,
                      style: TextStyle(
                        color: todo.completed ? const Color(0xFF6B7077) : const Color(0xFFA3A7AA),
                        decoration: todo.completed ? TextDecoration.lineThrough : null,
                        fontSize: 13,
                      ),
                    ),
                  if (todo.dueDate != null)
                    Text(
                      'Due: ${_formatDate(todo.dueDate!)}',
                      style: const TextStyle(
                        color: Color(0xFF6B7077),
                        fontSize: 12,
                      ),
                    ),
                ],
              )
            : null,
        trailing: IconButton(
          icon: const Icon(
            Icons.delete_outline,
            color: Color(0xFFE84B4B),
            size: 20,
          ),
          onPressed: () {
            ref.read(todoProvider.notifier).deleteTodo(id: todo.id);
          },
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _TodoDrawer extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TodoState state = ref.watch(todoProvider);
    final int completedCount =
        state.todos.where((todo) => todo.completed).length;
    final int totalCount = state.todos.length;
    final int toBeDoneCount = totalCount - completedCount;

    return Drawer(
      backgroundColor: const Color(0xFF151819),
      child: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'My Todos',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: const Color(0xFFE9E5F5),
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Completed: $completedCount / $totalCount',
                    style: const TextStyle(
                      color: Color(0xFF6B7077),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Color(0xFF2A2F32)),
            Expanded(
              child: ListView(
                children: <Widget>[
                  ListTile(
                    leading: const Icon(
                      Icons.all_inbox_outlined,
                      color: Color(0xFFD3CEE2),
                    ),
                    title: const Text(
                      'All Todos',
                      style: TextStyle(color: Color(0xFFE9E5F5)),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2F32),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '$totalCount',
                        style: const TextStyle(
                          color: Color(0xFFD3CEE2),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.radio_button_unchecked,
                      color: Color(0xFFE89A4B),
                    ),
                    title: const Text(
                      'To Be Done',
                      style: TextStyle(color: Color(0xFFE9E5F5)),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2F32),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '$toBeDoneCount',
                        style: const TextStyle(
                          color: Color(0xFFD3CEE2),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.check_circle_outline,
                      color: Color(0xFF4CAF50),
                    ),
                    title: const Text(
                      'Completed',
                      style: TextStyle(color: Color(0xFFE9E5F5)),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2F32),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '$completedCount',
                        style: const TextStyle(
                          color: Color(0xFFD3CEE2),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
