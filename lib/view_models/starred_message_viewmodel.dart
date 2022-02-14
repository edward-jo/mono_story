import 'dart:developer' as developer;
import 'package:mono_story/models/message.dart';
import 'package:mono_story/view_models/message_viewmodel_base.dart';

class StarredMessageViewModel extends MessageViewModelBase {
  @override
  Future<Message?> starMessage(int id, {bool notify = false}) async {
    try {
      final index = messages.indexWhere((e) => e.id == id);
      final message = Message.fromJson(messages[index].toJson());
      message.starred = message.starred == 0 ? 1 : 0;
      int affectedCount = await dbService.updateMessage(message);
      if (affectedCount != 1) {
        developer.log('Fail:', error: 'Failed to star message');
        return null;
      }
      messages.removeAt(index);
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
