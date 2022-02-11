import 'dart:developer' as developer;

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
import 'package:mono_story/view_models/thread_viewmodel.dart';
import 'package:provider/provider.dart';

class MessageListView extends StatefulWidget {
  const MessageListView({Key? key, required this.threadId}) : super(key: key);

  final int? threadId;

  @override
  State<MessageListView> createState() => _MessageListViewState();
}

class _MessageListViewState extends State<MessageListView> {
  late ThreadViewModel _threadVM;
  late MessageViewModel _messageVM;
  late Future<void> _readMessagesFuture;
  late Future<void> _readThreadsFuture;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _threadVM = context.read<ThreadViewModel>();
    _messageVM = context.read<MessageViewModel>();
    _scrollController.addListener(_scrollListener);
    _readThreadsFuture = _threadVM.getThreadList();
    _readMessagesFuture = _messageVM.readThreadChunk(widget.threadId);
  }

  @override
  void didUpdateWidget(covariant MessageListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _readMessagesFuture = _messageVM.readThreadChunk(widget.threadId);
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
                  controller: _scrollController,
                  onRefresh: () async {
                    _messageVM.initMessages();
                    await _messageVM.readThreadChunk(widget.threadId);
                  },
                  itemCount: messageList.isEmpty ? 0 : messageList.length + 1,
                  itemBuilder: (_, i) {
                    // -- MESSAGE LIST ITEM --
                    if (i < messageList.length) {
                      return Column(
                        children: <Widget>[
                          if (i != 0) const Divider(thickness: 0.5),
                          MessageListViewItem(
                            message: messageList[i],
                            onStar: () async {
                              await _messageVM.starMessage(messageList[i].id!);
                            },
                            onDelete: () async {
                              await _deleteMessage(messageList[i].id!);
                            },
                          ),
                        ],
                      );
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
                        child: Text('nothing more to load!',
                            style: Theme.of(context).textTheme.caption),
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

  void _scrollListener() async {
    if (!_scrollController.position.outOfRange) {
      return;
    }

    if (_scrollController.offset >=
        _scrollController.position.maxScrollExtent) {
      if (_messageVM.canLoadMessagesChunk()) {
        await _messageVM.readThreadChunk(widget.threadId);
      }
    }
  }

  Future<void> _deleteMessage(int? id) async {
    return await MonoAlertDialog.showAlertConfirmDialog(
      context: context,
      title: 'Delete Story',
      content: 'Are you sure you want to delete this Story?',
      cancelActionName: 'Cancel',
      onCancelPressed: () => Navigator.of(context).pop(),
      destructiveActionName: 'Delete',
      onDestructivePressed: () async {
        await _messageVM.deleteMessage(id!);
        Navigator.of(context).pop();
      },
    );
  }
}
