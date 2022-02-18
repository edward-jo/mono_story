import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

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
import 'package:mono_story/view_models/starred_message_viewmodel.dart';
import 'package:mono_story/view_models/thread_viewmodel.dart';
import 'package:provider/provider.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({Key? key}) : super(key: key);

  static const routeName = '/backup';

  @override
  _BackupScreenState createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  final _backupProgressKey = GlobalKey<_ProgressContentState>();
  final _restoreProgressKey = GlobalKey<_ProgressContentState>();

  late final MessageViewModel _messageVM;

  late Future<_BackupInfo> _getLastBackupInfoFuture;
  StreamSubscription? _backupProgressSub, _restoreProgressSub;

  bool _useCellularData = false;
  bool _isBackingUp = false;
  bool _isRestoring = false;

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
    if (_isRestoring && _restoreProgressSub != null) {
      _restoreProgressSub!.cancel();
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
          // const MonoDivider(height: 0, color: Colors.black),
          const SizedBox(height: 20),

          //
          // BACK UP & STORE LISTTILE
          //
          FutureBuilder<_BackupInfo>(
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

              // last backup info
              final lastBackupInfo = snapshot.data as _BackupInfo;

              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  // BACKUP
                  _BackUpNowListTile(
                    backupDateTime: lastBackupInfo.backupDate,
                    wifiRequired: !_useCellularData,
                    onTap: _backup,
                  ),

                  const SizedBox(height: 30),

                  // RESTORE
                  _RestoreListTile(
                    backupDateTime: lastBackupInfo.backupDate,
                    wifiRequired: !_useCellularData,
                    onTap: () => _restore(lastBackupInfo.backupFileName),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Future<_BackupInfo> _getLastBackupInfo() async {
    final backupList = await _messageVM.listBackupFiles();
    if (backupList.isEmpty) return const _BackupInfo();

    final availableList = backupList
        .where(
          (e) => e.startsWith(appDatabaseBackupFileNamePrefix),
        )
        .toList();

    if (availableList.isEmpty) return const _BackupInfo();
    ;

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
      final formatted = genFormattedLocalTime(
        DateTime.parse(lastBackupDateStr),
      );
      return _BackupInfo(backupDate: formatted, backupFileName: lastFilename);
    } catch (e) {
      developer.log('_getLastBackupInfo', error: e.toString());
      return const _BackupInfo();
    }
  }

  Future<void> _deleteBackupFiles(List<String> fileNames) async {
    for (String f in fileNames) {
      developer.log('Delete old backup file( $f )');
      await _messageVM.deleteBackupFile(f);
    }
  }

  Future<void> _backup() async {
    Future<bool?>? dialog = MonoAlertDialog.showNotifyAlertDialog<bool>(
      context: context,
      title: const Text('Backing up'),
      content: _ProgressContent(
        key: _backupProgressKey,
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
            _backupProgressKey.currentState?.update('${progress.ceil()}%');
          },
          onError: (error) {
            developer.log('Upload error: ${error.toString()}');
            _backupProgressKey.currentState?.update(
              'Failed to back up: $error',
            );
            setState(() => _isBackingUp = false);
            dialog.toString();
            dialog = null;
            Navigator.of(context).pop(true);
          },
          onDone: () async {
            developer.log('Upload completed');
            _backupProgressKey.currentState?.update(
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

  Future<void> _restore(String? fileName) async {
    if (fileName == null) return;

    bool? ret = await MonoAlertDialog.showConfirmAlertDialog<bool>(
      context: context,
      title: const Text('Delete all your stories?'),
      content: Text(
        (Platform.isIOS
            ? 'Restoring will delete all stories present on you iPhone and restore stories from iCloud backup.'
            : 'Restoring will delete all stories present on you phone and restore stories from Google drive backup.'),
      ),
      cancelActionName: 'Cancel',
      onCancelPressed: () => Navigator.of(context).pop(false),
      destructiveActionName: 'Restore',
      onDestructivePressed: () => Navigator.of(context).pop(true),
    );

    if (ret == null || !ret) return;

    Future<bool?>? dialog = MonoAlertDialog.showNotifyAlertDialog<bool>(
      context: context,
      title: const Text('Restore'),
      content: _ProgressContent(
        key: _restoreProgressKey,
        message: 'Start restore',
      ),
    );

    setState(() => _isRestoring = true);

    //
    // Start restore
    //
    try {
      developer.log('Start downloading $fileName');
      await _messageVM.downloadMessages(fileName, (stream) {
        _restoreProgressSub = stream.listen(
          (progress) {
            // First progress is 100.0. Looks like it is bug of the package. So
            // show the remainder of modulo.
            progress %= 100;
            developer.log('Upload progress: $progress');
            _restoreProgressKey.currentState?.update('${progress.ceil()}%');
          },
          onError: (error) {
            developer.log('Upload error: ${error.toString()}');
            _restoreProgressKey.currentState?.update(
              'Failed to back up: $error',
            );
            setState(() => _isRestoring = false);
            dialog.toString();
            dialog = null;
            Navigator.of(context).pop(true);
          },
          onDone: () async {
            developer.log('Upload completed');
            _restoreProgressKey.currentState?.update(
              'Completed',
            );
            await Future.delayed(const Duration(seconds: 1));

            //
            // Init Home & Starred list
            //
            final threadVM = context.read<ThreadViewModel>();
            threadVM.setCurrentThreadId(null, notify: true);

            final messageVM = context.read<MessageViewModel>();
            messageVM.initMessageDatabase();
            messageVM.initMessages();
            await messageVM.readMessagesChunk(threadVM.currentThreadId);

            final starredVM = context.read<StarredMessageViewModel>();
            starredVM.initMessages();
            await starredVM.searchStarredThreadChunk();

            setState(() {
              _getLastBackupInfoFuture = _getLastBackupInfo();
              _isRestoring = false;
            });
            dialog = null;
            Navigator.of(context).pop(true);
          },
          cancelOnError: true,
        );
      });
    } catch (e) {
      developer.log('_restore', error: e.toString());
      _restoreProgressSub!.cancel();
      setState(() => _isRestoring = false);
      dialog = null;
      Navigator.of(context).pop(true);
    }
  }
}

//------------------------------------------------------------------------------
// _BackupInfo
//------------------------------------------------------------------------------
class _BackupInfo {
  const _BackupInfo({this.backupDate, this.backupFileName});
  final String? backupDate;
  final String? backupFileName;
}

//------------------------------------------------------------------------------
// _BackupNowProgress
//------------------------------------------------------------------------------

class _ProgressContent extends StatefulWidget {
  const _ProgressContent({Key? key, required this.message}) : super(key: key);

  final String message;

  @override
  _ProgressContentState createState() => _ProgressContentState();
}

class _ProgressContentState extends State<_ProgressContent> {
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
          isThreeLine: true,
          title: Text('Back Up Now', style: titleStyle),
          subtitle: Container(
            alignment: Alignment.topLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // MESSAGE: LAST SUCCESSFUL BACKUP TIME
                Text(
                  (backupDateTime != null)
                      ? 'Last successful backup: $backupDateTime'
                      : 'You don\'t have any backup yet.',
                  style: subtitleStyle,
                ),

                // MESSAGE: WIFI REQUIRED
                if (wifiRequired)
                  Text(
                    'You must be connected to Wi-Fi network to start a backup.',
                    style: subtitleStyle,
                  ),
              ],
            ),
          ),
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
      ],
    );
  }
}
//------------------------------------------------------------------------------
// _CancelBackupWidget
//------------------------------------------------------------------------------

class _RestoreListTile extends StatelessWidget {
  const _RestoreListTile({
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
      children: <Widget>[
        // RESTORE FROM ICLOUD BACKUP
        ListTile(
          isThreeLine: true,
          title: Text('Restore from iCloud Backup', style: titleStyle),
          subtitle: Container(
            alignment: Alignment.topLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // MESSAGE: LAST SUCCESSFUL BACKUP TIME
                Text(
                  (backupDateTime != null)
                      ? 'Last successful backup: $backupDateTime'
                      : 'You don\'t have any backup yet.',
                  style: subtitleStyle,
                ),

                // MESSAGE: WIFI REQUIRED
                if (wifiRequired)
                  Text(
                    'You must be connected to Wi-Fi network to start a backup.',
                    style: subtitleStyle,
                  ),
              ],
            ),
          ),
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
      ],
    );
  }
}
