import 'package:flutter/material.dart';
import 'package:mono_story/constants.dart';
import 'package:mono_story/models/message.dart';
import 'package:mono_story/ui/common/mono_dynaimic_alertdialog.dart';
import 'package:mono_story/ui/common/platform_indicator.dart';
import 'package:mono_story/ui/common/platform_refresh_indicator.dart';
import 'package:mono_story/ui/common/styled_builder_error_widget.dart';
import 'package:mono_story/ui/views/main/starred/starred_message_listviewitem.dart';
import 'package:mono_story/view_models/message_viewmodel.dart';
import 'package:mono_story/view_models/starred_message_viewmodel.dart';
import 'package:provider/src/provider.dart';

class StarredMessageListView extends StatefulWidget {
  const StarredMessageListView({
    Key? key,
    required this.scrollController,
  }) : super(key: key);

  final ScrollController scrollController;

  @override
  State<StarredMessageListView> createState() => _StarredMessageListViewState();
}

class _StarredMessageListViewState extends State<StarredMessageListView> {
  late final StarredMessageViewModel _starredVM;
  late final MessageViewModel _messageVM;
  late Future<int> _starredMessagesFuture;
  late final ScrollController _scrollController;
  late final dynamic _listKey;

  @override
  void initState() {
    super.initState();
    _starredVM = context.read<StarredMessageViewModel>();
    _messageVM = context.read<MessageViewModel>();
    _starredVM.initMessages();
    _starredMessagesFuture = _starredVM.searchStarredThreadChunk();
    _starredVM.removedItemBuilder = _buildRemovedStarredItem;
    _listKey = _starredVM.listKey;
    _scrollController = widget.scrollController;
    _scrollController.addListener(_scrollListener);
  }

  @override
  void didUpdateWidget(covariant StarredMessageListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _starredVM.initMessages();
    _starredMessagesFuture = _starredVM.searchStarredThreadChunk();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: _starredMessagesFuture,
      builder: _starredMessageListViewBuilder,
    );
  }

  Widget _starredMessageListViewBuilder(
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

    List<Message> starredList;
    starredList = context.watch<StarredMessageViewModel>().messages;

    if (starredList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'No starred stories found',
              style: Theme.of(context).textTheme.headline6,
            ),
            TextButton(onPressed: _refresh, child: const Text('Refresh'))
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: SizedBox(
            child: PlatformRefreshIndicator(
              listKey: _listKey,
              controller: _scrollController,
              itemCount: starredList.length,
              itemBuilder: (_, i, animation) {
                return _buildStarredListViewItem(i, animation, starredList);
              },
              onRefresh: _refresh,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStarredListViewItem(
    int index,
    Animation<double> animation,
    List<Message> list,
  ) {
    final item = list[index];

    return SizeTransition(
      sizeFactor: animation,
      child: Column(
        children: <Widget>[
          if (index == 0)
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(
                left: 20.0,
                right: 20.0,
                top: 10.0,
                bottom: 0.0,
              ),
              child: Text(
                'STARRED',
                style: Theme.of(context).textTheme.caption?.copyWith(
                      fontSize: 12,
                      color: Colors.black,
                    ),
              ),
            ),

          StarredMessageListViewItem(
            message: item,
            onStar: () async {
              await _starredVM.starMessage(item.id!, notify: true);
              if (_messageVM.contains(item.id!)) {
                await _messageVM.updateMessage(item.id!, notify: true);
              }
            },
            onDelete: () async {
              bool? ret = await _showDeleteStarredMessageAlertDialog(item.id!);
              if (ret != null && ret) {
                final message = await _starredVM.deleteMessage(
                  item.id!,
                  notify: true,
                );
                if (message != null && _messageVM.contains(item.id!)) {
                  _messageVM.deleteMessageFromList(item.id!, notify: true);
                }
              }
            },
          ),
          // -- LOADING INDICATOR --
          if (index == list.length - 1 && _starredVM.hasNext)
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

  Widget _buildRemovedStarredItem(
    int index,
    Message item,
    Animation<double> animation,
  ) {
    return SizeTransition(
      sizeFactor: animation,
      child: Column(
        children: <Widget>[
          StarredMessageListViewItem(
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
      if (_starredVM.canLoadMessagesChunk()) {
        await _starredVM.searchStarredThreadChunk();
      }
    }
  }

  Future<bool?> _showDeleteStarredMessageAlertDialog(int? id) async {
    return await MonoDynamicAlertDialog().showNotifyAlertDialog<bool>(
      context: context,
      title: const Text('Delete Story'),
      content: const Text('Are you sure you want to delete this Story?'),
      cancel: const Text('Cancel'),
      onCancelPressed: () => Navigator.of(context).pop(false),
      destructive: const Text('Delete'),
      onDestructivePressed: () async {
        Navigator.of(context).pop(true);
      },
    );
  }

  Future<void> _refresh() async {
    _starredVM.initMessages();
    _starredMessagesFuture = _starredVM.searchStarredThreadChunk();
    setState(() {});
  }
}
