import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mono_story/constants.dart';
import 'package:mono_story/ui/common/platform_widget.dart';
import 'package:mono_story/ui/views/main/settings/about_screen.dart';
import 'package:mono_story/ui/views/main/settings/thread_settings/thread_setting_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Settings'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            // THREADS
            ListTile(
              leading: Icon(MonoStoryIcons.thread_icon),
              title: const Text('Threads'),
              trailing: const PlatformWidget(
                cupertino: Icon(CupertinoIcons.chevron_forward, size: 20.0),
                material: Icon(Icons.chevron_right, size: 20.0),
              ),
              onTap: () => Navigator.of(context).pushNamed(
                ThreadSettingScreen.routeName,
              ),
            ),

            // BACK UP
            ListTile(
              leading: const PlatformWidget(
                cupertino: Icon(CupertinoIcons.cloud_upload),
                material: Icon(Icons.cloud_upload),
              ),
              title: const Text('Back up'),
              onTap: () {},
            ),

            // RESTORE
            ListTile(
              leading: const PlatformWidget(
                cupertino: Icon(CupertinoIcons.cloud_download),
                material: Icon(Icons.cloud_download),
              ),
              title: const Text('Restore'),
              onTap: () {},
            ),

            // ABOUT
            ListTile(
              leading: const PlatformWidget(
                cupertino: Icon(CupertinoIcons.info),
                material: Icon(Icons.info),
              ),
              title: const Text('About'),
              trailing: const PlatformWidget(
                cupertino: Icon(CupertinoIcons.chevron_forward, size: 20.0),
                material: Icon(Icons.chevron_right, size: 20.0),
              ),
              onTap: () => Navigator.of(context).pushNamed(
                AboutScreen.routeName,
              ),
            )
          ],
        ),
      ),
    );
  }
}
