import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:mono_story/models/message.dart';
import 'package:mono_story/services/app_database/app_database_service.dart';
import 'package:mono_story/services/service_locator.dart';

abstract class MessageViewModelBase extends ChangeNotifier {
  final _dbService = serviceLocator<AppDatabaseService>();

  final List<Message> _messages = [];
  final int _messageChunkLimit = 15;
  bool _isLoading = false;
  bool hasNext = true;

  AppDatabaseService get dbService => _dbService;
  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;

  void initMessages() {
    _messages.clear();
    hasNext = true;
  }

  Future<int?> save(
    Message message, {
    bool insertAfterSaving = false,
    bool notify = false,
  }) async {
    Message msg = await _dbService.createMessage(message);
    if (insertAfterSaving) {
      _messages.insert(0, msg);
      if (notify) notifyListeners();
      return 0;
    }
    return null;
  }

  bool canLoadMessagesChunk() {
    if (_isLoading) {
      developer.log('Reading thread in progress');
      return false;
    }

    if (!hasNext) {
      developer.log('No next stories');
      return false;
    }

    return true;
  }

  Future<int> readMessagesChunk(int? threadId) async {
    _isLoading = true;

    await Future.delayed(const Duration(milliseconds: 300));

    List<Message> stories;
    if (threadId == null) {
      stories = await _dbService.readAllMessagesChunk(
          _messages.length, _messageChunkLimit);
    } else {
      stories = await _dbService.readThreadMessagesChunk(
          threadId, _messages.length, _messageChunkLimit);
    }

    // developer.log('Message List');
    // for (Message m in stories) {
    //   developer.log('id( ${m.id}: ' + m.toJson().toString());
    // }

    hasNext = (stories.length < _messageChunkLimit) ? false : true;
    _messages.insertAll(_messages.length, stories);
    _isLoading = false;
    notifyListeners();

    return stories.length;
  }

  Future<int> searchThreadChunk(String query) async {
    _isLoading = true;

    await Future.delayed(const Duration(milliseconds: 300));

    List<Message> stories;

    stories = await _dbService.searchAllMessagesChunk(
      _messages.length,
      _messageChunkLimit,
      query,
    );

    // developer.log('Message List');
    // for (Message m in stories) {
    //   developer.log('id( ${m.id}: ' + m.toJson().toString());
    // }

    hasNext = (stories.length < _messageChunkLimit) ? false : true;
    _messages.insertAll(_messages.length, stories);
    _isLoading = false;
    notifyListeners();

    return stories.length;
  }

  Future<int> searchStarredThreadChunk() async {
    _isLoading = true;

    await Future.delayed(const Duration(milliseconds: 300));

    List<Message> stories;

    stories = await _dbService.searchAllStarredMessagesChunk(
      _messages.length,
      _messageChunkLimit,
    );

    // developer.log('Message List');
    // for (Message m in stories) {
    //   developer.log('id( ${m.id}: ' + m.toJson().toString());
    // }

    hasNext = (stories.length < _messageChunkLimit) ? false : true;
    _messages.insertAll(_messages.length, stories);
    _isLoading = false;
    notifyListeners();

    return stories.length;
  }

  Future<Message?> deleteMessage(int id, {bool notify = false}) async {
    try {
      final index = _messages.indexWhere((e) => e.id == id);
      final message = _messages[index];
      int affectedCount = await _dbService.deleteMessage(message.id!);
      if (affectedCount != 1) {
        developer.log('deleteMessage:', error: 'Failed to delete message');
        return null;
      }
      _messages.removeAt(index);
      if (notify) notifyListeners();
      return message;
    } catch (e) {
      developer.log(
        'Error:',
        error: 'Failed to delete message with id($id) error( ${e.toString()})',
      );
      return null;
    }
  }

  void deleteMessageFromList(int id, {bool notify = false}) {
    try {
      final index = messages.indexWhere((e) => e.id == id);
      if (index < 0) return;
      messages.removeAt(index);
      if (notify) notifyListeners();
    } catch (e) {
      developer.log(
        'Error:',
        error: 'Failed to delete message with id($id) error( ${e.toString()})',
      );
      return;
    }
  }

  Future<void> starMessage(int id) async {
    try {
      final index = _messages.indexWhere((e) => e.id == id);
      final message = Message.fromJson(_messages[index].toJson());
      message.starred = message.starred == 0 ? 1 : 0;
      int affectedCount = await _dbService.updateMessage(message);
      if (affectedCount != 1) {
        developer.log('Fail:', error: 'Failed to star message');
        return;
      }
      _messages[index] = message;
      notifyListeners();
    } catch (e) {
      developer.log(
        'Error:',
        error: 'Failed to star message with id($id) error( ${e.toString()})',
      );
      return;
    }
  }
}
