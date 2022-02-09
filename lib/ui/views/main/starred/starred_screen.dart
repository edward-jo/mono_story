import 'package:flutter/material.dart';
import 'package:mono_story/ui/views/main/starred/starred_message_listview.dart';

class StarredScreen extends StatefulWidget {
  const StarredScreen({Key? key}) : super(key: key);

  @override
  _StarredScreenState createState() => _StarredScreenState();
}

class _StarredScreenState extends State<StarredScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Starred Story'),
      ),
      body: const StarredMessageListView(),
    );
  }
}
