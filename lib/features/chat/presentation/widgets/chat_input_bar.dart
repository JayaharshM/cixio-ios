import 'package:flutter/material.dart';

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
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xFF121418), // Match background
      ),
      child: SafeArea(
        top: false,
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF15181B), // Dark input background
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF5B4DFF).withOpacity(0.5), // Purple border
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF5B4DFF).withOpacity(0.15),
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
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: widget.enabled
                    ? 'Ask SmartHub AI...'
                    : 'SmartHub AI is responding...',
                hintStyle: const TextStyle(color: Colors.white54),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                prefixIcon: const Icon(
                  Icons.add,
                  color: Colors.white54,
                  size: 28,
                ),
                suffixIcon: IconButton(
                  tooltip: 'Send',
                  onPressed: widget.enabled ? _submit : null,
                  icon: const Icon(Icons.send_outlined),
                  color: const Color(0xFF8B7FFF), // Light purple send icon
                  disabledColor: const Color(0xFF2D3040),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
