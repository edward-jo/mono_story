import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mono_story/models/thread.dart';
import 'package:mono_story/ui/common/platform_alert_dialog.dart';
import 'package:mono_story/ui/common/platform_indicator.dart';
import 'package:mono_story/view_models/message_viewmodel.dart';
import 'package:provider/provider.dart';

class ThreadListBottomSheet extends StatefulWidget {
  const ThreadListBottomSheet({Key? key}) : super(key: key);

  @override
  State<ThreadListBottomSheet> createState() => _ThreadListBottomSheetState();
}

class _ThreadListBottomSheetState extends State<ThreadListBottomSheet> {
  late final MessageViewModel _model;
  late Future<List<Thread>> _getThreadListFuture;

  @override
  void initState() {
    super.initState();
    _model = context.read<MessageViewModel>();
    _getThreadListFuture = _model.getThreadList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getThreadListFuture,
      builder: _threadListBuilder,
    );
  }

  Widget _threadListBuilder(
    BuildContext context,
    AsyncSnapshot<List<Thread>> snapshot,
  ) {
    // -- INDICATOR --
    if (snapshot.connectionState != ConnectionState.done) {
      return const Center(
        child: PlatformIndicator(),
      );
    }
    // -- ALERT DIALOG --
    if (snapshot.hasError) {
      showDialog(
        context: context,
        builder: (_) {
          return PlatformAlertDialog(
            content: Text(snapshot.error.toString()),
          );
        },
      );
      return Container();
    }

    if (!snapshot.hasData) return Container();

    List<Thread> threadList = snapshot.data!;
    TextTheme textTheme = Theme.of(context).textTheme;

    // -- MESSAGE LIST --
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        // -- BOTTOM SHEET HEAD --
        const SizedBox(height: 20),
        Text(
          'Select Thread',
          style: textTheme.headline6!.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),

        // -- THREAD NAME LIST --
        Expanded(
          child: SizedBox(
            child: ListView.builder(
                shrinkWrap: true,
                itemCount: threadList.length,
                itemBuilder: (_, i) {
                  // -- THREAD LIST NAME ITEM --
                  return Container(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.topic),
                          title: Text(
                            threadList[i].name,
                            style: TextStyle(
                              fontSize: textTheme.bodyText2?.fontSize,
                              // fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.fade,
                            softWrap: false,
                          ),
                          trailing: const SizedBox(width: 20),
                          onTap: () => Navigator.of(context).pop(
                            ThreadNameListResult(
                              type: ThreadListResultType.thread,
                              data: threadList[i].id,
                            ),
                          ),
                        ),
                        // const Divider(height: 1),
                      ],
                    ),
                  );
                }),
          ),
        ),
        // const SizedBox(height: 10),

        // -- CREATE NEW THREAD BUTTON --
        TextButton(
          onPressed: () => Navigator.of(context).pop(ThreadNameListResult(
            type: ThreadListResultType.newThreadRequest,
          )),
          child: const Text('Create New Thread'),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

enum ThreadListResultType {
  thread,
  newThreadRequest,
}

class ThreadNameListResult {
  late final ThreadListResultType type;
  late final dynamic data;
  ThreadNameListResult({required this.type, this.data});
}
