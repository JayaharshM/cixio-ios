import 'package:flutter/material.dart';

import '../../../../core/models/message.dart';
import '../../../../core/theme/app_colors.dart';
import 'code_block_widget.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    required this.message,
    super.key,
  });

  final Message message;

  @override
  Widget build(BuildContext context) {
    if (message.isUser) {
      return _UserMessageBubble(message: message);
    }

    return _AssistantMessageBubble(message: message);
  }
}

class _AssistantMessageBubble extends StatelessWidget {
  const _AssistantMessageBubble({required this.message});

  final Message message;

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'SMARTHUB AI',
              style: TextStyle(
                color: c.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: c.assistantBubbleBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: _MessageContent(message: message),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserMessageBubble extends StatelessWidget {
  const _UserMessageBubble({required this.message});

  final Message message;

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(64, 14, 16, 18),
      child: Align(
        alignment: Alignment.centerRight,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 285),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                'You',
                style: TextStyle(
                  color: c.textSecondary,
                  fontFamily: 'monospace',
                  fontSize: 12,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 6),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: c.userBubbleBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    message.content,
                    style: TextStyle(
                      color: c.textPrimary,
                      fontSize: 16,
                      height: 1.45,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageContent extends StatelessWidget {
  const _MessageContent({required this.message});

  final Message message;

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);

    if (message.content.isEmpty && message.isStreaming) {
      return const _TypingIndicator();
    }

    final List<_ContentPart> parts = _parseContent(message.content);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (final _ContentPart part in parts)
          if (part.isCode)
            CodeBlockWidget(filename: part.filename, code: part.content)
          else if (part.content.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                part.content.trimRight(),
                style: TextStyle(
                  color: c.textPrimary,
                  fontSize: 16,
                  height: 1.45,
                  letterSpacing: 0,
                ),
              ),
            ),
        if (message.isStreaming) const _TypingIndicator(compact: true),
      ],
    );
  }

  List<_ContentPart> _parseContent(String content) {
    final RegExp codeFencePattern = RegExp(r'```([^\n`]*)\n([\s\S]*?)```');
    final List<_ContentPart> parts = <_ContentPart>[];
    int cursor = 0;

    for (final RegExpMatch match in codeFencePattern.allMatches(content)) {
      if (match.start > cursor) {
        parts.add(_ContentPart.text(content.substring(cursor, match.start)));
      }

      final String filename = (match.group(1)?.trim().isNotEmpty ?? false)
          ? match.group(1)!.trim()
          : 'Code';
      parts.add(_ContentPart.code(filename, match.group(2) ?? ''));
      cursor = match.end;
    }

    if (cursor < content.length) {
      parts.add(_ContentPart.text(content.substring(cursor)));
    }

    return parts;
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator({this.compact = false});

  final bool compact;

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            for (int index = 0; index < 3; index++)
              Container(
                width: widget.compact ? 4 : 6,
                height: widget.compact ? 4 : 6,
                margin: const EdgeInsets.only(right: 5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.lerp(
                    const Color(0xFF6A647D),
                    const Color(0xFFE5E1F5),
                    ((_controller.value + index * 0.2) % 1),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}


class _ContentPart {
  const _ContentPart._({
    required this.content,
    required this.isCode,
    this.filename = '',
  });

  factory _ContentPart.text(String content) {
    return _ContentPart._(content: content, isCode: false);
  }

  factory _ContentPart.code(String filename, String content) {
    return _ContentPart._(
      content: content,
      isCode: true,
      filename: filename,
    );
  }

  final String content;
  final bool isCode;
  final String filename;
}
