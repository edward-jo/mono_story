import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:mono_story/models/thread.dart';
import 'package:mono_story/services/app_database/app_database_service.dart';
import 'package:mono_story/services/service_locator.dart';

class ThreadViewModel extends ChangeNotifier {
  final AppDatabaseService _dbService = serviceLocator<AppDatabaseService>();
  List<Thread> _threads = [];
  int? currentThreadId;

  List<Thread> get threads => _threads;

  Thread? get currentThreadData {
    if (currentThreadId == null) return null;
    return findThreadData(id: currentThreadId);
  }

  void setCurrentThreadId(int? id, {bool notify = false}) {
    currentThreadId = id;
    if (notify) notifyListeners();
  }

  Future<List<Thread>> readThreadList() async {
    List<Thread> threads = await _dbService.readAllThreads();

    developer.log('Thread List');
    for (Thread t in threads) {
      developer.log('${t.id}: ${t.name}');
    }
    _threads.clear();
    _threads = threads;
    return threads;
  }

  Future<Thread> createThread(String name) async {
    Thread t = await _dbService.createThread(Thread(name: name));
    _threads.add(t);
    notifyListeners();
    return t;
  }

  Future<void> renameThread(int id, String newName) async {
    int index = _threads.indexWhere((e) => e.id == id);
    if (index < 0) {
      developer.log('Fail:', error: 'Failed to find thread($id');
      return;
    }

    final thread = Thread.fromJson(_threads[index].toJson());
    thread.name = newName;
    int affectedCount = await _dbService.updateThread(thread);
    if (affectedCount != 1) {
      developer.log('Fail:', error: 'Failed to rename thread($id)');
      return;
    }
    _threads[index] = thread;
    notifyListeners();
  }

  Future<Thread?> deleteThread(int id, {bool notify = false}) async {
    try {
      final index = _threads.indexWhere((e) => e.id == id);
      final thread = _threads[index];
      int affectedCount = await _dbService.deleteThread(thread.id!);
      if (affectedCount != 1) {
        developer.log('deleteThread:', error: 'Failed to delete thread');
        return null;
      }

      _threads.removeAt(index);

      if (notify) notifyListeners();

      return thread;
    } catch (e) {
      developer.log(
        'Error:',
        error: 'Failed to delete thread with id($id) error( ${e.toString()})',
      );
      return null;
    }
  }

  Thread? findThreadData({int? id, String? name}) {
    if (_threads.isEmpty) return null;

    try {
      return _threads
          .where((element) {
            if (id != null && element.id == id) {
              return true;
            } else if (name != null &&
                element.name.toLowerCase() == name.toLowerCase()) {
              return true;
            }
            return false;
          })
          .toList()
          .first;
    } catch (e) {
      return null;
    }
  }
}
