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
  // Story
  //----------------------------------------------------------------------------
  Future<Story> createStory(Story story);
  Future<int> deleteStory(int id);
  Future<Story> readStory(int id);
  Future<List<Story>> readThreadStory(int threadId);
  Future<List<Story>> readThreadStoriesChunk(
    int threadId,
    int? offset,
    int? limit,
  );
  Future<List<Story>> readAllStories();
  Future<List<Story>> readAllStoriesChunk(
    int? offset,
    int? limit,
  );
  Future<List<Story>> searchAllStoriesChunk(
    int? offset,
    int? limit,
    String query,
  );
  Future<List<Story>> searchAllStarredStoriesChunk(
    int? offset,
    int? limit,
  );
  Future<int> updateStory(Story story);
  //----------------------------------------------------------------------------
  // Thread
  //----------------------------------------------------------------------------
  Future<Thread> createThread(Thread thread);
  Future<int> deleteThread(int id);
  Future<Thread> readThread(int id);
  Future<List<Thread>> readAllThreads();
  Future<int> updateThread(Thread thread);
}
