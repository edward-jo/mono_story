import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mono_story/constants.dart';
import 'package:mono_story/models/message.dart';
import 'package:mono_story/models/thread.dart';
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
    required this.listKey,
  }) : super(key: key);

  final int? threadId;
  final Key listKey;

  @override
  State<MessageListView> createState() => _MessageListViewState();
}

class _MessageListViewState extends State<MessageListView> {
  late ThreadViewModel _threadVM;
  late MessageViewModel _messageVM;
  late StarredMessageViewModel _starredVM;
  late Future<void> _readMessagesFuture;
  late Future<void> _readThreadsFuture;
  final _scrollController = ScrollController();
  late final dynamic _listKey;

  @override
  void initState() {
    super.initState();
    _threadVM = context.read<ThreadViewModel>();
    _messageVM = context.read<MessageViewModel>();
    _starredVM = context.read<StarredMessageViewModel>();
    _scrollController.addListener(_scrollListener);
    _readThreadsFuture = _threadVM.readThreadList();
    _readMessagesFuture = _messageVM.readMessagesChunk(widget.threadId);
    _listKey = Platform.isIOS
        ? widget.listKey as GlobalKey<SliverAnimatedListState>
        : widget.listKey as GlobalKey<AnimatedListState>;
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
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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

    List<Message> messageList;
    messageList = context.watch<MessageViewModel>().messages;

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
    List<Message> list,
  ) {
    developer.log('itemBuilder($index/${list.length}):');
    final item = list[index];

    return SizeTransition(
      sizeFactor: animation,
      child: Column(
        children: <Widget>[
          if (index != 0) const Divider(thickness: 0.5),
          MessageListViewItem(
            message: list[index],
            onStar: () async => await _starMessage(item.id!),
            onDelete: () async {
              // Show alert dialog to confirm again
              bool? ret = await _showDeleteMessageAlertDialog(item.id!);
              if (ret != null && ret) {
                final message = await _messageVM.deleteMessage(item.id!);
                if (message != null) {
                  // Animate removed item
                  _listKey.currentState?.removeItem(
                    index,
                    (context, animation) => _buildRemovedMessageItem(
                      message,
                      index,
                      animation,
                    ),
                  );
                  // Remove item from Starred Messages
                  _starredVM.deleteMessageFromList(item.id!, notify: true);
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
    Message item,
    int index,
    Animation<double> animation,
  ) {
    return SizeTransition(
      sizeFactor: animation,
      child: Column(
        children: <Widget>[
          if (index != 0) const Divider(thickness: 0.5),
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
        int length = _messageVM.messages.length;
        int count = await _messageVM.readMessagesChunk(widget.threadId);
        if (count > 0) {
          for (int i = 0; i < count; i++) {
            _listKey.currentState?.insertItem(length + i);
          }
        }
      }
    }
  }

  Future<void> _starMessage(int? id) async {
    await _messageVM.starMessage(id!);

    /// No need to update message/starred listview, user should pull down the
    /// ListView to see the updated list.
  }

  Future<bool?> _showDeleteMessageAlertDialog(int? id) async {
    return await MonoAlertDialog.showAlertConfirmDialog<bool>(
      context: context,
      title: 'Delete Story',
      content: 'Are you sure you want to delete this Story?',
      cancelActionName: 'Cancel',
      onCancelPressed: () => Navigator.of(context).pop(false),
      destructiveActionName: 'Delete',
      onDestructivePressed: () {
        Navigator.of(context).pop(true);
      },
    );
  }

  Future<void> _refresh(List<Message> list) async {
    _messageVM.initMessages();
    _readMessagesFuture = _messageVM.readMessagesChunk(widget.threadId);
    setState(() {});

    // // Remove all messages
    // while (list.isNotEmpty) {
    //   var message = list.removeAt(list.length - 1);
    //   _listKey.currentState?.removeItem(
    //     0,
    //     (context, animation) => Container(),
    //     // (context, animation) => _buildRemovedItem(message, 0, animation),
    //   );
    // }
    // // Remove footer
    // _listKey.currentState?.removeItem(0, (context, animation) => Container());

    // // Start over reading
    // _messageVM.hasNext = true;
    // int count = await _messageVM.readMessagesChunk(widget.threadId);
    // if (count > 0) {
    //   for (int i = 0; i < count; i++) {
    //     _listKey.currentState?.insertItem(i);
    //   }
    //   // Insert footer
    //   _listKey.currentState?.insertItem(count);
    // }
  }
}
