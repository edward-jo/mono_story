import 'package:flutter/material.dart';
import 'package:mono_story/models/message.dart';
import 'package:mono_story/ui/views/main/home/message_listviewitem.dart';
import 'package:mono_story/view_models/message_viewmodel.dart';
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
  late final MessageViewModel _messageVM;

  @override
  void initState() {
    super.initState();
    _messageVM = context.read<MessageViewModel>();
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
            child: Scrollbar(
              // controller: _scrollController,
              child: ListView.separated(
                // controller: _scrollController,
                itemCount: searchResult.length,
                itemBuilder: (_, i) {
                  return MessageListViewItem(
                    message: searchResult[i],
                    onStar: () async {
                      await _messageVM.starMessage(i);
                    },
                    onDelete: () async {
                      await _messageVM.deleteMessage(i);
                    },
                    emphasis: widget.query,
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
  }
}
