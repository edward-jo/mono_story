import 'package:flutter/material.dart';
import 'package:mono_story/models/message.dart';
import 'package:mono_story/ui/common/platform_indicator.dart';
import 'package:mono_story/ui/common/platform_refresh_indicator.dart';
import 'package:mono_story/ui/views/main/home/message_listviewitem.dart';
import 'package:mono_story/view_models/message_viewmodel.dart';
import 'package:mono_story/view_models/thread_viewmodel.dart';
import 'package:provider/src/provider.dart';

class MessageSearchResultListView extends StatefulWidget {
  const MessageSearchResultListView({
    Key? key,
    required this.query,
  }) : super(key: key);

  final String query;

  @override
  State<MessageSearchResultListView> createState() =>
      _MessageSearchResultListViewState();
}

class _MessageSearchResultListViewState
    extends State<MessageSearchResultListView> {
  late final ThreadViewModel _threadVM;
  late final MessageViewModel _messageVM;
  final _scrollController = ScrollController();
  late final int? _threadId;

  @override
  void initState() {
    super.initState();
    _threadVM = context.read<ThreadViewModel>();
    _messageVM = context.read<MessageViewModel>();
    _scrollController.addListener(_scrollListener);
    _threadId = _threadVM.currentThreadId;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Message> messageList;
    messageList = context.watch<MessageViewModel>().messages;

    final searchResult = messageList
        .where(
          (e) => e.message.toLowerCase().contains(widget.query.toLowerCase()),
        )
        .toList();

    if (searchResult.isEmpty) {
      return Center(
        child: Text(
          'No stories found for \'${widget.query}\'',
          style: Theme.of(context).textTheme.headline6,
        ),
      );
    }

    return Column(
      children: [
        const SizedBox(height: 10.0),
        Expanded(
          child: SizedBox(
            child: PlatformRefreshIndicator(
              controller: _scrollController,
              onRefresh: () => Future.delayed(
                const Duration(milliseconds: 500),
                () async {
                  _messageVM.initMessages();
                  _messageVM.readThreadChunk(_threadId);
                },
              ),
              itemCount: searchResult.isEmpty ? 0 : searchResult.length + 1,
              itemBuilder: (_, i) {
                // -- MESSAGE LIST ITEM --
                if (i < searchResult.length) {
                  return Column(
                    children: <Widget>[
                      if (i != 0) const Divider(thickness: 0.5),
                      MessageListViewItem(
                        emphasis: widget.query,
                        message: searchResult[i],
                        onStar: () async {
                          await _messageVM.starMessage(searchResult[i].id!);
                        },
                        onDelete: () async {
                          await _messageVM.deleteMessage(searchResult[i].id!);
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
  }

  void _scrollListener() async {
    if (!_scrollController.position.outOfRange) {
      return;
    }

    if (_scrollController.offset >=
        _scrollController.position.maxScrollExtent) {
      if (_messageVM.canLoadMessagesChunk()) {
        await _messageVM.readThreadChunk(_threadId);
      }
    }
  }
}
