import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mono_story/ui/common/platform_alert_dialog.dart';
import 'package:mono_story/ui/common/platform_indicator.dart';
import 'package:provider/provider.dart';

import '/ui/views/main/home/message_listviewitem.dart';
import '/view_models/message_viewmodel.dart';

class MessageListView extends StatefulWidget {
  const MessageListView({Key? key}) : super(key: key);

  @override
  _MessageListViewState createState() => _MessageListViewState();
}

class _MessageListViewState extends State<MessageListView> {
  late Future<void> _readMessagesFuture;

  @override
  void initState() {
    _readMessagesFuture = context.read<MessageViewModel>().readAll();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _readMessagesFuture,
      builder: (context, snapshot) {
        // -- INDICATOR --
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(
            child: PlatformIndicator(),
          );
        }

        // -- ALERT DIALOG --
        if (snapshot.hasError) {
          showDialog(
            context: context,
            builder: (_) {
              return PlatformAlertDialog(
                content: Text(snapshot.error.toString()),
              );
            },
          );
          return Container();
        }

        // -- MESSAGE LIST --
        return ListView.builder(
          itemCount: context.watch<MessageViewModel>().messages.length,
          itemBuilder: (_, i) {
            return MessageListViewItem(
              message: context.watch<MessageViewModel>().messages[i],
            );
          },
        );
      },
    );
  }
}
