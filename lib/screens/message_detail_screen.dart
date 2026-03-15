import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/message.dart';
import '../state/message_controller.dart';
import 'message_editor_screen.dart';

class MessageDetailScreen extends StatelessWidget {
  const MessageDetailScreen({super.key, required this.messageId});

  final int messageId;

  @override
  Widget build(BuildContext context) {
    return Consumer<MessageController>(
      builder: (context, controller, _) {
        final message = controller.messages.where((m) => m.id == messageId).fold<
            Message?>(null, (previousValue, element) => element);

        if (message == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('MESSAGE')),
            body: const Center(child: Text('Message not found.')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('MESSAGE'),
            actions: [
              IconButton(
                tooltip: 'Share',
                onPressed: () async {
                  if (!controller.isOnline) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'You are offline. Reconnect before sharing online.',
                        ),
                      ),
                    );
                    return;
                  }
                  try {
                    await controller.shareMessage(message);
                  } catch (_) {
                    if (!context.mounted) {
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Sharing failed. Please try again.'),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.share),
              ),
              IconButton(
                tooltip: 'Edit',
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => MessageEditorScreen(message: message),
                    ),
                  );
                },
                icon: const Icon(Icons.edit),
              ),
              IconButton(
                tooltip: 'Delete',
                onPressed: () => _confirmDelete(context, message),
                icon: const Icon(Icons.delete),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              _BrutalBlock(
                child: Text(
                  message.content,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _BrutalBlock(
                child: Text(
                  'Created: ${DateFormat('dd MMM yyyy - HH:mm').format(message.createdAt)}\n'
                  'Updated: ${DateFormat('dd MMM yyyy - HH:mm').format(message.updatedAt)}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              if ((message.imagePath ?? '').isNotEmpty) ...[
                const SizedBox(height: 10),
                _BrutalBlock(
                  child: Image.file(
                    File(message.imagePath!),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const SizedBox(
                        height: 100,
                        child: Center(child: Text('Image unavailable')),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, Message message) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Delete this message?'),
          content: const Text('This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('DELETE'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !context.mounted) {
      return;
    }
    await context.read<MessageController>().deleteSingle(message.id!);
    if (!context.mounted) {
      return;
    }
    Navigator.of(context).pop();
  }
}

class _BrutalBlock extends StatelessWidget {
  const _BrutalBlock({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            margin: const EdgeInsets.only(left: 8, top: 8),
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(color: Colors.black, width: 3),
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border.all(color: Colors.black, width: 3),
          ),
          child: child,
        ),
      ],
    );
  }
}
