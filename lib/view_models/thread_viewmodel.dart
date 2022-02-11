import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:mono_story/models/thread.dart';
import 'package:mono_story/services/app_database/app_database_service.dart';
import 'package:mono_story/services/service_locator.dart';

class ThreadViewModel extends ChangeNotifier {
  final AppDatabaseService _dbService = serviceLocator<AppDatabaseService>();
  List<Thread> _threads = [];
  int? _currentThreadId;

  List<Thread> get threads => _threads;

  int? get currentThreadId => _currentThreadId;
  set currentThreadId(int? id) {
    _currentThreadId = id;
    notifyListeners();
  }

  Thread? get currentThreadData {
    if (_currentThreadId == null) return null;
    return findThreadData(id: _currentThreadId);
  }

  Future<List<Thread>> getThreadList() async {
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

  Future<void> deleteThread(int id) async {
    try {
      final index = _threads.indexWhere((e) => e.id == id);
      final thread = _threads[index];
      int affectedCount = await _dbService.deleteThread(thread.id!);
      if (affectedCount != 1) {
        developer.log('deleteThread:', error: 'Failed to delete thread');
        return;
      }
      _threads.removeAt(index);
      notifyListeners();
    } catch (e) {
      developer.log(
        'Error:',
        error: 'Failed to delete thread with id($id) error( ${e.toString()})',
      );
      return;
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
      developer.log('Cannot find out thread data');
      return null;
    }
  }
}
