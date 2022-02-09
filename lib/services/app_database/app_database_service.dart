import 'package:mono_story/models/message.dart';
import 'package:mono_story/models/thread.dart';

abstract class AppDatabaseService {
  Future init();
  Future closeAppDatabase();
  Future deleteAppDatabase();
  Future<String> getAppDatabaseFilePath();
  //----------------------------------------------------------------------------
  // Message
  //----------------------------------------------------------------------------
  Future<Message> createMessage(Message message);
  Future<int> deleteMessage(int id);
  Future<Message> readMessage(int id);
  Future<List<Message>> readThreadMessages(int threadId);
  Future<List<Message>> readThreadMessagesChunk(
    int threadId,
    int? offset,
    int? limit,
  );
  Future<List<Message>> readAllMessages();
  Future<List<Message>> readAllMessagesChunk(
    int? offset,
    int? limit,
  );
  Future<List<Message>> searchAllMessagesChunk(
    int? offset,
    int? limit,
    String query,
  );
  Future<List<Message>> searchAllStarredMessagesChunk(
    int? offset,
    int? limit,
  );
  Future<int> updateMessage(Message message);
  //----------------------------------------------------------------------------
  // Thread
  //----------------------------------------------------------------------------
  Future<Thread> createThread(Thread thread);
  Future<int> deleteThread(int id);
  Future<Thread> readThread(int id);
  Future<List<Thread>> readAllThreads();
  Future<int> updateThread(Thread thread);
}
