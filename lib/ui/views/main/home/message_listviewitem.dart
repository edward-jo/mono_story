import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mono_story/constants.dart';
import 'package:mono_story/models/message.dart';

class MessageListViewItem extends StatelessWidget {
  const MessageListViewItem({Key? key, required this.message})
      : super(key: key);

  final Message message;

  @override
  Widget build(BuildContext context) {
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
          Text(message.message, style: Theme.of(context).textTheme.bodyText2),

          // -- DATE TIME --
          InputChip(
            backgroundColor: dateTimeBgColor,
            label: Text(
              message.createdTime.toString(),
              style: Theme.of(context).textTheme.caption,
            ),
            elevation: 0,
            onPressed: () {},
          ),

          // -- DIVIDER --
          const Divider(thickness: 0.5),
        ],
      ),
    );
  }
}
