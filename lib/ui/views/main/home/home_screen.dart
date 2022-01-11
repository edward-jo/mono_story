import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'thread_select_button.dart';
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
          title: Builder(builder: (context) {
            return ThreadSelectButton(
              name: _currentThread,
              onPressed: () => showThreadSelectList(context),
            );
          }),
          actions: <Widget>[
            IconButton(onPressed: () {}, icon: const Icon(Icons.add_outlined))
          ],
        ),

        // -- BODY --
        body: const SafeArea(
          child: MessageListView(),
        ),
      ),
    );
  }

  void showThreadSelectList(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: const Center(child: Text('Thread list')),
        );
      },
    );
  }
}
