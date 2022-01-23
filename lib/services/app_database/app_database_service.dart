import '/models/message.dart';
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
  Future<List<Message>> readAllMessages();
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
