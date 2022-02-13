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
  late Future<void> _readMessagesFuture;
  late Future<void> _readThreadsFuture;
  final _scrollController = ScrollController();
  late final dynamic _listKey;

  @override
  void initState() {
    super.initState();
    _threadVM = context.read<ThreadViewModel>();
    _messageVM = context.read<MessageViewModel>();
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
      builder: (context, snapshot) {
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
        var snapshot1 = snapshot.data[1] as bool;
        if (snapshot0 == null || !snapshot1) {
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
                  onRefresh: () async {
                    _messageVM.initMessages();
                    await _messageVM.readMessagesChunk(widget.threadId);
                  },
                  itemCount: messageList.isEmpty ? 0 : messageList.length + 1,
                  itemBuilder: (_, i, animation) {
                    // -- MESSAGE LIST ITEM --
                    if (i < messageList.length) {
                      return _buildItem(messageList[i], i, animation);
                    }

                    // -- LOADING INDICATOR --
                    if (_messageVM.hasNext) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 5.0),
                        child: PlatformIndicator(),
                      );
                    }

                    // -- END MESSAGE --
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'nothing more to load!',
                          style: Theme.of(context).textTheme.caption,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildItem(Message item, int index, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: Column(
        children: <Widget>[
          if (index != 0) const Divider(thickness: 0.5),
          MessageListViewItem(
            message: item,
            onStar: () async {
              await _starMessage(item.id!);
            },
            onDelete: () async {
              final message = await _showDeleteMessageAlertDialog(item.id!);
              if (message != null) {
                _listKey.currentState?.removeItem(
                  index,
                  (context, animation) => _buildRemovedItem(
                    message,
                    index,
                    animation,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRemovedItem(
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
        await _messageVM.readMessagesChunk(widget.threadId);
      }
    }
  }

  Future<void> _starMessage(int? id) async {
    await _messageVM.starMessage(id!);

    /// No need to update message/starred listview, user should pull down the
    /// ListView to see the updated list.
  }

  Future<Message?> _showDeleteMessageAlertDialog(int? id) async {
    return await MonoAlertDialog.showAlertConfirmDialog(
      context: context,
      title: 'Delete Story',
      content: 'Are you sure you want to delete this Story?',
      cancelActionName: 'Cancel',
      onCancelPressed: () => Navigator.of(context).pop(),
      destructiveActionName: 'Delete',
      onDestructivePressed: () async {
        final message = await _messageVM.deleteMessage(id!);
        context.read<StarredMessageViewModel>().deleteMessageFromList(id);
        Navigator.of(context).pop(message);
      },
    );
  }
}
