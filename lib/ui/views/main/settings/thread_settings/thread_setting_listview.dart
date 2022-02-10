import 'package:flutter/material.dart';
import 'package:mono_story/models/thread.dart';
import 'package:mono_story/ui/views/main/settings/thread_settings/thread_rename_bottom_sheet.dart';
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
        return ThreadSettingListViewItem(
          thread: threadList[index],
          onRename: _renameThread,
          onDelete: _deleteThread,
        );
      },
    );
  }

  Future<void> _renameThread(Thread thread) async {
    String? newName = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (_) => ThreadRenameBottomSheet(threadName: thread.name),
    );

    if (newName == null) return;

    return await context.read<ThreadViewModel>().renameThread(
          thread.id!,
          newName,
        );
  }

  Future<void> _deleteThread(Thread thread) async {}
}
