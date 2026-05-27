import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../core/models/todo.dart';
import '../../../core/models/todo_section.dart';
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

  void _showAddSectionDialog() {
    _titleController.clear();
    showDialog<void>(
      context: context,
      builder: (context) {
        final AppColors c = AppColors.of(context);
        return AlertDialog(
          backgroundColor: c.dialogBg,
          title: Text(
            'New Todo List',
            style: TextStyle(color: c.textPrimary),
          ),
          content: TextField(
            controller: _titleController,
            style: TextStyle(color: c.textPrimary),
            decoration: InputDecoration(
              hintText: 'Enter list name',
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
                  ref.read(todoProvider.notifier).createSection(_titleController.text);
                  Navigator.pop(context);
                }
              },
              child: Text(
                'Create',
                style: TextStyle(color: c.accent),
              ),
            ),
          ],
        );
      },
    );
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

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: c.scaffoldBg,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 24.0),
        child: FloatingActionButton(
          onPressed: state.activeSection == null ? _showAddSectionDialog : _showAddTodoDialog,
          backgroundColor: c.accent,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      body: Column(
        children: <Widget>[
          _TodoHeader(
            state: state,
            isSearching: _isSearching,
            searchController: _searchController,
            onSearchToggle: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                }
              });
            },
            onBackTap: () {
              setState(() {
                _isSearching = false;
                _searchController.clear();
              });
              ref.read(todoProvider.notifier).clearActiveSection();
            },
          ),
          Expanded(
            child: state.isLoading && state.sections.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : state.activeSection == null
                    ? _TodoSectionsList(
                        state: state,
                        searchQuery: _searchController.text,
                      )
                    : _TodoItemsList(
                        state: state,
                        searchQuery: _searchController.text,
                        scrollController: _scrollController,
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
    );
  }
}

class _TodoHeader extends ConsumerWidget {
  const _TodoHeader({
    required this.state,
    required this.onBackTap,
    required this.isSearching,
    required this.searchController,
    required this.onSearchToggle,
  });

  final TodoState state;
  final VoidCallback onBackTap;
  final bool isSearching;
  final TextEditingController searchController;
  final VoidCallback onSearchToggle;

  Widget _buildFloatingButton(BuildContext context, {
    required IconData icon,
    required VoidCallback? onTap,
    Color? color,
  }) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color ?? AppColors.of(context).surfaceDim,
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
          onTap: onTap,
          child: Icon(icon, color: AppColors.of(context).textPrimary, size: 24),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      bottom: false,
      child: Container(
        height: 66,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: isSearching && state.activeSection == null
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
                        color: AppColors.of(context).surfaceDim,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: TextField(
                        controller: searchController,
                        style: TextStyle(color: AppColors.of(context).textPrimary, fontSize: 14),
                        autofocus: true,
                        textAlignVertical: TextAlignVertical.center,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                          hintText: 'Search lists...',
                          hintStyle: TextStyle(color: AppColors.of(context).textMuted, fontSize: 14),
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
                  if (state.activeSection != null) ...[
                    _buildFloatingButton(context,
                      icon: Icons.arrow_back,
                      onTap: onBackTap,
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Text(
                      state.activeSection?.title ?? 'Todo Lists',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.of(context).textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                  if (state.activeSection == null) ...[
                    _buildFloatingButton(context,
                      icon: Icons.search,
                      onTap: onSearchToggle,
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}

class _TodoSectionsList extends ConsumerWidget {
  const _TodoSectionsList({
    required this.state,
    required this.searchQuery,
  });

  final TodoState state;
  final String searchQuery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<TodoSection> filteredSections = searchQuery.isEmpty
        ? state.sections
        : state.sections
            .where((s) => s.title.toLowerCase().contains(searchQuery.toLowerCase()))
            .toList();

    if (filteredSections.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'No todo lists yet',
          style: TextStyle(color: Color(0xFF6B7077)),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: filteredSections.length,
      itemBuilder: (context, index) {
        final TodoSection section = filteredSections[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Slidable(
            key: Key(section.id),
            startActionPane: ActionPane(
              motion: const ScrollMotion(),
              extentRatio: 0.22,
              children: [
                CustomSlidableAction(
                  onPressed: (context) {
                    ref.read(todoProvider.notifier).togglePinSection(section.id);
                  },
                  backgroundColor: Colors.transparent,
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: section.isPinned ? const Color(0xFF6B7077) : AppColors.of(context).accent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      section.isPinned ? Icons.push_pin_outlined : Icons.push_pin,
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
                    ref.read(todoProvider.notifier).deleteSection(section.id);
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
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.of(context).cardBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () {
                  ref.read(todoProvider.notifier).selectSection(section);
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.list_alt_rounded,
                      color: AppColors.of(context).icon,
                      size: 24,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        section.title,
                        style: TextStyle(
                          color: AppColors.of(context).textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (section.isPinned)
                      Icon(
                        Icons.push_pin,
                        color: AppColors.of(context).accent,
                        size: 20,
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TodoItemsList extends ConsumerWidget {
  const _TodoItemsList({
    required this.state,
    required this.searchQuery,
    required this.scrollController,
  });

  final TodoState state;
  final String searchQuery;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Todo> filteredTodos = searchQuery.isEmpty
        ? state.todos
        : state.todos
            .where((todo) => todo.title.toLowerCase().contains(searchQuery.toLowerCase()))
            .toList();

    return RefreshIndicator(
      onRefresh: () => ref.read(todoProvider.notifier).refreshTodos(),
      child: filteredTodos.isEmpty
          ? ListView(
              controller: scrollController,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Text(
                      'No todos yet',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.of(context).textMuted),
                    ),
                  ),
                ),
              ],
            )
          : ReorderableListView.builder(
              scrollController: scrollController,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: filteredTodos.length,
              onReorder: (int oldIndex, int newIndex) {
                if (searchQuery.isNotEmpty) return;
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
