import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mono_story/ui/common/modal_page_route.dart';
import 'package:mono_story/ui/views/main/home/new_message/new_message_screen.dart';

import 'common/new_thread_name_bottom_sheet.dart';
import 'common/thread_name_list_bottom_sheet.dart';
import 'thread_name_button.dart';
import 'message_listview.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _currentThreadName = 'All';

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
            return ThreadNameButton(
              name: _currentThreadName,
              onPressed: () => _showThreadNameList(context),
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

  void _showThreadNameList(BuildContext context) async {
    final ThreadNameListResult? result;
    result = await showModalBottomSheet<ThreadNameListResult>(
      context: context,
      backgroundColor: Theme.of(context).canvasColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (_) => const ThreadNameListBottomSheet(),
    );

    if (result == null) return;

    switch (result.type) {
      case ThreadNameListResultType.threadName:
        final threadName = result.data as String;
        developer.log('Selected thread name is $threadName');
        setState(() => _currentThreadName = threadName);
        break;
      case ThreadNameListResultType.newThreadNameRequest:
        _showNewThreadName(context);
        break;
    }
    return;
  }

  void _showNewMessage(BuildContext context) {
    Navigator.of(context).push(
      ModalPageRoute(
        child: const NewMessageScreen(),
        settings: RouteSettings(
          arguments: NewMessageScreenArguments(threadName: _currentThreadName),
        ),
      ),
    );
  }

  void _showNewThreadName(BuildContext context) async {
    final String? newThreadName = await showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).canvasColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (ctx) {
        return const NewThreadNameBottomSheet();
      },
    );

    if (newThreadName == null || newThreadName.isEmpty) return;

    developer.log('New thread name is $newThreadName');
    setState(() => _currentThreadName = newThreadName);
    return;
  }
}
