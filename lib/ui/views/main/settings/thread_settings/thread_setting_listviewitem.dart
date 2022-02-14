import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mono_story/constants.dart';
import 'package:mono_story/models/thread.dart';

class ThreadSettingListViewItem extends StatefulWidget {
  const ThreadSettingListViewItem({
    Key? key,
    required this.thread,
    required this.animation,
    required this.onPressed,
  }) : super(key: key);

  final Thread thread;
  final Animation<double> animation;
  final void Function() onPressed;

  @override
  _ThreadSettingListViewItemState createState() =>
      _ThreadSettingListViewItemState();
}

class _ThreadSettingListViewItemState extends State<ThreadSettingListViewItem> {
  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: widget.animation,
      child: ListTile(
        leading: Icon(MonoIcons.thread_icon),
        title: Text(widget.thread.name),
        trailing: IconButton(
          icon: Icon(MonoIcons.more),
          onPressed: widget.onPressed,
        ),
      ),
    );
  }
}
