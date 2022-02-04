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

  final List<Message> _messages = [];
  bool _hasNext = true;

  List<Message> get messages => _messages;

  void initMessages() {
    _messages.clear();
    _hasNext = true;
  }

  Future<bool> save(Message message) async {
    Message msg = await _dbService.createMessage(message);
    _messages.insert(0, msg);
    notifyListeners();
    return true;
  }

  bool _isReadingThread = false;

  bool canReadThreadChunk() {
    if (_isReadingThread) {
      developer.log('Reading thread in progress');
      return false;
    }

    if (!_hasNext) {
      developer.log('No next stories');
      return false;
    }

    return true;
  }

  final int _storyChunkLimit = 15;
  Future<bool> readThreadChunk(int? threadId) async {
    _isReadingThread = true;

    List<Message> stories;
    if (threadId == null) {
      stories = await _dbService.readAllMessagesChunk(
          _messages.length, _storyChunkLimit);
    } else {
      stories = await _dbService.readThreadMessagesChunk(
          threadId, _messages.length, _storyChunkLimit);
    }

    developer.log('Message List');
    for (Message m in stories) {
      developer.log('id( ${m.id}: ' + m.toJson().toString());
    }

    _hasNext = (stories.length < _storyChunkLimit) ? false : true;
    _messages.insertAll(_messages.length, stories);
    _isReadingThread = false;
    notifyListeners();

    return true;
  }

  Future<void> deleteMessage(int index) async {
    final message = _messages[index];
    int affectedCount = await _dbService.deleteMessage(message.id!);
    if (affectedCount != 1) {
      developer.log('deleteMessage:', error: 'Failed to delete message');
      return;
    }
    _messages.removeAt(index);
    notifyListeners();
  }

  Future<void> starMessage(int index) async {
    final message = _messages[index];
    message.starred = message.starred == 0 ? 1 : 0;
    int affectedCount = await _dbService.updateMessage(message);
    if (affectedCount != 1) {
      developer.log('starMessage:', error: 'Failed to star message');
      return;
    }
    _messages[index] = message;
    notifyListeners();
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
}
