import 'package:flutter/material.dart';
import 'package:mono_story/models/thread.dart';
import 'package:mono_story/ui/common/mono_alertdialog.dart';
import 'package:mono_story/ui/views/main/settings/thread_settings/rename_bottom_sheet.dart';
import 'package:mono_story/ui/views/main/settings/thread_settings/thread_setting_listviewitem.dart';
import 'package:mono_story/view_models/message_viewmodel.dart';
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
      builder: (_) => RenameBottomSheet(threadName: thread.name),
    );

    if (newName == null) return;

    return await context.read<ThreadViewModel>().renameThread(
          thread.id!,
          newName,
        );
  }

  Future<void> _deleteThread(Thread thread) async {
    return await MonoAlertDialog.showAlertConfirmDialog(
      context: context,
      title: 'Delete Story',
      content: 'Are you sure you want to delete this Story?',
      cancelActionName: 'Cancel',
      onCancelPressed: () => Navigator.of(context).pop(),
      destructiveActionName: 'Delete',
      onDestructivePressed: () {
        final threadVM = context.read<ThreadViewModel>();
        final messageVM = context.read<MessageViewModel>();
        threadVM.deleteThread(thread.id!);
        if (threadVM.currentThreadId == thread.id!) {
          threadVM.currentThreadId = null;
        }
        messageVM.initMessages();
        messageVM.readThreadChunk(threadVM.currentThreadId);
        Navigator.of(context).pop();
      },
    );
  }
}
