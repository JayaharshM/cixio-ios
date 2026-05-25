import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../core/models/todo.dart';
import '../../../core/theme/app_colors.dart';
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
        final AppColors c = AppColors.of(context);
        return AlertDialog(
          backgroundColor: c.dialogBg,
          title: Text(
            'Add Todo',
            style: TextStyle(color: c.textPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                style: TextStyle(color: c.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Enter todo title',
                  hintStyle: TextStyle(color: c.textMuted),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: c.border),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: c.accent),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                style: TextStyle(color: c.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Enter description (optional)',
                  hintStyle: TextStyle(color: c.textMuted),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: c.border),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: c.accent),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: c.icon),
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
              child: Text(
                'Add',
                style: TextStyle(color: c.accent),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);
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
      backgroundColor: c.scaffoldBg,
      drawer: const _TodoDrawer(),
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
                                          ?.copyWith(color: c.textMuted),
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
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 24.0),
        child: FloatingActionButton(
          onPressed: _showAddTodoDialog,
          backgroundColor: c.accent,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white),
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

  Widget _buildFloatingButton(BuildContext context, {
    required IconData icon,
    required VoidCallback? onTap,
    Color? color,
  }) {
    final AppColors c = AppColors.of(context);
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color ?? c.surfaceDim,
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
          child: Icon(icon, color: c.textPrimary, size: 24),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);
    return SafeArea(
      bottom: false,
      child: Container(
        height: 66,
        padding: EdgeInsets.symmetric(horizontal: isSearching ? 0 : 16),
        child: isSearching
            ? Row(
                children: [
                  _buildFloatingButton(context,
                    icon: Icons.arrow_back,
                    onTap: onSearchToggle,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: c.surfaceDim,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: TextField(
                        controller: searchController,
                        style: TextStyle(color: c.textPrimary, fontSize: 14),
                        autofocus: true,
                        onChanged: onSearchChanged,
                        textAlignVertical: TextAlignVertical.center,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                          hintText: 'Search todos...',
                          hintStyle: TextStyle(color: c.textMuted, fontSize: 14),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
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
                        border: Border.all(color: c.border),
                      ),
                      child: Icon(
                        Icons.checklist_outlined,
                        color: c.accent,
                        size: 19,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'My Todos',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: c.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                  _buildFloatingButton(context,
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
    final AppColors c = AppColors.of(context);
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
                  color: todo.isPinned ? c.textMuted : c.accent,
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
            color: todo.completed ? c.todoItemDoneBg : c.todoItemBg,
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
                todo.completed ? const Color(0xFF4CAF50) : c.checkboxFill,
              ),
            ),
            title: Text(
              todo.title,
              style: TextStyle(
                color: todo.completed ? c.textMuted : c.textPrimary,
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
                            color: todo.completed ? c.textMuted : c.textSecondary,
                            decoration: todo.completed ? TextDecoration.lineThrough : null,
                            fontSize: 13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (todo.dueDate != null)
                        Text(
                          'Due: ${_formatDate(todo.dueDate!)}',
                          style: TextStyle(
                            color: c.textMuted,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  )
                : null,
            trailing: todo.isPinned
                ? Icon(
                    Icons.push_pin,
                    color: c.accent,
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
  const _TodoDrawer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppColors c = AppColors.of(context);
    final TodoState state = ref.watch(todoProvider);
    final int completedCount =
        state.todos.where((todo) => todo.completed).length;
    final int totalCount = state.todos.length;
    final int toBeDoneCount = totalCount - completedCount;

    return Drawer(
      backgroundColor: c.elevatedCardBg,
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
                          color: c.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Completed: $completedCount / $totalCount',
                    style: TextStyle(color: c.textMuted, fontSize: 14),
                  ),
                ],
              ),
            ),
            Divider(color: c.border),
            Expanded(
              child: ListView(
                children: <Widget>[
                  _drawerTile(context, c, Icons.all_inbox_outlined, c.icon, 'All Todos', totalCount),
                  _drawerTile(context, c, Icons.radio_button_unchecked, const Color(0xFFE89A4B), 'To Be Done', toBeDoneCount),
                  _drawerTile(context, c, Icons.check_circle_outline, const Color(0xFF4CAF50), 'Completed', completedCount),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerTile(BuildContext context, AppColors c, IconData icon, Color iconColor, String title, int count) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title, style: TextStyle(color: c.textPrimary)),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: c.surfaceDim,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          '$count',
          style: TextStyle(color: c.icon, fontSize: 12),
        ),
      ),
    );
  }
}
