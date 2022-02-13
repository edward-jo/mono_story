import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mono_story/constants.dart';
import 'package:mono_story/ui/views/main/home/common/new_thread_bottom_sheet.dart';
import 'package:mono_story/ui/views/main/home/common/thread_list_bottom_sheet.dart';
import 'package:mono_story/ui/views/main/home/message_listview.dart';
import 'package:mono_story/ui/views/main/home/message_search_delegate.dart';
import 'package:mono_story/ui/views/main/home/new_message/new_message_screen.dart';
import 'package:mono_story/ui/views/main/home/thread_button.dart';
import 'package:mono_story/view_models/thread_viewmodel.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ThreadViewModel _threadVM;
  final dynamic _listKey = Platform.isIOS
      ? GlobalKey<SliverAnimatedListState>()
      : GlobalKey<AnimatedListState>();

  @override
  void initState() {
    super.initState();
    _threadVM = context.read<ThreadViewModel>();
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
              showSearch(context: context, delegate: MessageSearchDelegate());
            },
          ),
        ],
      ),

      // -- BODY --
      body: Selector<ThreadViewModel, int?>(
        selector: (_, vm) => vm.currentThreadId,
        builder: (_, id, __) => MessageListView(
          threadId: id,
          listKey: _listKey,
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
        _threadVM.setCurrentThreadId(id: threadId, notify: true);
        break;
      case ThreadListResultType.newThreadRequest:
        final threadId = await _showCreateThreadBottomSheet(context);
        if (threadId == null) break;
        _threadVM.setCurrentThreadId(id: threadId, notify: true);
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
    await Navigator.of(context).pushNamed(
      NewMessageScreen.routeName,
      arguments: NewMessageScreenArgument(
        _threadVM.currentThreadId,
        _listKey,
      ),
    );
  }
}
