import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/message.dart';
import '../state/message_controller.dart';
import '../widgets/message_card.dart';
import 'message_detail_screen.dart';
import 'message_editor_screen.dart';

class MessagesHomeScreen extends StatefulWidget {
  const MessagesHomeScreen({super.key});

  @override
  State<MessagesHomeScreen> createState() => _MessagesHomeScreenState();
}

class _MessagesHomeScreenState extends State<MessagesHomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MessageController>(
      builder: (context, controller, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              controller.isSelectionMode
                  ? 'SELECT ${controller.selectedIds.length}'
                  : 'BRUTAL BLOG',
            ),
            actions: [
              if (controller.isSelectionMode) ...[
                IconButton(
                  tooltip: 'Select all',
                  onPressed: controller.selectAllVisible,
                  icon: const Icon(Icons.done_all),
                ),
                IconButton(
                  tooltip: 'Clear selection',
                  onPressed: controller.clearSelection,
                  icon: const Icon(Icons.clear_all),
                ),
                IconButton(
                  tooltip: 'Delete selected',
                  onPressed: controller.selectedIds.isEmpty
                      ? null
                      : () => _confirmBulkDelete(context),
                  icon: const Icon(Icons.delete),
                ),
                IconButton(
                  tooltip: 'Exit select mode',
                  onPressed: () => controller.toggleSelectionMode(false),
                  icon: const Icon(Icons.close),
                ),
              ],
            ],
          ),
          body: Column(
            children: [
              _ConnectivityBanner(isOnline: controller.isOnline),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                child: TextField(
                  controller: _searchController,
                  onChanged: controller.setSearchQuery,
                  decoration: InputDecoration(
                    hintText: 'Search messages...',
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              controller.setSearchQuery('');
                              setState(() {});
                            },
                            icon: const Icon(Icons.close),
                          )
                        : null,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                child: Row(
                  children: [
                    FilterChip(
                      label: Text(
                        controller.onlyWithImages
                            ? 'With image: ON'
                            : 'With image: OFF',
                      ),
                      selected: controller.onlyWithImages,
                      onSelected: controller.setOnlyWithImages,
                    ),
                    const SizedBox(width: 8),
                    ActionChip(
                      label: Text(
                        controller.sortMode == SortMode.newestFirst
                            ? 'Sort: Newest'
                            : 'Sort: Oldest',
                      ),
                      onPressed: controller.toggleSortMode,
                    ),
                  ],
                ),
              ),
              if (controller.error != null)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    controller.error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  child: controller.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : controller.messages.isEmpty
                      ? _EmptyState(query: controller.searchQuery)
                      : RefreshIndicator(
                          onRefresh: controller.loadMessages,
                          child: ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(12, 12, 12, 110),
                            itemCount: controller.messages.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final message = controller.messages[index];
                              final selected = controller.selectedIds.contains(
                                message.id,
                              );
                              return MessageCard(
                                key: ValueKey(message.id),
                                message: message,
                                searchQuery: controller.searchQuery,
                                isSelectionMode: controller.isSelectionMode,
                                isSelected: selected,
                                onLongPress: () {
                                  if (!controller.isSelectionMode) {
                                    controller.toggleSelectionMode(true);
                                  }
                                  if (message.id != null) {
                                    controller.toggleSelected(message.id!);
                                  }
                                },
                                onTap: () => _handleTap(
                                  context: context,
                                  controller: controller,
                                  message: message,
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              final messageController = context.read<MessageController>();
              await Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const MessageEditorScreen(),
                ),
              );
              if (mounted) {
                await messageController.loadMessages();
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('NEW'),
          ),
        );
      },
    );
  }

  void _handleTap({
    required BuildContext context,
    required MessageController controller,
    required Message message,
  }) {
    if (controller.isSelectionMode) {
      if (message.id != null) {
        controller.toggleSelected(message.id!);
      }
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MessageDetailScreen(messageId: message.id!),
      ),
    );
  }

  Future<void> _confirmBulkDelete(BuildContext context) async {
    final controller = context.read<MessageController>();
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Delete selected messages?'),
          content: Text(
            'You are deleting ${controller.selectedIds.length} messages.',
          ),
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

    if (shouldDelete == true) {
      await controller.deleteSelected();
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selected messages deleted.')),
      );
    }
  }
}

class _ConnectivityBanner extends StatelessWidget {
  const _ConnectivityBanner({required this.isOnline});

  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: double.infinity,
      color: isOnline ? const Color(0xFFD7F7D4) : const Color(0xFFFFC9C9),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Text(
        isOnline
            ? 'ONLINE - sharing available'
            : 'OFFLINE - local message features still work',
        style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.5),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    final searching = query.trim().isNotEmpty;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.forum_outlined, size: 64),
            const SizedBox(height: 12),
            Text(
              searching ? 'No results found.' : 'No messages yet.',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              searching
                  ? 'Try a different keyword.'
                  : 'Tap NEW to write your first post.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
