import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mono_story/models/story.dart';
import 'package:mono_story/services/app_database/app_database_service.dart';
import 'package:mono_story/services/service_locator.dart';

abstract class StoryViewModelBase extends ChangeNotifier {
  final dynamic listKey = Platform.isIOS
      ? GlobalKey<SliverAnimatedListState>()
      : GlobalKey<AnimatedListState>();

  late Widget Function(
    int,
    Story,
    Animation<double>,
  ) removedItemBuilder;

  final _dbService = serviceLocator<AppDatabaseService>();

  final List<Story> _stories = [];
  final int _storyChunkLimit = 15;
  bool _isLoading = false;
  bool hasNext = true;

  AppDatabaseService get dbService => _dbService;
  List<Story> get stories => _stories;
  bool get isLoading => _isLoading;

  void initStories() {
    clearAllItem();
    hasNext = true;
  }

  void clearAllItem() {
    while (_stories.isNotEmpty) {
      removeItem(_stories.length - 1);
    }
  }

  void insertItem(int index, Story story) {
    _stories.insert(index, story);
    dynamic listCurrentState = Platform.isIOS
        ? (listKey as GlobalKey<SliverAnimatedListState>).currentState
        : (listKey as GlobalKey<AnimatedListState>).currentState;
    listCurrentState?.insertItem(index);
  }

  void addItem(Story story) {
    _stories.add(story);
    dynamic listCurrentState = Platform.isIOS
        ? (listKey as GlobalKey<SliverAnimatedListState>).currentState
        : (listKey as GlobalKey<AnimatedListState>).currentState;
    listCurrentState?.insertItem(stories.length - 1);
  }

  void insertAllItem(int index, List<Story> newList) {
    for (int i = 0; i < newList.length; i++) {
      insertItem(index + i, newList[i]);
    }
  }

  void removeItem(int index) {
    Story removedItem = _stories.removeAt(index);
    dynamic listCurrentState = Platform.isIOS
        ? (listKey as GlobalKey<SliverAnimatedListState>).currentState
        : (listKey as GlobalKey<AnimatedListState>).currentState;
    listCurrentState?.removeItem(index, (context, animation) {
      return removedItemBuilder(index, removedItem, animation);
    });
  }

  Future<int?> save(
    Story story, {
    bool insertAfterSaving = false,
    bool notify = false,
  }) async {
    Story msg = await _dbService.createStory(story);
    if (insertAfterSaving) {
      insertItem(0, msg);
      if (notify) notifyListeners();
      return 0;
    }
    return null;
  }

  bool canLoadStoriesChunk() {
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

  Future<int> readStoriesChunk(int? threadId) async {
    _isLoading = true;

    await Future.delayed(const Duration(milliseconds: 300));

    List<Story> stories;
    if (threadId == null) {
      stories = await _dbService.readAllStoriesChunk(
          _stories.length, _storyChunkLimit);
    } else {
      stories = await _dbService.readThreadStoriesChunk(
          threadId, _stories.length, _storyChunkLimit);
    }

    // developer.log('Story List');
    // for (Story m in stories) {
    //   developer.log('id( ${m.id}: ' + m.toJson().toString());
    // }

    hasNext = (stories.length < _storyChunkLimit) ? false : true;
    insertAllItem(_stories.length, stories);
    _isLoading = false;
    notifyListeners();

    return stories.length;
  }

  Future<int> searchThreadChunk(String query) async {
    _isLoading = true;

    await Future.delayed(const Duration(milliseconds: 300));

    List<Story> stories;

    stories = await _dbService.searchAllStoriesChunk(
      _stories.length,
      _storyChunkLimit,
      query,
    );

    // developer.log('Story List');
    // for (Story m in stories) {
    //   developer.log('id( ${m.id}: ' + m.toJson().toString());
    // }

    hasNext = (stories.length < _storyChunkLimit) ? false : true;
    insertAllItem(_stories.length, stories);
    _isLoading = false;
    notifyListeners();

    return stories.length;
  }

  Future<int> readStarredStoriesChunk() async {
    _isLoading = true;

    await Future.delayed(const Duration(milliseconds: 300));

    List<Story> stories;

    stories = await _dbService.searchAllStarredStoriesChunk(
      _stories.length,
      _storyChunkLimit,
    );

    // developer.log('Story List');
    // for (Story m in stories) {
    //   developer.log('id( ${m.id}: ' + m.toJson().toString());
    // }

    hasNext = (stories.length < _storyChunkLimit) ? false : true;
    insertAllItem(_stories.length, stories);
    _isLoading = false;
    notifyListeners();

    return stories.length;
  }

  bool contains(int id) {
    return (stories.indexWhere((e) => e.id == id) < 0) ? false : true;
  }

  Future<Story?> updateStory(int id, {bool notify = false}) async {
    int index = _stories.indexWhere((e) => e.id == id);
    if (index < 0) {
      return null;
    }

    try {
      Story story = await _dbService.readStory(id);
      // Since the list already has this story, should not update animated list state
      _stories[index] = story;
      if (notify) notifyListeners();
    } catch (e) {
      developer.log(
        'readStory:',
        error: 'Failed to read story with id($id) error( ${e.toString()})',
      );
      return null;
    }
  }

  Future<Story?> insertStory(int id, {bool notify = false}) async {
    try {
      Story story = await _dbService.readStory(id);
      if (_stories.isEmpty) {
        insertItem(0, story);
      } else {
        int index = _stories.indexWhere((e) => e.id == id);
        if (index < 0) {
          // List does not have this story, find index to insert it.
          index = _stories.indexWhere((e) {
            return story.createdTime.isAfter(e.createdTime);
          });
          if (index < 0) {
            addItem(story);
          } else {
            insertItem(index, story);
          }
        } else {
          // List has this story. update item in the list without updating animated list state.
          _stories[index] = story;
        }
      }
      if (notify) notifyListeners();
      return story;
    } catch (e) {
      developer.log(
        'readStory:',
        error: 'Failed to read story with id($id) error( ${e.toString()})',
      );
      return null;
    }
  }

  Future<Story?> deleteStory(int id, {bool notify = false}) async {
    try {
      final index = _stories.indexWhere((e) => e.id == id);
      final story = _stories[index];
      int affectedCount = await _dbService.deleteStory(story.id!);
      if (affectedCount != 1) {
        developer.log('deleteStory:', error: 'Failed to delete story');
        return null;
      }
      removeItem(index);
      if (notify) notifyListeners();
      return story;
    } catch (e) {
      developer.log(
        'Error:',
        error: 'Failed to delete story with id($id) error( ${e.toString()})',
      );
      return null;
    }
  }

  void deleteStoryFromList(int id, {bool notify = false}) {
    final index = stories.indexWhere((e) => e.id == id);
    if (index < 0) return;

    removeItem(index);

    if (notify) notifyListeners();
    return;
  }

  Future<Story?> starStory(int id) async {
    try {
      final index = _stories.indexWhere((e) => e.id == id);
      final story = Story.fromJson(_stories[index].toJson());
      story.starred = story.starred == 0 ? 1 : 0;
      int affectedCount = await _dbService.updateStory(story);
      if (affectedCount != 1) {
        developer.log('Fail:', error: 'Failed to star story');
        return null;
      }
      _stories[index] = story;
      notifyListeners();
      return story;
    } catch (e) {
      developer.log(
        'Error:',
        error: 'Failed to star story with id($id) error( ${e.toString()})',
      );
      return null;
    }
  }
}
