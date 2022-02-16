import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mono_story/ui/common/platform_switch.dart';
import 'package:mono_story/ui/common/platform_widget_base.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({Key? key}) : super(key: key);

  static const routeName = '/backup';

  @override
  _BackupScreenState createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  bool _useCellularData = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text('Back up'),
      ),
      body: Center(
          child: Column(
        children: <Widget>[
          ListTile(
            title: const Text('Use Cellular Data'),
            trailing: PlatformSwitch(
              value: _useCellularData,
              onChanged: (value) {
                setState(() => _useCellularData = value);
              },
            ),
          ),
          const SizedBox(height: 20),
          ListTile(
            title: Text(
              'Back Up Now',
              style: Theme.of(context).textTheme.bodyText1?.copyWith(
                    color: Colors.blue,
                  ),
            ),
            subtitle: Container(
              padding: const EdgeInsets.only(top: 10),
              alignment: Alignment.centerLeft,
              child: Text(
                'Last successful backup: yesterday 2:00 PM',
                style: Theme.of(context).textTheme.caption?.copyWith(
                      fontSize: 12,
                    ),
              ),
            ),
            onTap: () {},
          ),
        ],
      )),
    );
  }
}
