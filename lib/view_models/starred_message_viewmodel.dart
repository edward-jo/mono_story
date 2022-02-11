import 'dart:developer';
import 'package:mono_story/models/message.dart';
import 'package:mono_story/view_models/message_viewmodel_base.dart';

class StarredMessageViewModel extends MessageViewModelBase {
  @override
  Future<void> starMessage(int id) async {
    try {
      final index = messages.indexWhere((e) => e.id == id);
      final message = Message.fromJson(messages[index].toJson());
      message.starred = message.starred == 0 ? 1 : 0;
      int affectedCount = await dbService.updateMessage(message);
      if (affectedCount != 1) {
        log('Fail:', error: 'Failed to star message');
        return;
      }
      messages.removeAt(index);
      notifyListeners();
    } catch (e) {
      log(
        'Error:',
        error: 'Failed to star message with id($id) error( ${e.toString()})',
      );
      return;
    }
  }
}
