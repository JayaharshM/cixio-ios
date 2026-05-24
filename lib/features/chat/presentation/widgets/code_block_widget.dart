import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CodeBlockWidget extends StatelessWidget {
  const CodeBlockWidget({
    required this.filename,
    required this.code,
    super.key,
  });

  final String filename;
  final String code;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1320),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1E2740)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: const BoxDecoration(
              color: Color(0xFF172035),
              border: Border(
                bottom: BorderSide(color: Color(0xFF23304C)),
              ),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    filename,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFE1DCF6),
                      fontFamily: 'monospace',
                      fontSize: 12,
                      letterSpacing: 0,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Copy code',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: code));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Code copied')),
                    );
                  },
                  icon: const Icon(Icons.copy_outlined, size: 18),
                  color: const Color(0xFFD5D1E6),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 32,
                    height: 32,
                  ),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: Color(0xFFE8E4F3),
                  fontFamily: 'monospace',
                  fontSize: 13,
                  height: 1.65,
                  letterSpacing: 0,
                ),
                children: _highlight(code),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<TextSpan> _highlight(String source) {
    final RegExp tokenPattern = RegExp(
      r"""\b(import|export|default|function|const|let|var|return|from|async|await|try|catch|if|else|class|final|required)\b|("[^"]*"|'[^']*')|(\b[A-Z][A-Za-z0-9_]*\b)|(//.*)""",
    );
    final List<TextSpan> spans = <TextSpan>[];
    int cursor = 0;

    for (final RegExpMatch match in tokenPattern.allMatches(source)) {
      if (match.start > cursor) {
        spans.add(TextSpan(text: source.substring(cursor, match.start)));
      }

      final String token = source.substring(match.start, match.end);
      final Color color = match.group(1) != null
          ? const Color(0xFFC49BFF)
          : match.group(2) != null
              ? const Color(0xFFFFB3C7)
              : match.group(3) != null
                  ? const Color(0xFF8DB7FF)
                  : const Color(0xFF7D879C);

      spans.add(TextSpan(text: token, style: TextStyle(color: color)));
      cursor = match.end;
    }

    if (cursor < source.length) {
      spans.add(TextSpan(text: source.substring(cursor)));
    }

    return spans;
  }
}
