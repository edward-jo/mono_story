import 'package:flutter/material.dart';
import 'package:mono_story/constants.dart';
import 'package:mono_story/models/message.dart';
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
  late Future<bool> _searchMessagesFuture;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _searchedVM = context.read<SearchedMessageViewModel>();
    _searchedVM.initMessages();
    _searchMessagesFuture = _searchedVM.searchThreadChunk(widget.query);
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
    return FutureBuilder<bool>(
      future: _searchMessagesFuture,
      builder: (context, snapshot) {
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

        if (!snapshot.data!) {
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
                  controller: _scrollController,
                  onRefresh: () async {
                    _searchedVM.initMessages();
                    await _searchedVM.searchThreadChunk(widget.query);
                  },
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
                              await _starMessage(searchResult[i].id!);
                            },
                            onDelete: () async {
                              await _deleteMessage(searchResult[i].id!);
                            },
                          ),
                        ],
                      );
                    }

                    // -- LOADING INDICATOR --
                    if (_searchedVM.hasNext) {
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
      if (_searchedVM.canLoadMessagesChunk()) {
        await _searchedVM.searchThreadChunk(widget.query);
      }
    }
  }

  Future<void> _starMessage(int? id) async {
    await _searchedVM.starMessage(id!);

    /// No need to update message/starred listview, user should pull down the
    /// ListView to see the updated list.
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
        await _searchedVM.deleteMessage(id!);
        context.read<MessageViewModel>().deleteMessageFromList(id);
        context.read<StarredMessageViewModel>().deleteMessageFromList(id);
        Navigator.of(context).pop();
      },
    );
  }
}
