import 'package:mono_story/constants.dart';
import 'package:mono_story/database/app_database.dart';
import 'package:mono_story/models/message.dart';
import 'package:mono_story/models/thread.dart';
import 'package:mono_story/services/app_database/app_database_service.dart';

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

    if (messages.isEmpty) throw Exception('Failed to find message id( $id )');

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
  Future<Thread> createThread(Thread thread) async {
    final db = _appDb.database;
    Map<String, dynamic> threadJson = thread.toJson();
    final id = await db.insert(threadNamesTableName, threadJson);
    threadJson[ThreadNamesTableCols.id] = id;

    return Thread.fromJson(threadJson);
  }

  @override
  Future<int> deleteThread(int id) async {
    final db = _appDb.database;

    return await db.delete(
      threadNamesTableName,
      where: '${ThreadNamesTableCols.id} = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<Thread>> readAllThreads() async {
    final db = _appDb.database;
    final threads = await db.query(
      threadNamesTableName,
      orderBy: '${ThreadNamesTableCols.name} ASC',
    );
    return threads.map((e) {
      return Thread.fromJson(e);
    }).toList();
  }

  @override
  Future<Thread> readThread(int id) async {
    final db = _appDb.database;
    final threads = await db.query(
      threadNamesTableName,
      columns: [
        ThreadNamesTableCols.id,
        ThreadNamesTableCols.name,
      ],
      where: '${ThreadNamesTableCols.id} = ?',
      whereArgs: [id],
    );

    if (threads.isEmpty) throw Exception('Failed to find thread id ( $id )');

    return Thread.fromJson(threads.first);
  }

  @override
  Future<int> updateThread(Thread thread) async {
    final db = _appDb.database;

    return await db.update(
      threadNamesTableName,
      thread.toJson(),
      where: '${ThreadNamesTableCols.id} = ?',
      whereArgs: [thread.id],
    );
  }
}
