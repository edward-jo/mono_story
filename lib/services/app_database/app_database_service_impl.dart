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
    final id = await db.insert(storiesTableNameV2, messageJson);
    messageJson[StoriesTableCols.id] = id;

    return Message.fromJson(messageJson);
  }

  @override
  Future<int> deleteMessage(int id) async {
    final db = _appDb.database;

    return await db.delete(
      storiesTableNameV2,
      where: '${StoriesTableCols.id} = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<Message> readMessage(int id) async {
    final db = _appDb.database;
    final messages = await db.query(
      storiesTableNameV2,
      columns: [
        StoriesTableCols.id,
        StoriesTableCols.story,
        StoriesTableCols.fkThreadId,
        StoriesTableCols.createdTime,
        StoriesTableCols.starred,
      ],
      where: '${StoriesTableCols.id} = ?',
      whereArgs: [id],
    );

    if (messages.isEmpty) throw Exception('Failed to find message id( $id )');

    return Message.fromJson(messages.first);
  }

  @override
  Future<List<Message>> readThreadMessages(int threadId) async {
    final db = _appDb.database;
    final messages = await db.query(
      storiesTableNameV2,
      columns: [
        StoriesTableCols.id,
        StoriesTableCols.story,
        StoriesTableCols.fkThreadId,
        StoriesTableCols.createdTime,
        StoriesTableCols.starred,
      ],
      where: '${StoriesTableCols.fkThreadId} = ?',
      whereArgs: [threadId],
      orderBy: '${StoriesTableCols.createdTime} DESC',
    );

    return messages.map((e) {
      return Message.fromJson(e);
    }).toList();
  }

  @override
  Future<List<Message>> readThreadMessagesChunk(
    int threadId,
    int? offset,
    int? limit,
  ) async {
    final db = _appDb.database;
    final messages = await db.query(
      storiesTableNameV2,
      columns: [
        StoriesTableCols.id,
        StoriesTableCols.story,
        StoriesTableCols.fkThreadId,
        StoriesTableCols.createdTime,
        StoriesTableCols.starred,
      ],
      where: '${StoriesTableCols.fkThreadId} = ?',
      whereArgs: [threadId],
      offset: offset,
      limit: limit,
      orderBy: '${StoriesTableCols.createdTime} DESC',
    );

    return messages.map((e) {
      return Message.fromJson(e);
    }).toList();
  }

  @override
  Future<List<Message>> readAllMessages() async {
    final db = _appDb.database;
    final messages = await db.query(
      storiesTableNameV2,
      orderBy: '${StoriesTableCols.createdTime} DESC',
    );

    return messages.map((e) {
      return Message.fromJson(e);
    }).toList();
  }

  @override
  Future<List<Message>> readAllMessagesChunk(int? offset, int? limit) async {
    final db = _appDb.database;
    final messages = await db.query(
      storiesTableNameV2,
      offset: offset,
      limit: limit,
      orderBy: '${StoriesTableCols.createdTime} DESC',
    );

    return messages.map((e) {
      return Message.fromJson(e);
    }).toList();
  }

  @override
  Future<List<Message>> searchAllMessagesChunk(
    int? offset,
    int? limit,
    String query,
  ) async {
    final db = _appDb.database;
    final messages = await db.query(
      storiesTableNameV2,
      columns: [
        StoriesTableCols.id,
        StoriesTableCols.story,
        StoriesTableCols.fkThreadId,
        StoriesTableCols.createdTime,
        StoriesTableCols.starred,
      ],
      where: '${StoriesTableCols.story} LIKE ?',
      whereArgs: ['%$query%'],
      offset: offset,
      limit: limit,
      orderBy: '${StoriesTableCols.createdTime} DESC',
    );

    return messages.map((e) {
      return Message.fromJson(e);
    }).toList();
  }

  @override
  Future<List<Message>> searchAllStarredMessagesChunk(
    int? offset,
    int? limit,
  ) async {
    final db = _appDb.database;
    final messages = await db.query(
      storiesTableNameV2,
      where: '${StoriesTableCols.starred} = ?',
      whereArgs: [1],
      offset: offset,
      limit: limit,
      orderBy: '${StoriesTableCols.createdTime} DESC',
    );

    return messages.map((e) {
      return Message.fromJson(e);
    }).toList();
  }

  @override
  Future<int> updateMessage(Message message) async {
    final db = _appDb.database;

    return await db.update(
      storiesTableNameV2,
      message.toJson(),
      where: '${StoriesTableCols.id} = ?',
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
    final id = await db.insert(threadsTableNameV2, threadJson);
    threadJson[ThreadsTableCols.id] = id;

    return Thread.fromJson(threadJson);
  }

  @override
  Future<int> deleteThread(int id) async {
    final db = _appDb.database;

    return await db.delete(
      threadsTableNameV2,
      where: '${ThreadsTableCols.id} = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<Thread>> readAllThreads() async {
    final db = _appDb.database;
    final threads = await db.query(
      threadsTableNameV2,
      orderBy: '${ThreadsTableCols.name} ASC',
    );
    return threads.map((e) {
      return Thread.fromJson(e);
    }).toList();
  }

  @override
  Future<Thread> readThread(int id) async {
    final db = _appDb.database;
    final threads = await db.query(
      threadsTableNameV2,
      columns: [
        ThreadsTableCols.id,
        ThreadsTableCols.name,
      ],
      where: '${ThreadsTableCols.id} = ?',
      whereArgs: [id],
    );

    if (threads.isEmpty) throw Exception('Failed to find thread id ( $id )');

    return Thread.fromJson(threads.first);
  }

  @override
  Future<int> updateThread(Thread thread) async {
    final db = _appDb.database;

    return await db.update(
      threadsTableNameV2,
      thread.toJson(),
      where: '${ThreadsTableCols.id} = ?',
      whereArgs: [thread.id],
    );
  }
}
