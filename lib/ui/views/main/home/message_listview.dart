import 'package:flutter/widgets.dart';
import 'package:mono_story/fake_data.dart';
import 'package:mono_story/ui/views/main/home/message_listviewitem.dart';

class MessageListView extends StatefulWidget {
  const MessageListView({Key? key}) : super(key: key);

  @override
  _MessageListViewState createState() => _MessageListViewState();
}

class _MessageListViewState extends State<MessageListView> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: fakeMessages.length,
        itemBuilder: (_, i) {
          return MessageListViewItem(message: fakeMessages[i]);
        });
  }
}
