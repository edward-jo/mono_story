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
  set currentThreadId(int? id) => _currentThreadId = id;

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

  Future<Thread> createThread(Thread threadName) async {
    Thread t = await _dbService.createThread(threadName);
    _threads.add(t);
    notifyListeners();
    return t;
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
