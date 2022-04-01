import 'package:flutter/material.dart';
import 'package:mono_story/constants.dart';
import 'package:mono_story/models/thread.dart';
import 'package:mono_story/ui/common/mono_alertdialog.dart';
import 'package:mono_story/ui/views/main/settings/thread_settings/rename_bottom_sheet.dart';
import 'package:mono_story/ui/views/main/settings/thread_settings/thread_setting_bottom_sheet.dart';
import 'package:mono_story/ui/views/main/settings/thread_settings/thread_setting_listviewitem.dart';
import 'package:mono_story/view_models/story_viewmodel.dart';
import 'package:mono_story/view_models/starred_story_viewmodel.dart';
import 'package:mono_story/view_models/thread_viewmodel.dart';
import 'package:provider/provider.dart';

class ThreadSettingListView extends StatefulWidget {
  const ThreadSettingListView({Key? key}) : super(key: key);

  @override
  _ThreadSettingListViewState createState() => _ThreadSettingListViewState();
}

class _ThreadSettingListViewState extends State<ThreadSettingListView> {
  late final ThreadViewModel _threadVM;
  late final GlobalKey<AnimatedListState> _listKey;

  @override
  void initState() {
    super.initState();
    _threadVM = context.read<ThreadViewModel>();
    _threadVM.removedItemBuilder = _buildRemovedThreadItem;
    _listKey = _threadVM.listKey;
  }

  Widget _buildRemovedThreadItem(Thread item, Animation<double> animation) {
    return ThreadSettingListViewItem(
      animation: animation,
      thread: item,
      onPressed: () {},
    );
  }

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
                String? newName = await _showRenameThreadBottomSheet(
                  threadList[index],
                );
                if (newName == null) return;
                await _renameThread(threadList[index], newName);
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

  Future<String?> _showRenameThreadBottomSheet(Thread thread) async {
    return await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (_) => RenameBottomSheet(threadName: thread.name),
    );
  }

  Future<void> _renameThread(Thread thread, String newName) async {
    // TODO: Clean
    final threadVM = context.read<ThreadViewModel>();
    await threadVM.renameThread(thread.id!, newName);

    final storyVM = context.read<StoryViewModel>();
    storyVM.initStories();
    await storyVM.readStoriesChunk(threadVM.currentThreadId);

    final starredVM = context.read<StarredStoryViewModel>();
    starredVM.initStories();
    await starredVM.readStarredStoriesChunk();
  }

  Future<bool?> _showDeleteThreadAlertDialog(
    Thread thread,
    int index,
    Animation<double> animation,
  ) async {
    return await MonoAlertDialog().show<bool>(
      context: context,
      title: const Text('Delete Thread'),
      content: const Text('Are you sure you want to delete this Thread?'),
      cancel: const Text('Cancel'),
      onCancelPressed: () => Navigator.of(context).pop(false),
      destructive: const Text('Delete'),
      onDestructivePressed: () async {
        Navigator.of(context).pop(true);
      },
    );
  }

  Future<void> _deleteThread(Thread thread, int index) async {
    // TODO: Clean
    final threadVM = context.read<ThreadViewModel>();
    await threadVM.deleteThread(thread.id!);
    if (threadVM.currentThreadId == thread.id!) {
      threadVM.setCurrentThreadId(null, notify: true);
    }

    final storyVM = context.read<StoryViewModel>();
    storyVM.initStories();
    await storyVM.readStoriesChunk(threadVM.currentThreadId);

    final starredVM = context.read<StarredStoryViewModel>();
    starredVM.initStories();
    await starredVM.readStarredStoriesChunk();
  }
}
