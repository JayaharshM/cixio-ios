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

  @override
  void dispose() {
    _scrollController.dispose();
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
      drawer: _ChatDrawer(state: state),
      body: DecoratedBox(
        decoration: const BoxDecoration(color: Color(0xFF101415)),
        child: Column(
          children: <Widget>[
            _ChatHeader(
              state: state,
              onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            Expanded(
              child: state.isLoading && state.messages.isEmpty
                  ? const Center(child: CircularProgressIndicator())
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
            ChatInputBar(
              enabled: !state.isStreaming && state.activeSession != null,
              onSubmitted: (value) {
                ref.read(chatProvider.notifier).sendMessage(value);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatHeader extends ConsumerWidget {
  const _ChatHeader({
    required this.state,
    required this.onMenuTap,
  });

  final ChatState state;
  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2D32), // Dark grey square
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.menu,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'SmartHub',
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

class _ChatDrawer extends ConsumerWidget {
  const _ChatDrawer({required this.state});

  final ChatState state;

  String _getMonth(int month) {
    const List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  Map<String, List<ChatSession>> _groupSessions(List<ChatSession> sessions) {
    final Map<String, List<ChatSession>> grouped = {
      'TODAY': [],
      'YESTERDAY': [],
      'LAST WEEK': [],
    };

    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime yesterday = today.subtract(const Duration(days: 1));
    final DateTime lastWeek = today.subtract(const Duration(days: 7));

    for (final session in sessions) {
      final DateTime sessionDate = session.createdAt.toLocal();
      final DateTime dateOnly = DateTime(sessionDate.year, sessionDate.month, sessionDate.day);

      if (dateOnly == today) {
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

    return Drawer(
      backgroundColor: const Color(0xFF151819),
      child: SafeArea(
        child: Column(
          children: <Widget>[
            // Search + New Chat Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search conversations...',
                        hintStyle: const TextStyle(color: Color(0xFF6B7077)),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Color(0xFF6B7077),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF2A2F32)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF2A2F32)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF3F484D)),
                        ),
                        filled: true,
                        fillColor: const Color(0xFF1E2024),
                      ),
                      style: const TextStyle(color: Color(0xFFE9E5F5)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.indigoAccent.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: state.isStreaming
                          ? null
                          : () {
                              ref.read(chatProvider.notifier).createNewSession();
                              Navigator.pop(context);
                            },
                      icon: const Icon(Icons.add, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            
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
                                        Navigator.pop(context);
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
        ),
      ),
    );
  }
}
