import 'package:mono_story/models/story.dart';
import 'package:mono_story/models/thread.dart';

abstract class AppDatabaseService {
  Future init();
  Future closeAppDatabase();
  Future deleteAppDatabase();
  Future replaceAppDatabase();
  Future<String> getAppDatabaseDirPath();
  Future<String> getAppDatabaseFilePath();
  Future<String> getAppDatabaseRestoreFilePath();
  //----------------------------------------------------------------------------
  // Message
  //----------------------------------------------------------------------------
  Future<Story> createMessage(Story message);
  Future<int> deleteMessage(int id);
  Future<Story> readMessage(int id);
  Future<List<Story>> readThreadMessages(int threadId);
  Future<List<Story>> readThreadMessagesChunk(
    int threadId,
    int? offset,
    int? limit,
  );
  Future<List<Story>> readAllMessages();
  Future<List<Story>> readAllMessagesChunk(
    int? offset,
    int? limit,
  );
  Future<List<Story>> searchAllMessagesChunk(
    int? offset,
    int? limit,
    String query,
  );
  Future<List<Story>> searchAllStarredMessagesChunk(
    int? offset,
    int? limit,
  );
  Future<int> updateMessage(Story message);
  //----------------------------------------------------------------------------
  // Thread
  //----------------------------------------------------------------------------
  Future<Thread> createThread(Thread thread);
  Future<int> deleteThread(int id);
  Future<Thread> readThread(int id);
  Future<List<Thread>> readAllThreads();
  Future<int> updateThread(Thread thread);
}
