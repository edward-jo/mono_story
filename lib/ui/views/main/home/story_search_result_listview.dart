import 'package:flutter/material.dart';
import 'package:mono_story/constants.dart';
import 'package:mono_story/models/story.dart';
import 'package:mono_story/ui/common/mono_divider.dart';
import 'package:mono_story/ui/common/mono_alertdialog.dart';
import 'package:mono_story/ui/common/platform_indicator.dart';
import 'package:mono_story/ui/common/platform_refresh_indicator.dart';
import 'package:mono_story/ui/common/styled_builder_error_widget.dart';
import 'package:mono_story/ui/views/main/home/story_listviewitem.dart';
import 'package:mono_story/view_models/story_viewmodel.dart';
import 'package:mono_story/view_models/searched_story_viewmodel.dart';
import 'package:mono_story/view_models/starred_story_viewmodel.dart';
import 'package:provider/src/provider.dart';

class StorySearchResultListView extends StatefulWidget {
  const StorySearchResultListView({
    Key? key,
    required this.query,
  }) : super(key: key);

  final String query;

  @override
  State<StorySearchResultListView> createState() =>
      _StorySearchResultListViewState();
}

class _StorySearchResultListViewState
    extends State<StorySearchResultListView> {
  late final SearchedStoryViewModel _searchedVM;
  late final StoryViewModel _storyVM;
  late final StarredStoryViewModel _starredVM;
  late Future<int> _searchStoriesFuture;
  final _scrollController = ScrollController();
  late final dynamic _listKey;

  @override
  void initState() {
    super.initState();
    _searchedVM = context.read<SearchedStoryViewModel>();
    _storyVM = context.read<StoryViewModel>();
    _starredVM = context.read<StarredStoryViewModel>();
    _searchedVM.initStories();
    _searchStoriesFuture = _searchedVM.searchThreadChunk(widget.query);
    _searchedVM.removedItemBuilder = _buildRemovedSearchedItem;
    _listKey = _searchedVM.listKey;
    _scrollController.addListener(_scrollListener);
  }

  @override
  void didUpdateWidget(covariant StorySearchResultListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _searchedVM.initStories();
    _searchStoriesFuture = _searchedVM.searchThreadChunk(widget.query);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: _searchStoriesFuture,
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
        message: ErrorMessages.storyReadingFailure,
      );
    }

    List<Story> searchResult;
    searchResult = context.watch<SearchedStoryViewModel>().stories;

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
    List<Story> list,
  ) {
    final item = list[index];

    return SizeTransition(
      sizeFactor: animation,
      child: Column(
        children: <Widget>[
          if (index != 0) const MonoDivider(),
          StoryListViewItem(
            emphasis: widget.query,
            story: item,
            onStar: () async {
              Story? story = await _searchedVM.starStory(item.id!);
              // When setting off the starred, if this story exists in the
              // StarredStory list, then DELETE the story from the list. If
              // the story exists in Story list, then UPDATE its status.
              // If not exist, that means the story is not loaded yet, so do
              // nothing.
              if (story?.starred == 0) {
                if (_starredVM.contains(item.id!)) {
                  _starredVM.deleteStoryFromList(item.id!, notify: true);
                }
                if (_storyVM.contains(item.id!)) {
                  _storyVM.updateStory(item.id!, notify: true);
                }
              }
            },
            onDelete: () async {
              bool? ret = await _showDeleteStoryAlertDialog(item.id!);
              if (ret != null && ret) {
                final story = await _searchedVM.deleteStory(item.id!);
                if (story != null) {
                  // Story is already deleted, so just delete the story from
                  // Story list and StarredStory list if exists. If not
                  // exists, do nothing.
                  if (_storyVM.contains(item.id!)) {
                    _storyVM.deleteStoryFromList(item.id!, notify: true);
                  }
                  if (_starredVM.contains(item.id!)) {
                    _starredVM.deleteStoryFromList(item.id!, notify: true);
                  }
                }
              }
            },
            onChangeThread: () {},
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
    Story item,
    Animation<double> animation,
  ) {
    return SizeTransition(
      sizeFactor: animation,
      child: Column(
        children: <Widget>[
          if (index != 0) const MonoDivider(),
          StoryListViewItem(
            emphasis: widget.query,
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
      if (_searchedVM.canLoadStoriesChunk()) {
        await _searchedVM.searchThreadChunk(widget.query);
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
    _searchedVM.initStories();
    _searchStoriesFuture = _searchedVM.searchThreadChunk(widget.query);
    setState(() {});
  }
}
