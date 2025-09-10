import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:realm/model/chat.dart';

class MessageBubble extends StatelessWidget {
  final ChatModel message;
  final void Function()? onDelete;
  const MessageBubble({super.key, required this.message, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (details) {
        final offset = details.globalPosition;
        !message.isSentByMe
            ? null
            : showMenu(
                context: context,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(20),
                ),
                position: RelativeRect.fromLTRB(
                  offset.dx,
                  offset.dy,
                  MediaQuery.of(context).size.width - offset.dx,
                  MediaQuery.of(context).size.height - offset.dy,
                ),
                items: [
                  PopupMenuItem(
                    onTap: onDelete,
                    value: 'delete',
                    child: Text('Unsend'),
                  ),
                  PopupMenuItem(
                    onTap: () async {
                      await Clipboard.setData(
                        ClipboardData(text: message.text),
                      );
                    },
                    value: 'copy',
                    child: Text('Copy'),
                  ),
                ],
              );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisAlignment: message.isSentByMe
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            // if (!message.isSentByMe) const SizedBox(width: 40),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: message.isSentByMe
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSecondary,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: Radius.circular(message.isSentByMe ? 20 : 4),
                    bottomRight: Radius.circular(message.isSentByMe ? 4 : 20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.text,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: message.isSentByMe
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          message.time,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.color,
                              ),
                        ),
                        if (message.isSentByMe) ...[
                          const SizedBox(width: 4),
                          Icon(
                            message.isRead ? Icons.done_all : Icons.done,
                            size: 14,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // if (message.isSentByMe) const SizedBox(width: 40),
          ],
        ),
      ),
    );
  }
}
