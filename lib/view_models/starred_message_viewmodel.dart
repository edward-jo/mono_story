import 'dart:developer' as developer;
import 'package:mono_story/models/story.dart';
import 'package:mono_story/view_models/message_viewmodel_base.dart';

class StarredMessageViewModel extends StoryViewModelBase {
  @override
  Future<Story?> starStory(int id, {bool notify = false}) async {
    try {
      final index = stories.indexWhere((e) => e.id == id);
      final message = Story.fromJson(stories[index].toJson());
      message.starred = message.starred == 0 ? 1 : 0;
      int affectedCount = await dbService.updateStory(message);
      if (affectedCount != 1) {
        developer.log('Fail:', error: 'Failed to star message');
        return null;
      }
      removeItem(index);
      if (notify) notifyListeners();
      return message;
    } catch (e) {
      developer.log(
        'Error:',
        error: 'Failed to star message with id($id) error( ${e.toString()})',
      );
      return null;
    }
  }
}
