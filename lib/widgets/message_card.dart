import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/message.dart';

class MessageCard extends StatelessWidget {
  const MessageCard({
    super.key,
    required this.message,
    required this.searchQuery,
    required this.isSelectionMode,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
  });

  final Message message;
  final String searchQuery;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final hasImage = (message.imagePath ?? '').isNotEmpty;
    final brutalShadowColor = Colors.black.withValues(alpha: 0.85);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      transform: Matrix4.translationValues(
        isSelected ? -4 : 0,
        isSelected ? -4 : 0,
        0,
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.only(left: 7, top: 7),
              decoration: BoxDecoration(
                color: brutalShadowColor,
                border: Border.all(color: Colors.black, width: 3),
              ),
            ),
          ),
          Material(
            color: isSelected
                ? Theme.of(context).colorScheme.secondary.withValues(alpha: 0.4)
                : Theme.of(context).colorScheme.surface,
            child: InkWell(
              onTap: onTap,
              onLongPress: onLongPress,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isSelectionMode) ...[
                      Checkbox(value: isSelected, onChanged: (_) => onTap()),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            text: _buildHighlightedText(
                              source: message.content,
                              query: searchQuery,
                              defaultStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                              highlightStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                backgroundColor: Color(0xFFFFD400),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            DateFormat(
                              'dd MMM yyyy - HH:mm',
                            ).format(message.updatedAt),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (hasImage) _PreviewImage(path: message.imagePath!),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

TextSpan _buildHighlightedText({
  required String source,
  required String query,
  required TextStyle defaultStyle,
  required TextStyle highlightStyle,
}) {
  if (query.trim().isEmpty) {
    return TextSpan(text: source, style: defaultStyle);
  }

  final lowerSource = source.toLowerCase();
  final lowerQuery = query.toLowerCase();
  final spans = <TextSpan>[];
  var start = 0;

  while (true) {
    final matchIndex = lowerSource.indexOf(lowerQuery, start);
    if (matchIndex == -1) {
      spans.add(TextSpan(text: source.substring(start), style: defaultStyle));
      break;
    }

    if (matchIndex > start) {
      spans.add(
        TextSpan(
          text: source.substring(start, matchIndex),
          style: defaultStyle,
        ),
      );
    }
    spans.add(
      TextSpan(
        text: source.substring(matchIndex, matchIndex + lowerQuery.length),
        style: highlightStyle,
      ),
    );
    start = matchIndex + lowerQuery.length;
  }

  return TextSpan(children: spans, style: defaultStyle);
}

class _PreviewImage extends StatelessWidget {
  const _PreviewImage({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.zero,
      child: Container(
        height: 72,
        width: 72,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 3),
        ),
        child: Image.file(
          File(path),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const ColoredBox(
              color: Colors.black12,
              child: Icon(Icons.broken_image),
            );
          },
        ),
      ),
    );
  }
}
