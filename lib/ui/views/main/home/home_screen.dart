import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mono_story/constants.dart';
import 'package:mono_story/models/story.dart';
import 'package:mono_story/ui/views/main/home/common/new_thread_bottom_sheet.dart';
import 'package:mono_story/ui/views/main/home/common/thread_list_bottom_sheet.dart';
import 'package:mono_story/ui/views/main/home/story_listview.dart';
import 'package:mono_story/ui/views/main/home/story_search_delegate.dart';
import 'package:mono_story/ui/views/main/home/new_message/new_message_screen.dart';
import 'package:mono_story/ui/views/main/home/thread_button.dart';
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
  late StoryViewModel _messageVM;

  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _threadVM = context.read<ThreadViewModel>();
    _messageVM = context.read<StoryViewModel>();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // -- APP BAR --
      appBar: AppBar(
        automaticallyImplyLeading: false,
        // -- TITLE --
        title: Consumer<ThreadViewModel>(
          builder: (context, model, _) => ThreadButton(
            name: model.currentThreadData?.name ?? defaultThreadName,
            onPressed: () => _showThreadListBottomSheet(context),
          ),
        ),

        // -- ACTIONS --
        actions: <Widget>[
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
        builder: (_, id, __) => StoryListView(
          threadId: id,
          scrollController: scrollController,
        ),
      ),

      // FLOATING BUTTON
      floatingActionButton: FloatingActionButton(
        onPressed: () => _pushNewMessageScreen(context),
        child: const Icon(Icons.add),
        tooltip: 'Create new story',
      ),
    );
  }

  void _showThreadListBottomSheet(BuildContext context) async {
    final ThreadListResult? result;
    result = await showModalBottomSheet<ThreadListResult>(
      context: context,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      isScrollControlled: true,
      backgroundColor: Theme.of(context).canvasColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(bottomSheetRadius),
        ),
      ),
      builder: (_) => const ThreadListBottomSheet(),
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
      backgroundColor: Theme.of(context).canvasColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(bottomSheetRadius),
        ),
      ),
      builder: (_) => const NewThreadBottomSheet(),
    );
  }

  void _pushNewMessageScreen(BuildContext context) async {
    var ret = await Navigator.of(context).pushNamed(
      NewMessageScreen.routeName,
      arguments: NewMessageScreenArgument(_threadVM.currentThreadId),
    );

    ret = ret as NewMessageScreenResult?;

    if (ret == null) return;

    // XXX: Animation does not work after removing all items. During NewMessage
    // Screen disappears, Flutter already draws the saved item on the Animated-
    // List. So, in order to show the animation, need this delay time.
    await Future.delayed(const Duration(milliseconds: 200));

    await _messageVM.save(
      Story(
        id: null,
        story: ret.message,
        threadId: ret.savedMessageThreadId,
        createdTime: DateTime.now().toUtc(),
        starred: 0,
      ),
      insertAfterSaving: (_threadVM.currentThreadId == null ||
          _threadVM.currentThreadId == ret.savedMessageThreadId),
      // If list is empty, need to rebuild home screen since AnimatedList was
      // not created. So if not rebuild, the inserted story will not show on the
      // screen.
      notify: _messageVM.stories.isEmpty,
    );
  }

  void scrollToTop() {
    if (_messageVM.stories.isEmpty) return;

    scrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeIn,
    );
  }
}
