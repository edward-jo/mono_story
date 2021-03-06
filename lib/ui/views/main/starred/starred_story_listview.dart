import 'package:flutter/material.dart';
import 'package:mono_story/constants.dart';
import 'package:mono_story/models/story.dart';
import 'package:mono_story/ui/common/mono_alertdialog.dart';
import 'package:mono_story/ui/common/platform_indicator.dart';
import 'package:mono_story/ui/common/platform_refresh_indicator.dart';
import 'package:mono_story/ui/common/styled_builder_error_widget.dart';
import 'package:mono_story/ui/views/main/home/common/new_thread_bottom_sheet.dart';
import 'package:mono_story/ui/views/main/home/common/thread_list_bottom_sheet.dart';
import 'package:mono_story/ui/views/main/starred/starred_story_listviewitem.dart';
import 'package:mono_story/view_models/starred_story_viewmodel.dart';
import 'package:mono_story/view_models/story_viewmodel.dart';
import 'package:provider/src/provider.dart';

class StarredStoryListView extends StatefulWidget {
  const StarredStoryListView({
    Key? key,
    required this.scrollController,
  }) : super(key: key);

  final ScrollController scrollController;

  @override
  State<StarredStoryListView> createState() => _StarredStoryListViewState();
}

class _StarredStoryListViewState extends State<StarredStoryListView> {
  late final StarredStoryViewModel _starredVM;
  late final StoryViewModel _storyVM;
  late Future<int> _starredStoriesFuture;
  late final ScrollController _scrollController;
  late final dynamic _listKey;

  @override
  void initState() {
    super.initState();
    _starredVM = context.read<StarredStoryViewModel>();
    _storyVM = context.read<StoryViewModel>();
    _starredVM.initStories();
    _starredStoriesFuture = _starredVM.readStarredStoriesChunk();
    _starredVM.removedItemBuilder = _buildRemovedStarredItem;
    _listKey = _starredVM.listKey;
    _scrollController = widget.scrollController;
    _scrollController.addListener(_scrollListener);
  }

  @override
  void didUpdateWidget(covariant StarredStoryListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _starredVM.initStories();
    _starredStoriesFuture = _starredVM.readStarredStoriesChunk();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: _starredStoriesFuture,
      builder: _starredStoryListViewBuilder,
    );
  }

  Widget _starredStoryListViewBuilder(
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
        message: ErrorMessages.storyReadingFailure,
      );
    }

    List<Story> starredList;
    starredList = context.watch<StarredStoryViewModel>().stories;

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
    List<Story> list,
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

          StarredStoryListViewItem(
            story: item,
            onStar: () async {
              await _starredVM.starStory(item.id!, notify: true);
              if (_storyVM.contains(item.id!)) {
                await _storyVM.updateStory(item.id!, notify: true);
              }
            },
            onDelete: () async {
              bool? ret = await _showDeleteStarredStoryAlertDialog(item.id!);
              if (ret != null && ret) {
                final story = await _starredVM.deleteStory(
                  item.id!,
                  notify: true,
                );
                if (story != null && _storyVM.contains(item.id!)) {
                  _storyVM.deleteStoryFromList(item.id!, notify: true);
                }
              }
            },
            onChangeThread: () => _showThreadListBottomSheet(context, item.id!),
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
    Story item,
    Animation<double> animation,
  ) {
    return SizeTransition(
      sizeFactor: animation,
      child: Column(
        children: <Widget>[
          StarredStoryListViewItem(
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
      if (_starredVM.canLoadStoriesChunk()) {
        await _starredVM.readStarredStoriesChunk();
      }
    }
  }

  Future<bool?> _showDeleteStarredStoryAlertDialog(int? id) async {
    return await MonoAlertDialog().show<bool>(
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
    _starredVM.initStories();
    _starredStoriesFuture = _starredVM.readStarredStoriesChunk();
    setState(() {});
  }

  void _showThreadListBottomSheet(BuildContext context, int id) async {
    final ThreadListResult? result;
    final mediaQueryData = MediaQuery.of(context);
    result = await showModalBottomSheet<ThreadListResult>(
      context: context,
      isScrollControlled: true,
      builder: (context) => MediaQuery(
        data: mediaQueryData,
        child: const SafeArea(
          minimum: EdgeInsets.symmetric(vertical: 20.0),
          child: ThreadListBottomSheet(),
        ),
      ),
    );

    if (result == null) return;

    switch (result.type) {
      case ThreadListResultType.thread:
        final threadId = result.data as int?;
        if (await _starredVM.changeThread(id, threadId) != null) {
          if (_storyVM.contains(id)) {
            await _storyVM.updateStory(id, notify: true);
          }
        }
        break;
      case ThreadListResultType.newThreadRequest:
        final threadId = await _showCreateThreadBottomSheet(context);
        if (threadId == null) break;
        if (await _starredVM.changeThread(id, threadId) != null) {
          if (_storyVM.contains(id)) {
            await _storyVM.updateStory(id, notify: true);
          }
        }
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
