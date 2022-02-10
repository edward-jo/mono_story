import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mono_story/ui/common/platform_widget.dart';

class ThreadSettingBottomSheet extends StatelessWidget {
  const ThreadSettingBottomSheet({Key? key, required this.threadName})
      : super(key: key);

  final String threadName;
  final _bottomSheetPadding = const EdgeInsets.symmetric(horizontal: 20.0);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: _bottomSheetPadding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SizedBox(height: 20),

          // THREAD ICON
          const PlatformWidget(
            cupertino: Icon(CupertinoIcons.tag),
            material: Icon(Icons.tag),
          ),

          // THREAD NAME
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Text(
              threadName,
              overflow: TextOverflow.fade,
              softWrap: false,
              style: Theme.of(context).textTheme.bodyText1?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),

          const Divider(thickness: 0.5),

          // RENAME
          _ThreadListTile(
            title: 'Rename',
            onTap: () => Navigator.of(context).pop(),
          ),

          const Divider(thickness: 0.5),

          // DELETE
          _ThreadListTile(
            title: 'Delete',
            onTap: () => Navigator.of(context).pop(),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class _ThreadListTile extends StatelessWidget {
  const _ThreadListTile({
    Key? key,
    this.onTap,
    required this.title,
  }) : super(key: key);

  final String title;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50.0,
      child: ListTile(
        title: Text(title, textAlign: TextAlign.center),
        onTap: onTap,
      ),
    );
  }
}
