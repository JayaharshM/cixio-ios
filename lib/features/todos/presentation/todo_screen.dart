import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

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
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {});
    });
  }

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
      backgroundColor: const Color(0xFF101415),
      drawer: _TodoDrawer(),
      body: Column(
          children: <Widget>[
            _TodoHeader(
              onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
              isSearching: _isSearching,
              searchController: _searchController,
              onSearchChanged: (value) {
                setState(() {});
              },
              onSearchToggle: () {
                setState(() {
                  _isSearching = !_isSearching;
                  if (!_isSearching) {
                    _searchController.clear();
                  }
                });
              },
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
                          : ReorderableListView.builder(
                              scrollController: _scrollController,
                              padding: const EdgeInsets.fromLTRB(8, 8, 8, 20),
                              itemCount: filteredTodos.length,
                              onReorder: (int oldIndex, int newIndex) {
                                if (_searchController.text.isNotEmpty) return;
                                ref.read(todoProvider.notifier).reorderTodos(oldIndex, newIndex);
                              },
                              proxyDecorator: (Widget child, int index, Animation<double> animation) {
                                return Material(
                                  color: Colors.transparent,
                                  child: child,
                                );
                              },
                              itemBuilder: (context, index) {
                                return _TodoItem(
                                  key: ValueKey(filteredTodos[index].id),
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
  const _TodoHeader({
    required this.onMenuTap,
    required this.isSearching,
    required this.searchController,
    required this.onSearchToggle,
    this.onSearchChanged,
  });

  final VoidCallback onMenuTap;
  final bool isSearching;
  final TextEditingController searchController;
  final VoidCallback onSearchToggle;
  final ValueChanged<String>? onSearchChanged;

  Widget _buildFloatingButton({
    required IconData icon,
    required VoidCallback? onTap,
    Color? color,
  }) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color ?? const Color(0xFF2A2D32),
        shape: BoxShape.circle,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          onTap: onTap,
          child: Icon(icon, color: Colors.white, size: 24),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        height: 66,
        padding: EdgeInsets.symmetric(horizontal: isSearching ? 0 : 16),
        child: isSearching
            ? Row(
                children: [
                  _buildFloatingButton(
                    icon: Icons.arrow_back,
                    onTap: onSearchToggle,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2D32),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: TextField(
                        controller: searchController,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        autofocus: true,
                        onChanged: onSearchChanged,
                        decoration: const InputDecoration(
                          hintText: 'Search todos...',
                          hintStyle: TextStyle(color: Colors.white54, fontSize: 14),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Row(
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
                  _buildFloatingButton(
                    icon: Icons.search,
                    onTap: onSearchToggle,
                  ),
                ],
              ),
      ),
    );
  }
}

class _TodoItem extends ConsumerWidget {
  const _TodoItem({super.key, required this.todo});

  final Todo todo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Slidable(
        key: Key(todo.id),
        startActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.22,
          children: [
            CustomSlidableAction(
              onPressed: (context) {
                ref.read(todoProvider.notifier).toggleTodoPin(id: todo.id);
              },
              backgroundColor: Colors.transparent,
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: todo.isPinned ? const Color(0xFF6B7077) : Colors.indigoAccent.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Icon(
                  todo.isPinned ? Icons.push_pin_outlined : Icons.push_pin,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.22,
          children: [
            CustomSlidableAction(
              onPressed: (context) {
                ref.read(todoProvider.notifier).deleteTodo(id: todo.id);
              },
              backgroundColor: Colors.transparent,
              child: Container(
                margin: const EdgeInsets.only(left: 8),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.delete_outline,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: todo.completed ? const Color(0xFF0F1213) : const Color(0xFF1E2024),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            leading: Checkbox(
              value: todo.completed,
              onChanged: (value) {
                ref.read(todoProvider.notifier).toggleTodoComplete(id: todo.id);
              },
              fillColor: WidgetStateProperty.all(
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
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: (todo.description != null && todo.description!.isNotEmpty) || todo.dueDate != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      if (todo.description != null && todo.description!.isNotEmpty)
                        Text(
                          todo.description!,
                          style: TextStyle(
                            color: todo.completed ? const Color(0xFF6B7077) : const Color(0xFFA3A7AA),
                            decoration: todo.completed ? TextDecoration.lineThrough : null,
                            fontSize: 13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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
            trailing: todo.isPinned
                ? Icon(
                    Icons.push_pin,
                    color: Colors.indigoAccent.shade200,
                    size: 20,
                  )
                : null,
          ),
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
