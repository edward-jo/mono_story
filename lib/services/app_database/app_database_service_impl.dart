import 'package:mono_story/models/thread.dart';

import '/database/app_database.dart';
import '/models/message.dart';
import 'app_database_service.dart';
import '../../constants.dart';

final AppDatabase _appDb = AppDatabase();

class AppDatabaseServiceImpl extends AppDatabaseService {
  @override
  Future init() async {
    await _appDb.init();
    return this;
  }

  @override
  Future closeAppDatabase() async {
    await _appDb.closeAppDatabase();
  }

  @override
  Future deleteAppDatabase() async {
    await _appDb.deleteAppDatabase();
  }

  @override
  Future<String> getAppDatabaseFilePath() async {
    final db = _appDb.database;
    return db.path;
  }
  //----------------------------------------------------------------------------
  // Message
  //----------------------------------------------------------------------------

  @override
  Future<Message> createMessage(Message message) async {
    final db = _appDb.database;
    Map<String, dynamic> messageJson = message.toJson();
    final id = await db.insert(messagesTableName, messageJson);
    messageJson[MessagesTableCols.id] = id;

    return Message.fromJson(messageJson);
  }

  @override
  Future<int> deleteMessage(int id) async {
    final db = _appDb.database;

    return await db.delete(
      messagesTableName,
      where: '${MessagesTableCols.id} = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<Message> readMessage(int id) async {
    final db = _appDb.database;
    final messages = await db.query(
      messagesTableName,
      columns: [
        MessagesTableCols.id,
        MessagesTableCols.message,
        MessagesTableCols.fkThreadNameId,
        MessagesTableCols.createdTime,
      ],
      where: '${MessagesTableCols.id} = ?',
      whereArgs: [id],
    );

    if (messages.isEmpty) throw Exception('Failed to find id( $id )');

    return Message.fromJson(messages.first);
  }

  @override
  Future<List<Message>> readAllMessages() async {
    final db = _appDb.database;
    final messages = await db.query(
      messagesTableName,
      orderBy: '${MessagesTableCols.createdTime} ASC',
    );

    return messages.map((e) {
      return Message.fromJson(e);
    }).toList();
  }

  @override
  Future<int> updateMessage(Message message) async {
    final db = _appDb.database;

    return await db.update(
      messagesTableName,
      message.toJson(),
      where: '${MessagesTableCols.id} = ?',
      whereArgs: [message.id],
    );
  }
  //----------------------------------------------------------------------------
  // Thread
  //----------------------------------------------------------------------------

  @override
  Future<Thread> createThread(Thread thread) {
    // TODO: implement createThread
    throw UnimplementedError();
  }

  @override
  Future<int> deleteThread(int id) {
    // TODO: implement deleteThread
    throw UnimplementedError();
  }

  @override
  Future<List<Thread>> readAllThreads() {
    // TODO: implement readAllThreads
    throw UnimplementedError();
  }

  @override
  Future<Thread> readThread(int id) {
    // TODO: implement readThread
    throw UnimplementedError();
  }

  @override
  Future<int> updateThread(Thread thread) {
    // TODO: implement updateThread
    throw UnimplementedError();
  }
}
