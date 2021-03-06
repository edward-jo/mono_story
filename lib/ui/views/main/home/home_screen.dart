import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mono_story/constants.dart';
import 'package:mono_story/models/story.dart';
import 'package:mono_story/ui/views/main/home/common/new_thread_bottom_sheet.dart';
import 'package:mono_story/ui/views/main/home/common/thread_list_bottom_sheet.dart';
import 'package:mono_story/ui/views/main/home/new_story/new_story_screen.dart';
import 'package:mono_story/ui/views/main/home/story_listview.dart';
import 'package:mono_story/ui/views/main/home/story_search_delegate.dart';
import 'package:mono_story/view_models/story_viewmodel.dart';
import 'package:mono_story/view_models/thread_viewmodel.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  late ThreadViewModel _threadVM;
  late StoryViewModel _storyVM;

  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _threadVM = context.read<ThreadViewModel>();
    _storyVM = context.read<StoryViewModel>();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);
    return Scaffold(
      // -- APP BAR --
      appBar: AppBar(
        automaticallyImplyLeading: false,
        // -- TITLE --
        title: Consumer<ThreadViewModel>(
          builder: (context, model, _) => Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              model.currentThreadData?.name ?? defaultThreadName,
              style: GoogleFonts.robotoMono(
                textStyle: Theme.of(context).textTheme.headline6,
              ),
            ),
          ),
        ),

        // -- ACTIONS --
        actions: <Widget>[
          IconButton(
            icon: Icon(
              MonoIcons.thread_icon,
            ),
            onPressed: () => _showThreadListBottomSheet(context),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: StorySearchDelegate());
            },
          ),
        ],
      ),

      // -- BODY --
      body: Selector<ThreadViewModel, int?>(
        selector: (_, vm) => vm.currentThreadId,
        builder: (_, id, __) {
          return MediaQuery(
            data: mediaQueryData,
            child: StoryListView(
              threadId: id,
              scrollController: scrollController,
            ),
          );
        },
      ),

      // FLOATING BUTTON
      floatingActionButton: FloatingActionButton(
        onPressed: () => _pushNewStoryScreen(context),
        child: const Icon(Icons.add),
        tooltip: 'Create new story',
      ),
    );
  }

  void _showThreadListBottomSheet(BuildContext context) async {
    final ThreadListResult? result;
    final mediaQueryData = MediaQuery.of(context);
    result = await showModalBottomSheet<ThreadListResult>(
      context: context,
      isScrollControlled: true,
      builder: (_) => MediaQuery(
        data: mediaQueryData,
        child: const SafeArea(
          minimum: EdgeInsets.symmetric(vertical: 20.0),
          child: ThreadListBottomSheet(seeAllOption: true),
        ),
      ),
    );

    if (result == null) return;

    switch (result.type) {
      case ThreadListResultType.thread:
        final threadId = result.data as int?;
        _threadVM.setCurrentThreadId(threadId, notify: true);
        break;
      case ThreadListResultType.newThreadRequest:
        final threadId = await _showCreateThreadBottomSheet(context);
        if (threadId == null) break;
        _threadVM.setCurrentThreadId(threadId, notify: true);
        break;
    }
    return;
  }

  Future<int?> _showCreateThreadBottomSheet(BuildContext context) async {
    return await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const NewThreadBottomSheet(),
    );
  }

  void _pushNewStoryScreen(BuildContext context) async {
    var ret = await Navigator.of(context).pushNamed(
      NewStoryScreen.routeName,
      arguments: NewStoryScreenArgument(_threadVM.currentThreadId),
    );

    ret = ret as NewStoryScreenResult?;

    if (ret == null) return;

    // XXX: Animation does not work after removing all items. During NewStory
    // Screen disappears, Flutter already draws the saved item on the Animated-
    // List. So, in order to show the animation, need this delay time.
    await Future.delayed(const Duration(milliseconds: 200));

    await _storyVM.save(
      Story(
        id: null,
        story: ret.story,
        threadId: ret.savedStoryThreadId,
        createdTime: DateTime.now().toUtc(),
        starred: 0,
      ),
      insertAfterSaving: (_threadVM.currentThreadId == null ||
          _threadVM.currentThreadId == ret.savedStoryThreadId),
      // If list is empty, need to rebuild home screen since AnimatedList was
      // not created. So if not rebuild, the inserted story will not show on the
      // screen.
      notify: _storyVM.stories.isEmpty,
    );
  }

  void scrollToTop() {
    if (_storyVM.stories.isEmpty) return;

    scrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeIn,
    );
  }
}
