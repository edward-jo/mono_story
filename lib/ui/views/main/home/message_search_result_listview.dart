import 'package:flutter/material.dart';
import 'package:mono_story/constants.dart';
import 'package:mono_story/models/message.dart';
import 'package:mono_story/ui/common/mono_divider.dart';
import 'package:mono_story/ui/common/mono_alertdialog.dart';
import 'package:mono_story/ui/common/platform_indicator.dart';
import 'package:mono_story/ui/common/platform_refresh_indicator.dart';
import 'package:mono_story/ui/common/styled_builder_error_widget.dart';
import 'package:mono_story/ui/views/main/home/message_listviewitem.dart';
import 'package:mono_story/view_models/message_viewmodel.dart';
import 'package:mono_story/view_models/searched_message_viewmodel.dart';
import 'package:mono_story/view_models/starred_message_viewmodel.dart';
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
  late final SearchedMessageViewModel _searchedVM;
  late final MessageViewModel _messageVM;
  late final StarredMessageViewModel _starredVM;
  late Future<int> _searchMessagesFuture;
  final _scrollController = ScrollController();
  late final dynamic _listKey;

  @override
  void initState() {
    super.initState();
    _searchedVM = context.read<SearchedMessageViewModel>();
    _messageVM = context.read<MessageViewModel>();
    _starredVM = context.read<StarredMessageViewModel>();
    _searchedVM.initMessages();
    _searchMessagesFuture = _searchedVM.searchThreadChunk(widget.query);
    _searchedVM.removedItemBuilder = _buildRemovedSearchedItem;
    _listKey = _searchedVM.listKey;
    _scrollController.addListener(_scrollListener);
  }

  @override
  void didUpdateWidget(covariant MessageSearchResultListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _searchedVM.initMessages();
    _searchMessagesFuture = _searchedVM.searchThreadChunk(widget.query);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: _searchMessagesFuture,
      builder: _searchedListViewBuilder,
    );
  }

  Widget _searchedListViewBuilder(
    BuildContext context,
    AsyncSnapshot<dynamic> snapshot,
  ) {
    if (snapshot.connectionState != ConnectionState.done) {
      return const Center(
        child: PlatformIndicator(),
      );
    }

    if (snapshot.hasError || !snapshot.hasData) {
      return StyledBuilderErrorWidget(
        message: snapshot.error.toString(),
      );
    }

    if (snapshot.data as int < 0) {
      return const StyledBuilderErrorWidget(
        message: ErrorMessages.messageReadingFailure,
      );
    }

    List<Message> searchResult;
    searchResult = context.watch<SearchedMessageViewModel>().messages;

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
              listKey: _listKey,
              controller: _scrollController,
              itemCount: searchResult.length,
              itemBuilder: (_, i, animation) {
                return _buildSearchedListViewItem(i, animation, searchResult);
              },
              onRefresh: () => _refresh(searchResult),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchedListViewItem(
    int index,
    Animation<double> animation,
    List<Message> list,
  ) {
    final item = list[index];

    return SizeTransition(
      sizeFactor: animation,
      child: Column(
        children: <Widget>[
          if (index != 0) const MonoDivider(),
          MessageListViewItem(
            emphasis: widget.query,
            message: item,
            onStar: () async {
              Message? message = await _searchedVM.starMessage(item.id!);
              // When setting off the starred, if this story exists in the
              // StarredMessage list, then DELETE the story from the list. If
              // the story exists in Message list, then UPDATE its status.
              // If not exist, that means the story is not loaded yet, so do
              // nothing.
              if (message?.starred == 0) {
                if (_starredVM.contains(item.id!)) {
                  _starredVM.deleteMessageFromList(item.id!, notify: true);
                }
                if (_messageVM.contains(item.id!)) {
                  _messageVM.updateMessage(item.id!, notify: true);
                }
              }
            },
            onDelete: () async {
              bool? ret = await _showDeleteMessageAlertDialog(item.id!);
              if (ret != null && ret) {
                final message = await _searchedVM.deleteMessage(item.id!);
                if (message != null) {
                  // Story is already deleted, so just delete the story from
                  // Message list and StarredMessage list if exists. If not
                  // exists, do nothing.
                  if (_messageVM.contains(item.id!)) {
                    _messageVM.deleteMessageFromList(item.id!, notify: true);
                  }
                  if (_starredVM.contains(item.id!)) {
                    _starredVM.deleteMessageFromList(item.id!, notify: true);
                  }
                }
              }
            },
          ),
          // -- LOADING INDICATOR --
          if (index == list.length - 1 && _searchedVM.hasNext)
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

  Widget _buildRemovedSearchedItem(
    int index,
    Message item,
    Animation<double> animation,
  ) {
    return SizeTransition(
      sizeFactor: animation,
      child: Column(
        children: <Widget>[
          if (index != 0) const MonoDivider(),
          MessageListViewItem(
            emphasis: widget.query,
            message: item,
            onStar: () {},
            onDelete: () {},
          ),
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
      if (_searchedVM.canLoadMessagesChunk()) {
        await _searchedVM.searchThreadChunk(widget.query);
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

  Future<void> _refresh(List<Message> list) async {
    _searchedVM.initMessages();
    _searchMessagesFuture = _searchedVM.searchThreadChunk(widget.query);
    setState(() {});
  }
}
