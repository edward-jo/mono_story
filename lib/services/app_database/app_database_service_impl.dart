import 'package:mono_story/constants.dart';
import 'package:mono_story/database/app_database.dart';
import 'package:mono_story/models/story.dart';
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
  Future replaceAppDatabase() async {
    await _appDb.replaceAppDatabaseWithRestore();
  }

  @override
  Future<String> getAppDatabaseDirPath() async {
    return _appDb.getAppDatabaseDirPath();
  }

  @override
  Future<String> getAppDatabaseFilePath() async {
    final db = _appDb.database;
    return db.path;
  }

  @override
  Future<String> getAppDatabaseRestoreFilePath() async {
    return _appDb.getRestoreFilePath();
  }
  //----------------------------------------------------------------------------
  // Story
  //----------------------------------------------------------------------------

  @override
  Future<Story> createStory(Story story) async {
    final db = _appDb.database;
    Map<String, dynamic> storyJson = story.toJson();
    final id = await db.insert(storiesTableNameV2, storyJson);
    storyJson[StoriesTableCols.id] = id;

    return Story.fromJson(storyJson);
  }

  @override
  Future<int> deleteStory(int id) async {
    final db = _appDb.database;

    return await db.delete(
      storiesTableNameV2,
      where: '${StoriesTableCols.id} = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<Story> readStory(int id) async {
    final db = _appDb.database;
    final stories = await db.query(
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

    if (stories.isEmpty) throw Exception('Failed to find story id( $id )');

    return Story.fromJson(stories.first);
  }

  @override
  Future<List<Story>> readThreadStory(int threadId) async {
    final db = _appDb.database;
    final stories = await db.query(
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

    return stories.map((e) {
      return Story.fromJson(e);
    }).toList();
  }

  @override
  Future<List<Story>> readThreadStoriesChunk(
    int threadId,
    int? offset,
    int? limit,
  ) async {
    final db = _appDb.database;
    final stories = await db.query(
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

    return stories.map((e) {
      return Story.fromJson(e);
    }).toList();
  }

  @override
  Future<List<Story>> readAllStories() async {
    final db = _appDb.database;
    final stories = await db.query(
      storiesTableNameV2,
      orderBy: '${StoriesTableCols.createdTime} DESC',
    );

    return stories.map((e) {
      return Story.fromJson(e);
    }).toList();
  }

  @override
  Future<List<Story>> readAllStoriesChunk(int? offset, int? limit) async {
    final db = _appDb.database;
    final stories = await db.query(
      storiesTableNameV2,
      offset: offset,
      limit: limit,
      orderBy: '${StoriesTableCols.createdTime} DESC',
    );

    return stories.map((e) {
      return Story.fromJson(e);
    }).toList();
  }

  @override
  Future<List<Story>> searchAllStoriesChunk(
    int? offset,
    int? limit,
    String query,
  ) async {
    final db = _appDb.database;
    final stories = await db.query(
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

    return stories.map((e) {
      return Story.fromJson(e);
    }).toList();
  }

  @override
  Future<List<Story>> searchAllStarredStoriesChunk(
    int? offset,
    int? limit,
  ) async {
    final db = _appDb.database;
    final stories = await db.query(
      storiesTableNameV2,
      where: '${StoriesTableCols.starred} = ?',
      whereArgs: [1],
      offset: offset,
      limit: limit,
      orderBy: '${StoriesTableCols.createdTime} DESC',
    );

    return stories.map((e) {
      return Story.fromJson(e);
    }).toList();
  }

  @override
  Future<int> updateStory(Story story) async {
    final db = _appDb.database;

    return await db.update(
      storiesTableNameV2,
      story.toJson(),
      where: '${StoriesTableCols.id} = ?',
      whereArgs: [story.id],
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
