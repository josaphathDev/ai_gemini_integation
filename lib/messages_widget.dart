import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class Messages extends StatelessWidget {
  const Messages({
    super.key,
    required this.text,
    required this.isFromUser,
  });
  final String text;
  final bool isFromUser;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(child: Container( 
          padding: EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 20,
          ),
          margin: EdgeInsets.only(bottom: 8),
          constraints: const BoxConstraints(maxWidth: 520),decoration: BoxDecoration(
          color: isFromUser
          ?Theme.of(context).colorScheme.primary
          :Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(18),

        ),
          child: MarkdownBody(data:text),))
      ],
    );
  }
}
