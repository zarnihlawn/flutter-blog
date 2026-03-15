import '../models/message.dart';
import 'database_service.dart';

class MessageRepository {
  MessageRepository({DatabaseService? databaseService})
      : _databaseService = databaseService ?? DatabaseService.instance;

  final DatabaseService _databaseService;

  Future<List<Message>> getAllMessages() async {
    final db = await _databaseService.database;
    final rows = await db.query(
      'messages',
      orderBy: 'updated_at DESC',
    );
    return rows.map(Message.fromMap).toList();
  }

  Future<Message?> getMessageById(int id) async {
    final db = await _databaseService.database;
    final rows = await db.query(
      'messages',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return Message.fromMap(rows.first);
  }

  Future<List<Message>> searchMessages(String query) async {
    final db = await _databaseService.database;
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return getAllMessages();
    }
    final rows = await db.query(
      'messages',
      where: 'content LIKE ?',
      whereArgs: ['%$trimmed%'],
      orderBy: 'updated_at DESC',
    );
    return rows.map(Message.fromMap).toList();
  }

  Future<int> createMessage(Message message) async {
    final db = await _databaseService.database;
    return db.insert('messages', message.toMap());
  }

  Future<int> updateMessage(Message message) async {
    final db = await _databaseService.database;
    return db.update(
      'messages',
      message.toMap(),
      where: 'id = ?',
      whereArgs: [message.id],
    );
  }

  Future<int> deleteMessage(int id) async {
    final db = await _databaseService.database;
    return db.delete(
      'messages',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteMessages(List<int> ids) async {
    if (ids.isEmpty) {
      return 0;
    }
    final db = await _databaseService.database;
    final placeholders = List.filled(ids.length, '?').join(',');
    return db.delete(
      'messages',
      where: 'id IN ($placeholders)',
      whereArgs: ids,
    );
  }
}
