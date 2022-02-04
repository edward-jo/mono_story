import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:mono_story/constants.dart';
import 'package:mono_story/models/message.dart';
import 'package:mono_story/view_models/thread_viewmodel.dart';
import 'package:provider/provider.dart';

class MessageListViewItem extends StatelessWidget {
  const MessageListViewItem({
    Key? key,
    required this.message,
    required this.onDelete,
    required this.onStar,
  }) : super(key: key);

  final Message message;
  final void Function() onStar;
  final void Function() onDelete;

  @override
  Widget build(BuildContext context) {
    final findThread = context.read<ThreadViewModel>().findThreadData;

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

          // -- PADDING --
          const SizedBox(height: 10.0),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    // -- CREATE TIME --
                    MessageInfoContainer(
                      label: genCreatedTimeInfo(message.createdTime),
                      color: dateTimeBgColor,
                    ),

                    const SizedBox(width: 10),

                    // -- THREAD --
                    if (message.threadId != null)
                      MessageInfoContainer(
                        color: threadInfoBgColor,
                        label: findThread(id: message.threadId)?.name ??
                            'undefined',
                      ),
                  ],
                ),
              ),
              PopupMenuButton(
                onSelected: (value) {},
                itemBuilder: (context) => <PopupMenuEntry>[
                  PopupMenuItem(
                    child: Row(
                      children: const <Widget>[
                        Icon(Icons.star_outline_rounded),
                        SizedBox(width: 10),
                        Text('Star'),
                      ],
                    ),
                    onTap: onStar,
                  ),
                  PopupMenuItem(
                    child: Row(
                      children: const <Widget>[
                        Icon(Icons.delete_rounded),
                        SizedBox(width: 10),
                        Text('Delete'),
                      ],
                    ),
                    onTap: onDelete,
                  ),
                ],
              ),
              // IconButton(onPressed: onTab, icon: const Icon(Icons.more_horiz)),
            ],
          ),
        ],
      ),
    );
  }

  /// createdTime: UTC time
  String genCreatedTimeInfo(DateTime createdTime) {
    final current = DateTime.now();
    final created = createdTime.toLocal();

    String time = DateFormat.jm().format(created);
    String date = (created.year == current.year)
        ? DateFormat.MMMMd().format(created)
        : DateFormat.yMMMMd().format(created);

    return '$time, $date';
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
          borderRadius: const BorderRadius.all(Radius.circular(3)),
        ),
        child: Text(
          label,
          overflow: TextOverflow.fade,
          softWrap: false,
          style: Theme.of(context).textTheme.caption?.copyWith(fontSize: 12),
        ),
      ),
    );
  }
}
