import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:mono_story/constants.dart';
import 'package:mono_story/models/story.dart';
import 'package:mono_story/utils/utils.dart';
import 'package:mono_story/view_models/thread_viewmodel.dart';
import 'package:provider/provider.dart';

enum _StoryListViewItemMenu {
  delete,
  changeThread,
}

class StoryListViewItem extends StatefulWidget {
  const StoryListViewItem({
    Key? key,
    required this.story,
    required this.onDelete,
    required this.onStar,
    required this.onChangeThread,
    this.emphasis,
  }) : super(key: key);

  final Story story;
  final void Function() onStar;
  final void Function() onDelete;
  final void Function() onChangeThread;
  final String? emphasis;

  @override
  State<StoryListViewItem> createState() => _StoryListViewItemState();
}

class _StoryListViewItemState extends State<StoryListViewItem> {
  @override
  Widget build(BuildContext context) {
    final threadVM = context.read<ThreadViewModel>();
    final threadName =
        threadVM.findThreadData(id: widget.story.threadId)?.name ?? 'undefined';

    Widget storyWidget;
    TextStyle? textStyle = Theme.of(context).textTheme.bodyText2;
    if (widget.emphasis != null && widget.emphasis!.isNotEmpty) {
      // Generate span list
      final pattern =
          RegExp(widget.emphasis!, caseSensitive: false, unicode: true);
      var textSpanList = splitStringWithPattern(widget.story.story, pattern);
      var textSpanWidgetList = textSpanList.map((e) {
        final style = (e.toLowerCase() == widget.emphasis!.toLowerCase())
            ? textStyle?.copyWith(fontWeight: FontWeight.bold)
            : textStyle;
        return TextSpan(text: e, style: style);
      }).toList();

      // Create RichText
      storyWidget = SelectableText.rich(
        TextSpan(children: <TextSpan>[...textSpanWidgetList]),
        selectionHeightStyle: BoxHeightStyle.max,
        toolbarOptions: const ToolbarOptions(copy: true, selectAll: true),
      );
    } else {
      // Create Text
      storyWidget = SelectableText(
        widget.story.story,
        toolbarOptions: const ToolbarOptions(copy: true, selectAll: true),
        selectionHeightStyle: BoxHeightStyle.max,
        style: textStyle,
      );
    }

    final maxMenuItemWidth = MediaQuery.of(context).size.width * 0.5;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // -- STORY --
          storyWidget,

          // -- PADDING --
          const SizedBox(height: 10.0),

          //
          // -- STORY INFO --
          //
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              // -- CREATED TIME --
              Expanded(
                child: Text(
                  genCreatedTimeInfo(widget.story.createdTime),
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
                  StarIconButton(
                      starred: widget.story.starred, onPressed: widget.onStar),

                  // -- DELETE BUTTON --
                  IconButton(
                    onPressed: widget.onDelete,
                    icon: const Icon(Icons.delete_outline_rounded, size: 20.0),
                  ),

                  // -- POPUP MENU BUTTON --
                  PopupMenuButton<_StoryListViewItemMenu>(
                      onSelected: _popupMenuButtonSelected,
                      itemBuilder: (context) =>
                          <PopupMenuItem<_StoryListViewItemMenu>>[
                            // -- DELETE --
                            _StyledPopupMenuItem(
                              maxWidth: maxMenuItemWidth,
                              menuName: 'Delete',
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                size: 20.0,
                              ),
                              value: _StoryListViewItemMenu.delete,
                            ),

                            // -- CHANGE THREAD
                            _StyledPopupMenuItem(
                              maxWidth: maxMenuItemWidth,
                              menuName: 'Change Thread',
                              icon: Icon(MonoIcons.thread_icon, size: 20.0),
                              value: _StoryListViewItemMenu.changeThread,
                            ),
                          ]),
                ],
              ),
            ],
          ),
          // -- THREAD --
          if (widget.story.threadId != null)
            ThreadInfoWidget(label: threadName),
        ],
      ),
    );
  }

  void _popupMenuButtonSelected(_StoryListViewItemMenu value) {
    switch (value) {
      case _StoryListViewItemMenu.delete:
        widget.onDelete();
        break;
      case _StoryListViewItemMenu.changeThread:
        widget.onChangeThread();
        break;
      default:
        throw Exception('Invalid status');
    }
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

class _StyledPopupMenuItem<T> extends PopupMenuItem<T> {
  _StyledPopupMenuItem({
    Key? key,
    this.maxWidth = double.infinity,
    this.maxHeight = double.infinity,
    required this.menuName,
    required this.icon,
    required T value,
  }) : super(
          key: key,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          value: null,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: maxWidth,
                  maxHeight: maxHeight,
                ),
                child: Text(menuName, softWrap: true),
              ),
              icon,
            ],
          ),
        );

  final String menuName;
  final Icon icon;
  final double maxWidth;
  final double maxHeight;
}
