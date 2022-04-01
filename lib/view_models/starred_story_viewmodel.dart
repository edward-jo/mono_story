import 'dart:developer' as developer;
import 'package:mono_story/models/story.dart';
import 'package:mono_story/view_models/story_viewmodel_base.dart';

class StarredStoryViewModel extends StoryViewModelBase {
  @override
  Future<Story?> starStory(int id, {bool notify = false}) async {
    try {
      final index = stories.indexWhere((e) => e.id == id);
      final story = Story.fromJson(stories[index].toJson());
      story.starred = story.starred == 0 ? 1 : 0;
      int affectedCount = await dbService.updateStory(story);
      if (affectedCount != 1) {
        developer.log('Fail:', error: 'Failed to star story');
        return null;
      }
      removeItem(index);
      if (notify) notifyListeners();
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
