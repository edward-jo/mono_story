import 'package:flutter/material.dart';
import 'package:mono_story/models/thread.dart';
import 'package:mono_story/ui/views/main/settings/thread_settings/thread_setting_listviewitem.dart';
import 'package:mono_story/view_models/thread_viewmodel.dart';
import 'package:provider/provider.dart';

class ThreadSettingListView extends StatefulWidget {
  const ThreadSettingListView({Key? key}) : super(key: key);

  @override
  _ThreadSettingListViewState createState() => _ThreadSettingListViewState();
}

class _ThreadSettingListViewState extends State<ThreadSettingListView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Thread> threadList = context.watch<ThreadViewModel>().threads;
    return ListView.builder(
      itemCount: threadList.length,
      itemBuilder: (context, index) {
        return ThreadSettingListViewItem(thread: threadList[index]);
      },
    );
  }
}
