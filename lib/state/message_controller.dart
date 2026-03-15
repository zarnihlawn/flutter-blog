import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';

import '../data/message_repository.dart';
import '../models/message.dart';

class MessageController extends ChangeNotifier {
  MessageController({required MessageRepository repository})
      : _repository = repository;

  final MessageRepository _repository;
  final ImagePicker _imagePicker = ImagePicker();

  List<Message> _messages = const [];
  String _searchQuery = '';
  bool _isLoading = true;
  bool _isSelectionMode = false;
  final Set<int> _selectedIds = <int>{};
  String? _error;
  bool _isOnline = true;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isSelectionMode => _isSelectionMode;
  Set<int> get selectedIds => _selectedIds;
  String get searchQuery => _searchQuery;
  String? get error => _error;
  bool get isOnline => _isOnline;

  Future<void> initialize() async {
    await _observeConnectivity();
    await loadMessages();
  }

  Future<void> _observeConnectivity() async {
    final connectivity = Connectivity();
    final initial = await connectivity.checkConnectivity();
    _isOnline = !initial.contains(ConnectivityResult.none);
    _connectivitySubscription = connectivity.onConnectivityChanged.listen((
      results,
    ) {
      _isOnline = !results.contains(ConnectivityResult.none);
      notifyListeners();
    });
  }

  Future<void> loadMessages() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _messages = _searchQuery.trim().isEmpty
          ? await _repository.getAllMessages()
          : await _repository.searchMessages(_searchQuery);
    } catch (_) {
      _error = 'Unable to load messages from the local database.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createMessage({
    required String content,
    String? imagePath,
  }) async {
    final now = DateTime.now();
    final message = Message(
      content: content.trim(),
      imagePath: imagePath,
      createdAt: now,
      updatedAt: now,
    );
    await _repository.createMessage(message);
    await loadMessages();
  }

  Future<void> editMessage({
    required Message original,
    required String content,
    String? imagePath,
    bool clearImagePath = false,
  }) async {
    final updated = original.copyWith(
      content: content.trim(),
      imagePath: imagePath,
      clearImagePath: clearImagePath,
      updatedAt: DateTime.now(),
    );
    await _repository.updateMessage(updated);
    await loadMessages();
  }

  Future<void> deleteSingle(int id) async {
    await _repository.deleteMessage(id);
    _selectedIds.remove(id);
    await loadMessages();
  }

  Future<void> deleteSelected() async {
    await _repository.deleteMessages(_selectedIds.toList());
    _selectedIds.clear();
    _isSelectionMode = false;
    await loadMessages();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    unawaited(loadMessages());
  }

  void toggleSelectionMode([bool? value]) {
    _isSelectionMode = value ?? !_isSelectionMode;
    if (!_isSelectionMode) {
      _selectedIds.clear();
    }
    notifyListeners();
  }

  void toggleSelected(int id) {
    if (_selectedIds.contains(id)) {
      _selectedIds.remove(id);
    } else {
      _selectedIds.add(id);
    }
    notifyListeners();
  }

  void selectAllVisible() {
    _selectedIds
      ..clear()
      ..addAll(_messages.where((message) => message.id != null).map((e) => e.id!));
    notifyListeners();
  }

  void clearSelection() {
    _selectedIds.clear();
    notifyListeners();
  }

  Future<String?> pickFromGallery() async {
    final file = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      imageQuality: 85,
    );
    return file?.path;
  }

  Future<String?> pickFromCamera() async {
    final file = await _imagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      imageQuality: 85,
    );
    return file?.path;
  }

  Future<void> shareMessage(Message message) async {
    final text = message.content.trim();
    if ((message.imagePath ?? '').isNotEmpty) {
      final file = File(message.imagePath!);
      if (await file.exists()) {
        await SharePlus.instance.share(
          ShareParams(
            text: text,
            files: [XFile(file.path)],
            title: 'Share message',
          ),
        );
        return;
      }
    }
    await SharePlus.instance.share(
      ShareParams(
        text: text,
        title: 'Share message',
      ),
    );
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}
