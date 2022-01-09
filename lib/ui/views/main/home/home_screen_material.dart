import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mono_story/ui/views/main/home/message_listview.dart';
import 'package:mono_story/ui/views/main/home/thread_select_button.dart';

import '/constants.dart';

class HomeScreenMaterial extends StatefulWidget {
  const HomeScreenMaterial({Key? key}) : super(key: key);

  @override
  _HomeScreenMaterialState createState() => _HomeScreenMaterialState();
}

class _HomeScreenMaterialState extends State<HomeScreenMaterial> {
  String _currentThread = 'All';

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        // APP BAR
        appBar: AppBar(
          title: ThreadSelectButton(
              name: _currentThread,
              onPressed: () {
                developer.log('Pressed');
              }),
          actions: <Widget>[
            IconButton(onPressed: () {}, icon: const Icon(Icons.add_outlined))
          ],
        ),
        body: const SafeArea(
          child: MessageListView(),
        ),
      ),
    );
  }
}
