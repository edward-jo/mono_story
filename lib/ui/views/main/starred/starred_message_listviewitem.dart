import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:mono_story/constants.dart';
import 'package:mono_story/models/story.dart';
import 'package:mono_story/utils/utils.dart';
import 'package:mono_story/view_models/thread_viewmodel.dart';
import 'package:provider/provider.dart';

class StarredMessageListViewItem extends StatelessWidget {
  const StarredMessageListViewItem({
    Key? key,
    required this.message,
    required this.onDelete,
    required this.onStar,
    this.emphasis,
  }) : super(key: key);

  final Story message;
  final void Function() onStar;
  final void Function() onDelete;
  final String? emphasis;

  @override
  Widget build(BuildContext context) {
    final threadVM = context.read<ThreadViewModel>();
    final threadName =
        threadVM.findThreadData(id: message.threadId)?.name ?? 'undefined';

    Widget messageWidget;
    TextStyle? textStyle = Theme.of(context).textTheme.bodyText2;
    if (emphasis != null && emphasis!.isNotEmpty) {
      // Generate span list
      final pattern = RegExp(emphasis!, caseSensitive: false, unicode: true);
      var textSpanList = splitStringWithPattern(message.story, pattern);
      var textSpanWidgetList = textSpanList.map((e) {
        final style = (e.toLowerCase() == emphasis!.toLowerCase())
            ? textStyle?.copyWith(fontWeight: FontWeight.bold)
            : textStyle;
        return TextSpan(text: e, style: style);
      }).toList();

      // Create RichText
      messageWidget = SelectableText.rich(
        TextSpan(children: <TextSpan>[...textSpanWidgetList]),
        selectionHeightStyle: BoxHeightStyle.max,
        toolbarOptions: const ToolbarOptions(copy: true, selectAll: true),
      );
    } else {
      // Create Text
      messageWidget = SelectableText(
        message.story,
        toolbarOptions: const ToolbarOptions(copy: true, selectAll: true),
        selectionHeightStyle: BoxHeightStyle.max,
        style: textStyle,
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // -- MESSAGE --
          messageWidget,

          // -- PADDING --
          const SizedBox(height: 10.0),

          //
          // -- MESSAGE INFO --
          //
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              // -- CREATED TIME --
              Expanded(
                child: Text(
                  genCreatedTimeInfo(message.createdTime),
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: Theme.of(context)
                      .textTheme
                      .caption
                      ?.copyWith(fontSize: 12),
                ),
              ),
              Row(
                children: <Widget>[
                  // -- STARRED --
                  StarIconButton(starred: message.starred, onPressed: onStar),

                  // -- DELETE BUTTON --
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline_rounded, size: 20.0),
                  ),
                ],
              ),
            ],
          ),
          // -- THREAD --
          if (message.threadId != null) ThreadInfoWidget(label: threadName),
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

class StarIconButton extends StatelessWidget {
  const StarIconButton({
    Key? key,
    required this.starred,
    required this.onPressed,
  }) : super(key: key);

  final int starred;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    final icon = starred == 1
        ? const Icon(Icons.star_rounded, color: Colors.yellow)
        : const Icon(Icons.star_outline_rounded);

    return IconButton(
      icon: icon,
      onPressed: onPressed,
      iconSize: 20.0,
    );
  }
}

class ThreadInfoWidget extends StatelessWidget {
  const ThreadInfoWidget({Key? key, required this.label}) : super(key: key);

  final String label;

  @override
  Widget build(BuildContext context) {
    return // -- THREAD --
        Container(
      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 2.5),
      decoration: const BoxDecoration(
        color: threadInfoBgColor,
        borderRadius: BorderRadius.all(Radius.circular(3)),
      ),
      child: Text(
        label,
        overflow: TextOverflow.fade,
        softWrap: false,
        style: Theme.of(context).textTheme.caption?.copyWith(
              fontSize: 12,
              color: Colors.black,
            ),
      ),
    );
  }
}
