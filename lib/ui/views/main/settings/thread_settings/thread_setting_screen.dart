import 'package:flutter/material.dart';
import 'package:mono_story/ui/views/main/settings/thread_settings/thread_setting_listview.dart';

class ThreadSettingScreen extends StatelessWidget {
  const ThreadSettingScreen({Key? key}) : super(key: key);

  static const String routeName = '/settings/thread';

  @override
  Widget build(BuildContext context) {
    final ThemeData _themeData = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text('Thread'),
      ),
      body: Theme(
        data: _themeData.copyWith(
            dividerTheme: _themeData.dividerTheme.copyWith(space: 5.0),
            iconTheme: _themeData.iconTheme.copyWith(size: 20.0)),
        child: const ThreadSettingListView(),
      ),
    );
  }
}
