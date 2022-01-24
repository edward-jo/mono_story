import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mono_story/models/thread.dart';
import 'package:mono_story/ui/common/modal_page_route.dart';
import 'package:mono_story/ui/views/main/home/common/new_thread_bottom_sheet.dart';
import 'package:mono_story/ui/views/main/home/common/thread_list_bottom_sheet.dart';
import 'package:mono_story/ui/views/main/home/message_listview.dart';
import 'package:mono_story/ui/views/main/home/new_message/new_message_screen.dart';
import 'package:mono_story/ui/views/main/home/thread_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Thread? _currentThread;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        // -- APP BAR --
        appBar: AppBar(
          automaticallyImplyLeading: false,
          // -- TITLE --
          title: Builder(builder: (context) {
            return ThreadButton(
              name: _currentThread?.name ?? 'All',
              onPressed: () => _showThreadList(context),
            );
          }),
          // -- ACTIONS --
          actions: <Widget>[
            Builder(builder: (context) {
              return IconButton(
                onPressed: () => _showNewMessage(context),
                icon: const Icon(Icons.add_outlined),
              );
            })
          ],
        ),

        // -- BODY --
        body: const SafeArea(
          child: MessageListView(),
        ),
      ),
    );
  }

  void _showThreadList(BuildContext context) async {
    final ThreadNameListResult? result;
    result = await showModalBottomSheet<ThreadNameListResult>(
      context: context,
      backgroundColor: Theme.of(context).canvasColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (_) => const ThreadListBottomSheet(),
    );

    if (result == null) return;

    switch (result.type) {
      case ThreadListResultType.thread:
        final thread = result.data as Thread;
        developer.log('Selected thread name is ${thread.name}');
        setState(() => _currentThread = thread);
        break;
      case ThreadListResultType.newThreadRequest:
        _showNewThread(context);
        break;
    }
    return;
  }

  void _showNewMessage(BuildContext context) {
    Navigator.of(context).push(
      ModalPageRoute(
        child: const NewMessageScreen(),
        settings: RouteSettings(
          arguments: NewMessageScreenArguments(thread: _currentThread),
        ),
      ),
    );
  }

  void _showNewThread(BuildContext context) async {
    final Thread? newThread = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).canvasColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (_) => const NewThreadBottomSheet(),
    );

    if (newThread == null || newThread.name.isEmpty) return;

    developer.log('New thread name is ${newThread.name}');
    setState(() => _currentThread = newThread);
    return;
  }
}
