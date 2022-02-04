import 'package:flutter/material.dart';
import 'package:mono_story/constants.dart';
import 'package:mono_story/models/message.dart';
import 'package:mono_story/models/thread.dart';
import 'package:mono_story/ui/common/platform_alert_dialog.dart';
import 'package:mono_story/ui/common/platform_indicator.dart';
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
    _readMessagesFuture = _readMessagesFuture = _messageVM.readThreadChunk(
      widget.threadId,
    );
  }

  @override
  void didUpdateWidget(covariant MessageListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _readMessagesFuture = _readMessagesFuture = _messageVM.readThreadChunk(
      widget.threadId,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
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
        // -- ALERT DIALOG --
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
                child: Scrollbar(
                  controller: _scrollController,
                  child: ListView.separated(
                    controller: _scrollController,
                    itemCount: messageList.length,
                    itemBuilder: (_, i) {
                      return MessageListViewItem(
                        message: messageList[i],
                        onStar: () {},
                        onDelete: () async {
                          _messageVM.deleteMessage(i);
                        },
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return const Divider(thickness: 0.5);
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _scrollListener() {
    if (_scrollController.position.outOfRange) return;

    if (_scrollController.offset >=
        _scrollController.position.maxScrollExtent / 2) {
      if (_messageVM.canReadThreadChunk()) {
        _messageVM.readThreadChunk(widget.threadId);
      }
    }
  }
}
