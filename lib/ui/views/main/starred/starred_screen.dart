import 'package:flutter/material.dart';
import 'package:mono_story/ui/views/main/starred/starred_message_listview.dart';

class StarredScreen extends StatefulWidget {
  const StarredScreen({Key? key}) : super(key: key);

  @override
  StarredScreenState createState() => StarredScreenState();
}

class StarredScreenState extends State<StarredScreen> {
  final scrollController = ScrollController();

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Starred Story'),
      ),
      body: StarredMessageListView(
        scrollController: scrollController,
      ),
    );
  }

  void scrollToTop() {
    scrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeIn,
    );
  }
}
