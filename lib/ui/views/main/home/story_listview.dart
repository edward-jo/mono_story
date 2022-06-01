import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:mono_story/constants.dart';
import 'package:mono_story/models/story.dart';
import 'package:mono_story/models/thread.dart';
import 'package:mono_story/ui/common/mono_alertdialog.dart';
import 'package:mono_story/ui/common/mono_divider.dart';
import 'package:mono_story/ui/common/platform_indicator.dart';
import 'package:mono_story/ui/common/platform_refresh_indicator.dart';
import 'package:mono_story/ui/common/styled_builder_error_widget.dart';
import 'package:mono_story/ui/views/main/home/common/new_thread_bottom_sheet.dart';
import 'package:mono_story/ui/views/main/home/common/thread_list_bottom_sheet.dart';
import 'package:mono_story/ui/views/main/home/story_listviewitem.dart';
import 'package:mono_story/view_models/starred_story_viewmodel.dart';
import 'package:mono_story/view_models/story_viewmodel.dart';
import 'package:mono_story/view_models/thread_viewmodel.dart';
import 'package:provider/provider.dart';

class StoryListView extends StatefulWidget {
  const StoryListView({
    Key? key,
    required this.threadId,
    required this.scrollController,
  }) : super(key: key);

  final int? threadId;
  final ScrollController scrollController;

  @override
  State<StoryListView> createState() => _StoryListViewState();
}

class _StoryListViewState extends State<StoryListView> {
  late ThreadViewModel _threadVM;
  late StoryViewModel _storyVM;
  late StarredStoryViewModel _starredVM;
  late Future<void> _readStoriesFuture;
  late Future<void> _readThreadsFuture;
  late final ScrollController _scrollController;
  late final dynamic _listKey;

  @override
  void initState() {
    super.initState();
    _threadVM = context.read<ThreadViewModel>();
    _storyVM = context.read<StoryViewModel>();
    _starredVM = context.read<StarredStoryViewModel>();

    _scrollController = widget.scrollController;
    _scrollController.addListener(_scrollListener);

    _readThreadsFuture = _threadVM.readThreadList();
    _readStoriesFuture = _storyVM.readStoriesChunk(widget.threadId);

    _storyVM.removedItemBuilder = _buildRemovedStoryItem;
    _listKey = _storyVM.listKey;
  }

  @override
  void didUpdateWidget(covariant StoryListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.threadId != widget.threadId) {
      _storyVM.initStories();
      _readStoriesFuture = _storyVM.readStoriesChunk(widget.threadId);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: Future.wait([
        _readThreadsFuture,
        _readStoriesFuture,
      ]),
      builder: _storyListViewBuilder,
    );
  }

  Widget _storyListViewBuilder(
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
        message: ErrorMessages.storyReadingFailure,
      );
    }

    List<Story> storyList;
    storyList = context.watch<StoryViewModel>().stories;

    if (storyList.isEmpty) {
      return Center(
        child: Text(
          'You don\'t have any stories yet',
          style: Theme.of(context).textTheme.headline6,
        ),
      );
    }

    // -- STORY LIST --
    return Column(
      children: [
        const SizedBox(height: 10.0),
        Expanded(
          child: SizedBox(
            child: PlatformRefreshIndicator(
              listKey: _listKey,
              controller: _scrollController,
              itemCount: storyList.length,
              itemBuilder: (_, i, animation) {
                return _buildStoryListViewItem(i, animation, storyList);
              },
              onRefresh: () => _refresh(storyList),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStoryListViewItem(
    int index,
    Animation<double> animation,
    List<Story> list,
  ) {
    developer.log(
      '_buildStoryListViewItem( i: $index, len: ${list.length} )',
    );
    final item = list[index];

    return SizeTransition(
      sizeFactor: animation,
      child: Column(
        children: <Widget>[
          if (index != 0) const MonoDivider(thickness: 7.0),
          StoryListViewItem(
            story: item,
            onStar: () async {
              Story? story = await _storyVM.starStory(item.id!);
              // When setting off the starred, if this story exists in the
              // StarredStory ListView, then delete the story from that list.
              // If not exist(not loaded yet from DB), do nothing.
              if (story?.starred == 0) {
                if (_starredVM.contains(item.id!)) {
                  _starredVM.deleteStoryFromList(item.id!, notify: true);
                }
              }
              // When setting on the starred, do nothing. User should refresh
              // the StarredStory ListView.
            },
            onDelete: () async {
              // Show alert dialog to confirm again
              bool? ret = await _showDeleteStoryAlertDialog(item.id!);
              if (ret != null && ret) {
                final story = await _storyVM.deleteStory(item.id!);
                if (story != null) {
                  // Remove item from Starred Stories if exists.
                  if (_starredVM.contains(item.id!)) {
                    _starredVM.deleteStoryFromList(item.id!, notify: true);
                  }
                }
              }
            },
            onChangeThread: () => _showThreadListBottomSheet(context, item.id!),
          ),
          // -- LOADING INDICATOR --
          if (index == list.length - 1 && _storyVM.hasNext)
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

  Widget _buildRemovedStoryItem(
    int index,
    Story item,
    Animation<double> animation,
  ) {
    return SizeTransition(
      sizeFactor: animation,
      child: Column(
        children: <Widget>[
          if (index != 0) const MonoDivider(),
          StoryListViewItem(
            story: item,
            onStar: () {},
            onDelete: () {},
            onChangeThread: () {},
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
      if (_storyVM.canLoadStoriesChunk()) {
        await _storyVM.readStoriesChunk(widget.threadId);
      }
    }
  }

  Future<bool?> _showDeleteStoryAlertDialog(int? id) async {
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

  Future<void> _refresh(List<Story> list) async {
    _storyVM.initStories();
    _readStoriesFuture = _storyVM.readStoriesChunk(widget.threadId);
    setState(() {});
  }

  void _showThreadListBottomSheet(BuildContext context, int id) async {
    final ThreadListResult? result;
    result = await showModalBottomSheet<ThreadListResult>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const ThreadListBottomSheet(),
    );

    if (result == null) return;

    switch (result.type) {
      case ThreadListResultType.thread:
        final threadId = result.data as int?;
        await _storyVM.changeThread(id, threadId);
        break;
      case ThreadListResultType.newThreadRequest:
        final threadId = await _showCreateThreadBottomSheet(context);
        if (threadId == null) break;
        await _storyVM.changeThread(id, threadId);
        break;
    }
  }

  Future<int?> _showCreateThreadBottomSheet(BuildContext context) async {
    return await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const NewThreadBottomSheet(),
    );
  }
}
