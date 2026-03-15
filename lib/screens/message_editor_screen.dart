import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/message.dart';
import '../state/message_controller.dart';

class MessageEditorScreen extends StatefulWidget {
  const MessageEditorScreen({super.key, this.message});

  final Message? message;

  @override
  State<MessageEditorScreen> createState() => _MessageEditorScreenState();
}

class _MessageEditorScreenState extends State<MessageEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _contentController;
  String? _imagePath;
  bool _removeExistingImage = false;
  bool _isSaving = false;

  bool get _isEdit => widget.message != null;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(
      text: widget.message?.content ?? '',
    );
    _imagePath = widget.message?.imagePath;
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'EDIT MESSAGE' : 'NEW MESSAGE')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              TextFormField(
                controller: _contentController,
                minLines: 6,
                maxLines: 12,
                decoration: const InputDecoration(
                  hintText: 'Write your post...',
                ),
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) {
                    return 'Message text is required.';
                  }
                  if (text.length < 3) {
                    return 'Please enter at least 3 characters.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ElevatedButton.icon(
                    onPressed: _isSaving ? null : _pickFromGallery,
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Gallery'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _isSaving ? null : _pickFromCamera,
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text('Camera'),
                  ),
                  if (_imagePath != null)
                    ElevatedButton.icon(
                      onPressed: _isSaving
                          ? null
                          : () {
                              setState(() {
                                _imagePath = null;
                                _removeExistingImage = true;
                              });
                            },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Remove Image'),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: _imagePath == null
                    ? const SizedBox.shrink()
                    : Container(
                        key: ValueKey(_imagePath),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 3),
                        ),
                        child: Image.file(
                          File(_imagePath!),
                          height: 220,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const SizedBox(
                              height: 120,
                              child: Center(child: Text('Image unavailable')),
                            );
                          },
                        ),
                      ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: _isSaving
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(_isEdit ? 'Update Message' : 'Create Message'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickFromGallery() async {
    final path = await context.read<MessageController>().pickFromGallery();
    if (path == null || !mounted) {
      return;
    }
    setState(() {
      _imagePath = path;
      _removeExistingImage = false;
    });
  }

  Future<void> _pickFromCamera() async {
    final path = await context.read<MessageController>().pickFromCamera();
    if (path == null || !mounted) {
      return;
    }
    setState(() {
      _imagePath = path;
      _removeExistingImage = false;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final controller = context.read<MessageController>();

    setState(() => _isSaving = true);
    try {
      if (_isEdit) {
        await controller.editMessage(
          original: widget.message!,
          content: _contentController.text,
          imagePath: _imagePath,
          clearImagePath: _removeExistingImage,
        );
      } else {
        await controller.createMessage(
          content: _contentController.text,
          imagePath: _imagePath,
        );
      }
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Unable to save message.')));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
