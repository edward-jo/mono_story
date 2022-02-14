import 'package:flutter/material.dart';
import 'package:mono_story/constants.dart';
import 'package:mono_story/models/thread.dart';
import 'package:mono_story/ui/common/mono_alertdialog.dart';
import 'package:mono_story/ui/views/main/settings/thread_settings/rename_bottom_sheet.dart';
import 'package:mono_story/ui/views/main/settings/thread_settings/thread_setting_bottom_sheet.dart';
import 'package:mono_story/ui/views/main/settings/thread_settings/thread_setting_listviewitem.dart';
import 'package:mono_story/view_models/message_viewmodel.dart';
import 'package:mono_story/view_models/starred_message_viewmodel.dart';
import 'package:mono_story/view_models/thread_viewmodel.dart';
import 'package:provider/provider.dart';

class ThreadSettingListView extends StatefulWidget {
  const ThreadSettingListView({Key? key}) : super(key: key);

  @override
  _ThreadSettingListViewState createState() => _ThreadSettingListViewState();
}

class _ThreadSettingListViewState extends State<ThreadSettingListView> {
  final _listKey = GlobalKey<AnimatedListState>();

  @override
  Widget build(BuildContext context) {
    List<Thread> threadList = context.watch<ThreadViewModel>().threads;
    return AnimatedList(
      key: _listKey,
      initialItemCount: threadList.length,
      itemBuilder: (context, index, animation) {
        return ThreadSettingListViewItem(
          animation: animation,
          thread: threadList[index],
          onPressed: () async {
            final ret = await _showThreadSettingBottomSheet(
              context,
              threadList[index],
            );
            switch (ret) {
              case ThreadSettingMenus.rename:
                await _showRenameThreadBottomSheet(threadList[index]);
                break;
              case ThreadSettingMenus.delete:
                bool? ret = await _showDeleteThreadAlertDialog(
                  threadList[index],
                  index,
                  animation,
                );
                if (ret != null && ret) {
                  await _deleteThread(threadList[index], index);
                }
                break;
              default:
                return;
            }
          },
        );
      },
    );
  }

  Future<ThreadSettingMenus?> _showThreadSettingBottomSheet(
    BuildContext context,
    Thread thread,
  ) async {
    return await showModalBottomSheet<ThreadSettingMenus>(
      context: context,
      backgroundColor: Theme.of(context).canvasColor,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
        top: Radius.circular(bottomSheetRadius),
      )),
      builder: (_) => ThreadSettingBottomSheet(threadName: thread.name),
    );
  }

  Future<void> _showRenameThreadBottomSheet(Thread thread) async {
    String? newName = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (_) => RenameBottomSheet(threadName: thread.name),
    );

    if (newName == null) return;

    // TODO: Clean
    final threadVM = context.read<ThreadViewModel>();
    await threadVM.renameThread(thread.id!, newName);

    final messageVM = context.read<MessageViewModel>();
    messageVM.initMessages();
    await messageVM.readMessagesChunk(threadVM.currentThreadId);

    final starredVM = context.read<StarredMessageViewModel>();
    starredVM.initMessages();
    await starredVM.searchStarredThreadChunk();
  }

  Future<bool?> _showDeleteThreadAlertDialog(
    Thread thread,
    int index,
    Animation<double> animation,
  ) async {
    return await MonoAlertDialog.showAlertConfirmDialog<bool>(
      context: context,
      title: 'Delete Thread',
      content: 'Are you sure you want to delete this Thread?',
      cancelActionName: 'Cancel',
      onCancelPressed: () => Navigator.of(context).pop(false),
      destructiveActionName: 'Delete',
      onDestructivePressed: () async {
        Navigator.of(context).pop(true);
      },
    );
  }

  Future<void> _deleteThread(Thread thread, int index) async {
    // TODO: Clean
    final threadVM = context.read<ThreadViewModel>();

    final deletedThread = await threadVM.deleteThread(thread.id!);
    if (deletedThread != null) {
      _listKey.currentState?.removeItem(
        index,
        (context, animation) => ThreadSettingListViewItem(
          animation: animation,
          thread: deletedThread,
          onPressed: () {},
        ),
      );
    }

    if (threadVM.currentThreadId == thread.id!) {
      threadVM.setCurrentThreadId(null, notify: true);
    }

    final messageVM = context.read<MessageViewModel>();
    messageVM.initMessages();
    await messageVM.readMessagesChunk(threadVM.currentThreadId);

    final starredVM = context.read<StarredMessageViewModel>();
    starredVM.initMessages();
    await starredVM.searchStarredThreadChunk();
  }
}
