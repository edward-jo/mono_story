import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mono_story/ui/common/modal_page_route.dart';
import 'package:mono_story/ui/views/main/home/new_message/new_message_screen.dart';

import 'thread_list_bottom_sheet.dart';
import 'thread_name_button.dart';
import 'message_listview.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _currentThread = 'All';

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
              name: _currentThread,
              onPressed: () => _showThreadSelectList(context),
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

  void _showThreadSelectList(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return ThreadListBottomSheet(onTap: (threadName) {
          setState(() {
            _currentThread = threadName;
          });
          Navigator.of(context).pop();
        });
      },
    );
  }

  void _showNewMessage(BuildContext context) {
    Navigator.of(context).push(
      ModalPageRoute(
        child: const NewMessageScreen(),
        settings: RouteSettings(
            arguments: NewMessageScreenArguments(threadName: _currentThread),
      ),
    );
  }
}