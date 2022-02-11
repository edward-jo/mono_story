import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mono_story/constants.dart';
import 'package:mono_story/models/thread.dart';
import 'package:mono_story/ui/common/platform_widget.dart';
import 'package:mono_story/ui/views/main/settings/thread_settings/thread_setting_bottom_sheet.dart';

class ThreadSettingListViewItem extends StatefulWidget {
  const ThreadSettingListViewItem({
    Key? key,
    required this.thread,
    required this.onRename,
    required this.onDelete,
  }) : super(key: key);

  final Thread thread;
  final Future<void> Function(Thread) onRename;
  final Future<void> Function(Thread) onDelete;

  @override
  _ThreadSettingListViewItemState createState() =>
      _ThreadSettingListViewItemState();
}

class _ThreadSettingListViewItemState extends State<ThreadSettingListViewItem> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(MonoIcons.thread_icon),
      title: Text(widget.thread.name),
      trailing: PlatformWidget(
        cupertino: IconButton(
          icon: const Icon(CupertinoIcons.ellipsis),
          onPressed: () => _showThreadSetting(context),
        ),
        material: const Icon(Icons.more_horiz),
      ),
    );
  }

  void _showThreadSetting(BuildContext context) async {
    ThreadSettingMenus? result = await showModalBottomSheet<ThreadSettingMenus>(
      context: context,
      backgroundColor: Theme.of(context).canvasColor,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
        top: Radius.circular(bottomSheetRadius),
      )),
      builder: (_) => ThreadSettingBottomSheet(threadName: widget.thread.name),
    );

    switch (result) {
      case ThreadSettingMenus.rename:
        await widget.onRename(widget.thread);
        break;
      case ThreadSettingMenus.delete:
        await widget.onDelete(widget.thread);
        break;
      default:
        return;
    }
  }
}
