import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:mono_story/constants.dart';
import 'package:mono_story/models/story.dart';
import 'package:mono_story/models/thread.dart';
import 'package:mono_story/ui/common/mono_divider.dart';
import 'package:mono_story/ui/common/mono_alertdialog.dart';
import 'package:mono_story/ui/common/platform_indicator.dart';
import 'package:mono_story/ui/common/platform_refresh_indicator.dart';
import 'package:mono_story/ui/common/styled_builder_error_widget.dart';
import 'package:mono_story/ui/views/main/home/message_listviewitem.dart';
import 'package:mono_story/view_models/message_viewmodel.dart';
import 'package:mono_story/view_models/starred_message_viewmodel.dart';
import 'package:mono_story/view_models/thread_viewmodel.dart';
import 'package:provider/provider.dart';

class MessageListView extends StatefulWidget {
  const MessageListView({
    Key? key,
    required this.threadId,
    required this.scrollController,
  }) : super(key: key);

  final int? threadId;
  final ScrollController scrollController;

  @override
  State<MessageListView> createState() => _MessageListViewState();
}

class _MessageListViewState extends State<MessageListView> {
  late ThreadViewModel _threadVM;
  late MessageViewModel _messageVM;
  late StarredMessageViewModel _starredVM;
  late Future<void> _readMessagesFuture;
  late Future<void> _readThreadsFuture;
  late final ScrollController _scrollController;
  late final dynamic _listKey;

  @override
  void initState() {
    super.initState();
    _threadVM = context.read<ThreadViewModel>();
    _messageVM = context.read<MessageViewModel>();
    _starredVM = context.read<StarredMessageViewModel>();

    _scrollController = widget.scrollController;
    _scrollController.addListener(_scrollListener);

    _readThreadsFuture = _threadVM.readThreadList();
    _readMessagesFuture = _messageVM.readMessagesChunk(widget.threadId);

    _messageVM.removedItemBuilder = _buildRemovedMessageItem;
    _listKey = _messageVM.listKey;
  }

  @override
  void didUpdateWidget(covariant MessageListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.threadId != widget.threadId) {
      _messageVM.initMessages();
      _readMessagesFuture = _messageVM.readMessagesChunk(widget.threadId);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: Future.wait([
        _readThreadsFuture,
        _readMessagesFuture,
      ]),
      builder: _messageListViewBuilder,
    );
  }

  Widget _messageListViewBuilder(
    BuildContext context,
    AsyncSnapshot<dynamic> snapshot,
  ) {
    // -- INDICATOR --
    if (snapshot.connectionState != ConnectionState.done) {
      return const Center(
        child: PlatformIndicator(),
      );
    }
    // -- ERROR MESSAGE --
    if (snapshot.hasError || !snapshot.hasData) {
      return StyledBuilderErrorWidget(
        message: snapshot.error.toString(),
      );
    }

    // Check snapshots
    var snapshot0 = snapshot.data[0] as List<Thread>?;
    var snapshot1 = snapshot.data[1] as int;
    if (snapshot0 == null || snapshot1 < 0) {
      return const StyledBuilderErrorWidget(
        message: ErrorMessages.messageReadingFailure,
      );
    }

    List<Story> messageList;
    messageList = context.watch<MessageViewModel>().messages;

    if (messageList.isEmpty) {
      return Center(
        child: Text(
          'You don\'t have any stories yet',
          style: Theme.of(context).textTheme.headline6,
        ),
      );
    }

    // -- MESSAGE LIST --
    return Column(
      children: [
        const SizedBox(height: 10.0),
        Expanded(
          child: SizedBox(
            child: PlatformRefreshIndicator(
              listKey: _listKey,
              controller: _scrollController,
              itemCount: messageList.length,
              itemBuilder: (_, i, animation) {
                return _buildMessageListViewItem(i, animation, messageList);
              },
              onRefresh: () => _refresh(messageList),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageListViewItem(
    int index,
    Animation<double> animation,
    List<Story> list,
  ) {
    developer.log(
      '_buildMessageListViewItem( i: $index, len: ${list.length} )',
    );
    final item = list[index];

    return SizeTransition(
      sizeFactor: animation,
      child: Column(
        children: <Widget>[
          if (index != 0) const MonoDivider(thickness: 7.0),
          MessageListViewItem(
            message: item,
            onStar: () async {
              Story? message = await _messageVM.starMessage(item.id!);
              // When setting off the starred, if this story exists in the
              // StarredMessage ListView, then delete the story from that list.
              // If not exist(not loaded yet from DB), do nothing.
              if (message?.starred == 0) {
                if (_starredVM.contains(item.id!)) {
                  _starredVM.deleteMessageFromList(item.id!, notify: true);
                }
              }
              // When setting on the starred, do nothing. User should refresh
              // the StarredMessage ListView.
            },
            onDelete: () async {
              // Show alert dialog to confirm again
              bool? ret = await _showDeleteMessageAlertDialog(item.id!);
              if (ret != null && ret) {
                final message = await _messageVM.deleteMessage(item.id!);
                if (message != null) {
                  // Remove item from Starred Messages if exists.
                  if (_starredVM.contains(item.id!)) {
                    _starredVM.deleteMessageFromList(item.id!, notify: true);
                  }
                }
              }
            },
          ),
          // -- LOADING INDICATOR --
          if (index == list.length - 1 && _messageVM.hasNext)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 5.0),
              child: PlatformIndicator(),
            )
          // -- END MESSAGE --
          else if (index == list.length - 1)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'nothing more to load!',
                  style: Theme.of(context).textTheme.caption,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRemovedMessageItem(
    int index,
    Story item,
    Animation<double> animation,
  ) {
    return SizeTransition(
      sizeFactor: animation,
      child: Column(
        children: <Widget>[
          if (index != 0) const MonoDivider(),
          MessageListViewItem(message: item, onStar: () {}, onDelete: () {}),
        ],
      ),
    );
  }

  void _scrollListener() async {
    if (!_scrollController.position.outOfRange) {
      return;
    }

    if (_scrollController.offset >=
        _scrollController.position.maxScrollExtent) {
      if (_messageVM.canLoadMessagesChunk()) {
        await _messageVM.readMessagesChunk(widget.threadId);
      }
    }
  }

  Future<bool?> _showDeleteMessageAlertDialog(int? id) async {
    return await MonoAlertDialog().show<bool>(
      context: context,
      title: const Text('Delete Story'),
      content: const Text('Are you sure you want to delete this Story?'),
      cancel: const Text('Cancel'),
      onCancelPressed: () => Navigator.of(context).pop(false),
      destructive: const Text('Delete'),
      onDestructivePressed: () {
        Navigator.of(context).pop(true);
      },
    );
  }

  Future<void> _refresh(List<Story> list) async {
    _messageVM.initMessages();
    _readMessagesFuture = _messageVM.readMessagesChunk(widget.threadId);
    setState(() {});
  }
}
