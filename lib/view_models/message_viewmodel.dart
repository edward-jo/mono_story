import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:mono_story/constants.dart';
import 'package:mono_story/models/message.dart';
import 'package:mono_story/models/thread.dart';
import 'package:mono_story/services/app_database/app_database_service.dart';
import 'package:mono_story/services/icloud_storage/icloud_storage_service.dart';
import 'package:mono_story/services/service_locator.dart';

class MessageViewModel extends ChangeNotifier {
  final AppDatabaseService _dbService = serviceLocator<AppDatabaseService>();
  final IcloudStorageService _iStorageService =
      serviceLocator<IcloudStorageService>();

  List<Message> _messages = [];
  List<Thread> _threads = [];
  int? _currentThreadId;

  List<Message> get messages => _messages;
  List<Thread> get threads => _threads;

  int? get currentThreadId => _currentThreadId;

  set currentThreadId(int? id) {
    _currentThreadId = id;
  }

  Thread? get currentThreadData {
    if (_currentThreadId == null) {
      return null;
    }
    return findThreadData(id: _currentThreadId);
  }

  Future<bool> save(Message message) async {
    Message msg = await _dbService.createMessage(message);
    _messages.insert(0, msg);
    notifyListeners();
    return true;
  }

  Future<List<Thread>> getThreadList() async {
    List<Thread> threads = await _dbService.readAllThreads();

    developer.log('Thread List');
    for (Thread t in threads) {
      developer.log('${t.id}: ${t.name}');
    }
    _threads = threads;
    return threads;
  }

  Future<List<Message>> readThread(int? id) async {
    List<Thread> threads = await _dbService.readAllThreads();

    developer.log('Thread List');
    for (Thread t in threads) {
      developer.log('${t.id}: ${t.name}');
    }
    _threads = threads;

    List<Message> messages;
    if (id == null) {
      messages = await _dbService.readAllMessages();
    } else {
      messages = await _dbService.readThreadMessages(id);
    }

    developer.log('Message List');
    for (Message m in messages) {
      developer.log('id( ${m.id}: ' + m.toJson().toString());
    }
    _messages = messages;

    // notifyListeners();
    return messages;
  }

  Future<void> uploadMessages(
    void Function(Stream<double>) onProgress,
  ) async {
    final path = await _dbService.getAppDatabaseFilePath();
    await _iStorageService.uploadFile(
      path,
      appDatabaseBackupFileName,
      onProgress,
    );
  }

  Future<void> downloadMessages(
    void Function(Stream<double>) onProgress,
  ) async {
    final path = await _dbService.getAppDatabaseFilePath();

    await _dbService.closeAppDatabase();
    await _dbService.deleteAppDatabase();

    await _iStorageService.downloadFile(
      appDatabaseBackupFileName,
      path,
      onProgress,
    );

    _messages.clear();
    notifyListeners();
  }

  Future<void> deleteMessages() async {
    await _dbService.closeAppDatabase();
    await _dbService.deleteAppDatabase();
    _messages.clear();
    notifyListeners();
  }

  Future<void> reloadMessages() async {
    await _dbService.init();
    readThread(_currentThreadId);
  }

  Future<Thread> createThreadName(Thread threadName) async {
    Thread t = await _dbService.createThread(threadName);
    _threads.add(t);
    notifyListeners();
    return t;
  }

  Thread? findThreadData({int? id, String? name}) {
    assert(id != null || name != null);
    if (_threads.isEmpty) return null;
    return _threads
        .where((element) {
          if (id != null && element.id == id) {
            return true;
          } else if (name != null && element.name == name) {
            return true;
          }
          return false;
        })
        .toList()
        .first;
  }
}
