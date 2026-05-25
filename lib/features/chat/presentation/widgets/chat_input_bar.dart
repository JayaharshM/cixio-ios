import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class ChatInputBar extends StatefulWidget {
  const ChatInputBar({
    required this.onSubmitted,
    required this.enabled,
    super.key,
  });

  final ValueChanged<String> onSubmitted;
  final bool enabled;

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final String value = _controller.text.trim();
    if (value.isEmpty || !widget.enabled) {
      return;
    }

    _controller.clear();
    widget.onSubmitted(value);
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.scaffoldBg,
      ),
      child: SafeArea(
        top: false,
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 16),
          child: Container(
            decoration: BoxDecoration(
              color: c.inputBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: c.chatInputBorder,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: c.chatInputGlow,
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: TextField(
              controller: _controller,
              enabled: widget.enabled,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _submit(),
              style: TextStyle(color: c.textPrimary),
              decoration: InputDecoration(
                hintText: widget.enabled
                    ? 'Ask SmartHub AI...'
                    : 'SmartHub AI is responding...',
                hintStyle: TextStyle(color: c.textMuted),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                prefixIcon: Icon(
                  Icons.add,
                  color: c.textMuted,
                  size: 28,
                ),
                suffixIcon: IconButton(
                  tooltip: 'Send',
                  onPressed: widget.enabled ? _submit : null,
                  icon: const Icon(Icons.send_outlined),
                  color: c.accent,
                  disabledColor: c.iconMuted,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
