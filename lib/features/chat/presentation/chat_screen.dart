import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../core/models/chat_session.dart';
import '../providers/chat_provider.dart';
import 'widgets/chat_input_bar.dart';
import 'widgets/message_bubble.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
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
    _searchController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ChatState>(chatProvider, (previous, next) {
      final String previousLastContent = previous?.messages.isNotEmpty == true
          ? previous!.messages.last.content
          : '';
      final String nextLastContent =
          next.messages.isNotEmpty ? next.messages.last.content : '';

      if (previous?.messages.length != next.messages.length ||
          previousLastContent != nextLastContent) {
        _scrollToBottom();
      }
    });

    final ChatState state = ref.watch(chatProvider);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF101415),
      body: Column(
        children: <Widget>[
          _ChatHeader(
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
                ref.read(chatProvider.notifier).clearActiveSession();
              },
            ),
            Expanded(
              child: state.isLoading && state.messages.isEmpty && state.activeSession != null
                  ? const Center(child: CircularProgressIndicator())
                  : state.activeSession == null
                      ? _ChatSessionsList(
                          state: state,
                          searchQuery: _searchController.text,
                        )
                      : RefreshIndicator(
                          onRefresh: () {
                            final ChatSession? session = state.activeSession;
                            if (session == null) {
                              return ref.read(chatProvider.notifier).initialize();
                            }
                            return ref
                                .read(chatProvider.notifier)
                                .selectSession(session);
                          },
                          child: ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.fromLTRB(0, 14, 0, 18),
                            itemCount: state.messages.length,
                            itemBuilder: (context, index) {
                              return MessageBubble(message: state.messages[index]);
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
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            if (state.activeSession != null)
              ChatInputBar(
                enabled: !state.isStreaming && state.activeSession != null,
                onSubmitted: (value) {
                  ref.read(chatProvider.notifier).sendMessage(value);
                },
              ),
        ],
      ),
    );
  }
}

class _ChatHeader extends ConsumerWidget {
  const _ChatHeader({
    required this.state,
    required this.onBackTap,
    required this.isSearching,
    required this.searchController,
    required this.onSearchToggle,
  });

  final ChatState state;
  final VoidCallback onBackTap;
  final bool isSearching;
  final TextEditingController searchController;
  final VoidCallback onSearchToggle;

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
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      bottom: false,
      child: Container(
        height: 66,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: isSearching && state.activeSession == null
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
                        decoration: const InputDecoration(
                          hintText: 'Search chats...',
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
                  if (state.activeSession != null) ...[
              _buildFloatingButton(
                icon: Icons.arrow_back,
                onTap: onBackTap,
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Theme(
                  data: Theme.of(context).copyWith(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                  ),
                  child: PopupMenuButton<bool>(
                    offset: const Offset(0, 40),
                    color: const Color(0xFF2A2D32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  initialValue: state.isRagEnabled,
                  onSelected: (bool value) {
                    ref.read(chatProvider.notifier).setRagEnabled(value);
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<bool>>[
                    PopupMenuItem<bool>(
                      value: true,
                      child: Row(
                        children: [
                          Icon(
                            Icons.check,
                            color: state.isRagEnabled ? Colors.indigoAccent.shade200 : Colors.transparent,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          const Text('RAG On', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                    PopupMenuItem<bool>(
                      value: false,
                      child: Row(
                        children: [
                          Icon(
                            Icons.check,
                            color: !state.isRagEnabled ? Colors.indigoAccent.shade200 : Colors.transparent,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          const Text('RAG Off', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  ],
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'SmartHub',
                        style: TextStyle(
                          color: Color(0xFFE9E5F5),
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white.withValues(alpha: 0.5), size: 24),
                    ],
                  ),
                ), // Close PopupMenuButton
                ), // Close Theme
              ), // Close Align
            ), // Close Expanded
            if (state.activeSession == null) ...[
              _buildFloatingButton(
                icon: Icons.search,
                onTap: onSearchToggle,
              ),
              const SizedBox(width: 12),
              _buildFloatingButton(
                icon: Icons.add,
                color: Colors.indigoAccent.shade200,
                onTap: state.isStreaming
                    ? null
                    : () {
                        ref.read(chatProvider.notifier).createNewSession();
                      },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ChatSessionsList extends ConsumerWidget {
  const _ChatSessionsList({
    required this.state,
    required this.searchQuery,
  });

  final ChatState state;
  final String searchQuery;

  Map<String, List<ChatSession>> _groupSessions(List<ChatSession> sessions) {
    final Map<String, List<ChatSession>> grouped = {
      'PINNED': [],
      'TODAY': [],
      'YESTERDAY': [],
      'LAST WEEK': [],
    };

    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime yesterday = today.subtract(const Duration(days: 1));
    final DateTime lastWeek = today.subtract(const Duration(days: 7));

    for (final session in sessions) {
      if (searchQuery.isNotEmpty && !session.title.toLowerCase().contains(searchQuery.toLowerCase())) {
        continue;
      }

      final DateTime sessionDate = session.createdAt.toLocal();
      final DateTime dateOnly = DateTime(sessionDate.year, sessionDate.month, sessionDate.day);

      if (session.isPinned) {
        grouped['PINNED']!.add(session);
      } else if (dateOnly == today) {
        grouped['TODAY']!.add(session);
      } else if (dateOnly == yesterday) {
        grouped['YESTERDAY']!.add(session);
      } else if (dateOnly.isAfter(lastWeek) || dateOnly == lastWeek) {
        grouped['LAST WEEK']!.add(session);
      } else {
        // Add older to last week for now
        grouped['LAST WEEK']!.add(session);
      }
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Map<String, List<ChatSession>> groupedSessions = _groupSessions(state.sessions);

    return Column(
          children: <Widget>[
            // Sessions List
            Expanded(
              child: state.sessions.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'No sessions yet',
                        style: TextStyle(color: Color(0xFF6B7077)),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: groupedSessions.entries.map((entry) {
                        if (entry.value.isEmpty) return const SizedBox.shrink();
                        
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 16, bottom: 8),
                              child: Text(
                                entry.key,
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                            ...entry.value.map((session) {
                              final bool isActive = state.activeSession?.id == session.id;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Slidable(
                                  key: Key(session.id),
                                  startActionPane: ActionPane(
                                    motion: const ScrollMotion(),
                                    extentRatio: 0.22,
                                    children: [
                                      CustomSlidableAction(
                                        onPressed: (context) {
                                          ref.read(chatProvider.notifier).togglePinSession(session.id);
                                        },
                                        backgroundColor: Colors.transparent,
                                        child: Container(
                                          margin: const EdgeInsets.only(right: 8),
                                          decoration: BoxDecoration(
                                            color: session.isPinned ? const Color(0xFF6B7077) : Colors.indigoAccent.shade200,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          alignment: Alignment.center,
                                          child: Icon(
                                            session.isPinned ? Icons.push_pin_outlined : Icons.push_pin,
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
                                          ref.read(chatProvider.notifier).deleteSession(session.id);
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
                                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: isActive ? const Color(0xFF2A2D32) : const Color(0xFF1E2024),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        ref.read(chatProvider.notifier).selectSession(session);
                                      },
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF2A2D32),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                              Icons.chat_bubble_outline,
                                              color: Colors.white70,
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  session.title,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 4),
                                                const Text(
                                                  'Session started...',
                                                  style: TextStyle(
                                                    color: Colors.white54,
                                                    fontSize: 12,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        );
                      }).toList(),
                    ),
            ),
          ],
        );
  }
}
