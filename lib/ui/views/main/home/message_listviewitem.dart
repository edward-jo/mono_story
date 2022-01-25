import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:mono_story/constants.dart';
import 'package:mono_story/models/message.dart';
import 'package:mono_story/view_models/message_viewmodel.dart';
import 'package:provider/src/provider.dart';

class MessageListViewItem extends StatelessWidget {
  const MessageListViewItem({Key? key, required this.message})
      : super(key: key);

  final Message message;

  @override
  Widget build(BuildContext context) {
    final findThread = Provider.of<MessageViewModel>(
      context,
      listen: false,
    ).findThreadData;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 1.0),
      padding: const EdgeInsets.only(
        left: 15.0,
        top: 5.0,
        bottom: 5.0,
        right: 10.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // -- MESSAGE --
          Text(message.message, style: Theme.of(context).textTheme.bodyText1),

          // -- PADDING --
          const SizedBox(height: 10.0),

          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // -- DATE TIME --
              MessageInfoContainer(
                color: dateTimeBgColor,
                label: DateFormat('dd/MM/yyy hh:mm').format(
                  message.createdTime,
                ),
              ),

              const SizedBox(width: 10),

              // -- Thread --
              if (message.threadId != null)
                MessageInfoContainer(
                  color: threadInfoBgColor,
                  label: findThread(id: message.threadId)?.name ?? 'undefined',
                ),
            ],
          ),

          // -- DIVIDER --
          const Divider(thickness: 0.5),
        ],
      ),
    );
  }
}

class MessageInfoContainer extends StatelessWidget {
  final Color color;
  final String label;

  const MessageInfoContainer({
    Key? key,
    required this.label,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 2.5),
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.all(Radius.circular(25)),
        ),
        child: Text(
          label,
          overflow: TextOverflow.fade,
          softWrap: false,
          style: Theme.of(context).textTheme.bodyText2,
        ),
      ),
    );
  }
}
