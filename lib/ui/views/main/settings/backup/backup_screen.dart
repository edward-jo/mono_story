import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mono_story/ui/common/mono_alertdialog.dart';
import 'package:mono_story/ui/common/mono_divider.dart';
import 'package:mono_story/ui/common/platform_indicator.dart';
import 'package:mono_story/ui/common/platform_switch.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({Key? key}) : super(key: key);

  static const routeName = '/backup';

  @override
  _BackupScreenState createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  bool _useCellularData = false;
  bool _isBackingUp = false;
  final _backupNowProgressKey = GlobalKey<_BackupNowProgressState>();

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
          // USE CELLULAR DATA
          ListTile(
            title: const Text('Use Cellular Data'),
            trailing: PlatformSwitch(
              value: _useCellularData,
              onChanged: (value) {
                setState(() => _useCellularData = value);
              },
            ),
          ),

          //
          const MonoDivider(height: 0, color: Colors.black),

          // BACK UP / CANCEL BACK UP
          _isBackingUp
              ? _CancelBackupWidget(
                  onTap: () => setState(() {
                    _isBackingUp = false;
                  }),
                )
              : _BackUpNowWidget(
                  wifiRequired: !_useCellularData,
                  onTap: _backupNow,
                ),
        ],
      )),
    );
  }

  void _backupNow() async {
    final dialog = MonoAlertDialog.showProgressAlertDialog<bool>(
        context: context,
        title: const Text('Backing up'),
        content: _BackupNowProgress(
          key: _backupNowProgressKey,
          message: 'Start backup',
        ),
        cancelActionName: 'Cancel',
        onCancelPressed: () {
          Navigator.of(context).pop(true);
          setState(() => _isBackingUp = false);
        });

    setState(() => _isBackingUp = true);

    await _backupFuture();

    setState(() => _isBackingUp = false);
    Navigator.of(context).pop(true);
  }

  Future<void> _backupFuture() async {
    for (int i = 0; i < 5; i++) {
      await Future.delayed(const Duration(seconds: 1));
      _backupNowProgressKey.currentState?.update('${i * 10} %!');
    }
  }
}

class _BackupNowProgress extends StatefulWidget {
  const _BackupNowProgress({Key? key, required this.message}) : super(key: key);

  final String message;

  @override
  _BackupNowProgressState createState() => _BackupNowProgressState();
}

class _BackupNowProgressState extends State<_BackupNowProgress> {
  late String _message;

  @override
  void initState() {
    super.initState();
    _message = widget.message;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(_message),
        const SizedBox(height: 10),
        const PlatformIndicator(),
      ],
    );
  }

  void update(String message) {
    setState(() => _message = message);
  }
}

class _BackUpNowWidget extends StatelessWidget {
  const _BackUpNowWidget({
    Key? key,
    required this.wifiRequired,
    required this.onTap,
  }) : super(key: key);

  final bool wifiRequired;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.bodyText1?.copyWith(
          color: Colors.blue,
        );
    final subtitleStyle = Theme.of(context).textTheme.caption?.copyWith(
          fontSize: 13,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // BACK UP NOW
        ListTile(
          title: Text('Back Up Now', style: titleStyle),
          onTap: onTap,
        ),

        //
        const MonoDivider(height: 10, color: Colors.black),

        // SUBTITLES
        Container(
          padding: const EdgeInsets.only(left: 20, top: 10),
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // MESSAGE: WIFI REQUIRED
              if (wifiRequired)
                Text(
                  'You must be connected to Wi-Fi network to start a backup.',
                  style: subtitleStyle,
                ),
              const SizedBox(height: 10),

              // MESSAGE: LAST SUCCESSFUL BACKUP TIME
              Text(
                'Last successful backup: yesterday 2:00 PM',
                style: subtitleStyle,
              ),
            ],
          ),
        )
      ],
    );
  }
}

class _CancelBackupWidget extends StatelessWidget {
  const _CancelBackupWidget({Key? key, required this.onTap}) : super(key: key);

  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        // CANCEL BACKUP
        ListTile(
          title: Text(
            'Cancel Backup',
            style: Theme.of(context).textTheme.bodyText1?.copyWith(
                  color: Colors.blue,
                ),
          ),
          onTap: onTap,
        ),

        // PROGRESS INDICATOR
      ],
    );
  }
}
