import 'package:flutter/material.dart';
import 'package:mono_story/ui/views/main/starred/starred_message_listview.dart';
import 'package:mono_story/view_models/starred_message_viewmodel.dart';
import 'package:provider/src/provider.dart';

class StarredScreen extends StatefulWidget {
  const StarredScreen({Key? key}) : super(key: key);

  @override
  StarredScreenState createState() => StarredScreenState();
}

class StarredScreenState extends State<StarredScreen> {
  final scrollController = ScrollController();
  late final StarredMessageViewModel _starredVM;

  @override
  void initState() {
    super.initState();
    _starredVM = context.read<StarredMessageViewModel>();
  }

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
      body: Container(
        color: Colors.grey.shade200,
        child: StarredMessageListView(
          scrollController: scrollController,
        ),
      ),
    );
  }

  void scrollToTop() {
    if (_starredVM.stories.isEmpty) return;

    scrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeIn,
    );
  }
}
