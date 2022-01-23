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

  List<Message> get messages => _messages;
  List<Thread> get threads => _threads;

  Future<bool> save(Message message) async {
    Message msg = await _dbService.createMessage(message);
    _messages.add(msg);
    notifyListeners();
    return true;
  }

  Future<bool> readAll() async {
    List<Thread> allThreadNames = await _dbService.readAllThreads();
    for (Thread t in allThreadNames) {
      developer.log('Read all thread names( ${t.id}, ${t.name} )');
    }

    List<Message> allMessages = await _dbService.readAllMessages();
    for (Message msg in allMessages) {
      developer.log('Read all messages ( ${msg.id} )');
      developer.log(msg.toJson().toString());
    }
    _messages = allMessages;
    notifyListeners();
    return true;
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
    await readAll();
  }

  Future<bool> createThreadName(Thread threadName) async {
    Thread t = await _dbService.createThread(threadName);
    _threads.add(t);
    notifyListeners();
    return true;
  }
}
