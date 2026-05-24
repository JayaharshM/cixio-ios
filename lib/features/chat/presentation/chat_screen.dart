import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF2B3033)),
                ),
                child: const Icon(
                  Icons.smart_toy_outlined,
                  color: Color(0xFFD9D4FF),
                  size: 19,
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      backgroundColor: const Color(0xFF151819),
      child: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: state.isStreaming
                      ? null
                      : () {
                          ref
                              .read(chatProvider.notifier)
                              .createNewSession();
                          Navigator.pop(context);
                        },
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('New chat'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2A2F32),
                    foregroundColor: const Color(0xFFE9E5F5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search chats',
                  hintStyle: const TextStyle(color: Color(0xFF6B7077)),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF6B7077),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0xFF2A2F32),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0xFF2A2F32),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0xFF3F484D),
                    ),
                  ),
                ),
                style: const TextStyle(color: Color(0xFFE9E5F5)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Recents',
                  style: TextStyle(
                    color: const Color(0xFFE9E5F5),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Expanded(
              child: state.sessions.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'No sessions yet',
                        style: TextStyle(
                          color: const Color(0xFF6B7077),
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: state.sessions.length,
                      itemBuilder: (context, index) {
                        final ChatSession session = state.sessions[index];
                        final bool isActive =
                            state.activeSession?.id == session.id;

                        return Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isActive
                                ? const Color(0xFF2A2F32)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListTile(
                            title: Text(
                              session.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFFE9E5F5),
                                fontSize: 14,
                              ),
                            ),
                            trailing: GestureDetector(
                              onTap: () {
                                ref
                                    .read(chatProvider.notifier)
                                    .deleteSession(session.id);
                                Navigator.pop(context);
                              },
                              child: const Icon(
                                Icons.more_vert,
                                color: Color(0xFF6B7077),
                                size: 18,
                              ),
                            ),
                            onTap: () {
                              ref
                                  .read(chatProvider.notifier)
                                  .selectSession(session);
                              Navigator.pop(context);
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
