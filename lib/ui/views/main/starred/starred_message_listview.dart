import 'package:flutter/material.dart';
import 'package:mono_story/constants.dart';
import 'package:mono_story/models/message.dart';
import 'package:mono_story/ui/common/mono_alertdialog.dart';
import 'package:mono_story/ui/common/platform_indicator.dart';
import 'package:mono_story/ui/common/platform_refresh_indicator.dart';
import 'package:mono_story/ui/common/styled_builder_error_widget.dart';
import 'package:mono_story/ui/views/main/home/message_listviewitem.dart';
import 'package:mono_story/view_models/message_viewmodel.dart';
import 'package:mono_story/view_models/starred_message_viewmodel.dart';
import 'package:mono_story/view_models/thread_viewmodel.dart';
import 'package:provider/src/provider.dart';

class StarredMessageListView extends StatefulWidget {
  const StarredMessageListView({
    Key? key,
  }) : super(key: key);

  @override
  State<StarredMessageListView> createState() => _StarredMessageListViewState();
}

class _StarredMessageListViewState extends State<StarredMessageListView> {
  late final StarredMessageViewModel _starredVM;
  late Future<bool> _starredMessagesFuture;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _starredVM = context.read<StarredMessageViewModel>();
    _starredVM.initMessages();
    _starredMessagesFuture = _starredVM.searchStarredThreadChunk();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void didUpdateWidget(covariant StarredMessageListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _starredVM.initMessages();
    _starredMessagesFuture = _starredVM.searchStarredThreadChunk();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _starredMessagesFuture,
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

        List<Message> starredList;
        starredList = context.watch<StarredMessageViewModel>().messages;

        if (starredList.isEmpty) {
          return Center(
            child: Text(
              'No starred stories found',
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
                    _starredVM.initMessages();
                    await _starredVM.searchStarredThreadChunk();
                  },
                  itemCount: starredList.isEmpty ? 0 : starredList.length + 1,
                  itemBuilder: (_, i) {
                    // -- MESSAGE LIST ITEM --
                    if (i < starredList.length) {
                      return Column(
                        children: <Widget>[
                          if (i != 0) const Divider(thickness: 0.5),
                          MessageListViewItem(
                            message: starredList[i],
                            onStar: () async {
                              await _starMessage(starredList[i].id!);
                            },
                            onDelete: () async {
                              await _deleteStarredMessage(starredList[i].id!);
                            },
                          ),
                        ],
                      );
                    }

                    // -- LOADING INDICATOR --
                    if (_starredVM.hasNext) {
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
      if (_starredVM.canLoadMessagesChunk()) {
        await _starredVM.searchStarredThreadChunk();
      }
    }
  }

  Future<void> _starMessage(int? id) async {
    await _starredVM.starMessage(id!);

    /// No need to update message/starred listview, user should pull down the
    /// ListView to see the updated list.
  }

  Future<void> _deleteStarredMessage(int? id) async {
    return await MonoAlertDialog.showAlertConfirmDialog(
      context: context,
      title: 'Delete Story',
      content: 'Are you sure you want to delete this Story?',
      cancelActionName: 'Cancel',
      onCancelPressed: () => Navigator.of(context).pop(),
      destructiveActionName: 'Delete',
      onDestructivePressed: () async {
        await _starredVM.deleteMessage(id!);
        context.read<MessageViewModel>().deleteMessageFromList(id);
        Navigator.of(context).pop();
      },
    );
  }
}
