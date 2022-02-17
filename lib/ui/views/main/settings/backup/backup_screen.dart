import 'dart:async';
import 'dart:developer' as developer;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mono_story/constants.dart';
import 'package:mono_story/ui/common/mono_alertdialog.dart';
import 'package:mono_story/ui/common/mono_divider.dart';
import 'package:mono_story/ui/common/platform_indicator.dart';
import 'package:mono_story/ui/common/platform_switch.dart';
import 'package:mono_story/ui/common/styled_builder_error_widget.dart';
import 'package:mono_story/utils/utils.dart';
import 'package:mono_story/view_models/message_viewmodel.dart';
import 'package:provider/provider.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({Key? key}) : super(key: key);

  static const routeName = '/backup';

  @override
  _BackupScreenState createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  final _backupNowProgressKey = GlobalKey<_BackupNowProgressState>();

  late final MessageViewModel _messageVM;

  late Future<String?> _getLastBackupInfoFuture;
  StreamSubscription? _backupProgressSub, _restoreProgressSub;

  bool _useCellularData = false;
  bool _isBackingUp = false;

  @override
  void initState() {
    super.initState();
    _messageVM = context.read<MessageViewModel>();
    _getLastBackupInfoFuture = _getLastBackupInfo();
  }

  @override
  void dispose() {
    if (_isBackingUp && _backupProgressSub != null) {
      _backupProgressSub!.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text('Back up'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
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

          //
          // BACK UP LISTTILE and INFO
          //
          FutureBuilder(
            future: _getLastBackupInfoFuture,
            builder: (context, snapshot) {
              // INDICATOR
              if (snapshot.connectionState != ConnectionState.done) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const <Widget>[
                    ListTile(leading: PlatformIndicator()),
                    MonoDivider(height: 1, color: Colors.black),
                  ],
                );
              }
              // MESSAGE FOR ERROR
              if (snapshot.hasError || !snapshot.hasData) {
                return StyledBuilderErrorWidget(
                  message: snapshot.error.toString(),
                );
              }
              // MESSAGE FOR EMPTY LIST
              if (snapshot.data == null) {
                return const StyledBuilderErrorWidget(
                  message: 'No Backup found',
                );
              }
              // LASTEST BACKUP INFO
              final lastDate = snapshot.data as String?;

              return _BackUpNowListTile(
                backupDateTime: lastDate,
                wifiRequired: !_useCellularData,
                onTap: _backupNow,
              );
            },
          ),
        ],
      ),
    );
  }

  Future<String?> _getLastBackupInfo() async {
    final backupList = await _messageVM.listBackupFiles();
    if (backupList.isEmpty) return null;

    final availableList = backupList
        .where(
          (e) => e.startsWith(appDatabaseBackupFileNamePrefix),
        )
        .toList();

    if (availableList.isEmpty) return null;

    availableList.sort((a, b) => a.compareTo(b));
    availableList.forEach(developer.log);

    final lastFilename = availableList.last;
    final lastBackupDateStr = lastFilename.substring(
      appDatabaseBackupFileNamePrefix.length,
    );

    developer.log('>>> Last backup: $lastFilename');

    if (availableList.length > 3) {
      // Delete unnecessary backup files
      await _deleteBackupFiles(
        availableList.sublist(0, availableList.length - 3),
      );
    }

    try {
      return genFormattedLocalTime(DateTime.parse(lastBackupDateStr));
    } catch (e) {
      developer.log('_getLastBackupInfo', error: e.toString());
      return null;
    }
  }

  Future<void> _deleteBackupFiles(List<String> fileNames) async {
    for (String f in fileNames) {
      developer.log('Delete old backup file( $f )');
      await _messageVM.deleteBackupFile(f);
    }
  }

  Future<void> _backupNow() async {
    Future<bool?>? dialog = MonoAlertDialog.showNotifyAlertDialog<bool>(
      context: context,
      title: const Text('Backing up'),
      content: _BackupNowProgress(
        key: _backupNowProgressKey,
        message: 'Start backup',
      ),
    );

    setState(() => _isBackingUp = true);

    //
    // Start backup
    //
    try {
      await _messageVM.uploadMessages((stream) {
        _backupProgressSub = stream.listen(
          (progress) {
            // First progress is 100.0. Looks like it is bug of the package. So
            // show the remainder of modulo.
            progress %= 100;
            developer.log('Upload progress: $progress');
            _backupNowProgressKey.currentState?.update('${progress.ceil()}%');
          },
          onError: (error) {
            developer.log('Upload error: ${error.toString()}');
            _backupNowProgressKey.currentState?.update(
              'Failed to back up: $error',
            );
            setState(() => _isBackingUp = false);
            dialog.toString();
            dialog = null;
            Navigator.of(context).pop(true);
          },
          onDone: () async {
            developer.log('Upload completed');
            _backupNowProgressKey.currentState?.update(
              'Completed',
            );
            await Future.delayed(const Duration(seconds: 1));
            setState(() {
              _getLastBackupInfoFuture = _getLastBackupInfo();
              _isBackingUp = false;
            });
            dialog = null;
            Navigator.of(context).pop(true);
          },
          cancelOnError: true,
        );
      });
    } catch (e) {
      developer.log('_backupNow', error: e.toString());
      _backupProgressSub!.cancel();
      setState(() => _isBackingUp = false);
      dialog = null;
      Navigator.of(context).pop(true);
    }
  }
}
//------------------------------------------------------------------------------
// _BackupNowProgress
//------------------------------------------------------------------------------

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
//------------------------------------------------------------------------------
// _BackUpNowListTile
//------------------------------------------------------------------------------

class _BackUpNowListTile extends StatelessWidget {
  const _BackUpNowListTile({
    Key? key,
    required this.backupDateTime,
    required this.wifiRequired,
    required this.onTap,
  }) : super(key: key);

  final String? backupDateTime;
  final bool wifiRequired;
  final Future<void> Function() onTap;

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
          onTap: () async {
            if (wifiRequired) {
              var result = await Connectivity().checkConnectivity();
              if (result != ConnectivityResult.wifi) {
                await MonoAlertDialog.showNotifyAlertDialog(
                  context: context,
                  title: const Text('Not Connected to Wi-Fi'),
                  content: const Text('You are not connected to Wi-Fi'),
                  cancelActionName: 'Close',
                  onCancelPressed: () => Navigator.of(context).pop(),
                );
                return;
              }
            }
            await onTap();
          },
        ),

        //
        const MonoDivider(height: 1, color: Colors.black),

        // SUBTITLES
        Container(
          padding: const EdgeInsets.only(left: 20, top: 10),
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // MESSAGE: LAST SUCCESSFUL BACKUP TIME
              if (backupDateTime != null)
                Text(
                  'Last successful backup: $backupDateTime',
                  style: subtitleStyle,
                ),

              const SizedBox(height: 10),

              // MESSAGE: WIFI REQUIRED
              if (wifiRequired)
                Text(
                  'You must be connected to Wi-Fi network to start a backup.',
                  style: subtitleStyle,
                ),
            ],
          ),
        )
      ],
    );
  }
}
//------------------------------------------------------------------------------
// _CancelBackupWidget
//------------------------------------------------------------------------------

class _CancelBackupListTile extends StatelessWidget {
  const _CancelBackupListTile({Key? key, required this.onTap})
      : super(key: key);

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
