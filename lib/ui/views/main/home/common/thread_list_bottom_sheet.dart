import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mono_story/constants.dart';
import 'package:mono_story/models/thread.dart';
import 'package:mono_story/ui/common/mono_elevatedbutton.dart';
import 'package:mono_story/ui/common/platform_alert_dialog.dart';
import 'package:mono_story/ui/common/platform_indicator.dart';
import 'package:mono_story/ui/common/styled_builder_error_widget.dart';
import 'package:mono_story/view_models/message_viewmodel.dart';
import 'package:mono_story/view_models/thread_viewmodel.dart';
import 'package:provider/provider.dart';

class ThreadListBottomSheet extends StatefulWidget {
  const ThreadListBottomSheet({Key? key}) : super(key: key);

  @override
  State<ThreadListBottomSheet> createState() => _ThreadListBottomSheetState();
}

class _ThreadListBottomSheetState extends State<ThreadListBottomSheet> {
  late final ThreadViewModel _threadVM;
  late Future<List<Thread>> _readThreadListFuture;

  final double _threadItemHeight = 50.0;
  final _bottomSheetPadding = const EdgeInsets.symmetric(horizontal: 20.0);

  @override
  void initState() {
    super.initState();
    _threadVM = context.read<ThreadViewModel>();
    _readThreadListFuture = _threadVM.readThreadList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _readThreadListFuture,
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
    // -- ERROR MESSAGE --
    if (snapshot.hasError) {
      return StyledBuilderErrorWidget(message: snapshot.error.toString());
    }

    if (!snapshot.hasData) return Container();

    List<Thread> threadList = snapshot.data!;

    // -- THREAD LIST --
    return Padding(
      padding: _bottomSheetPadding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // -- BOTTOM SHEET HEAD --
          const SizedBox(height: 10),

          // -- SEE ALL BUTTON --
          Container(
            alignment: Alignment.centerRight,
            child: TextButton(
              child: const Text('See all'),
              onPressed: () => _seeAll(context),
            ),
          ),

          // -- THREAD NAME LIST --
          Expanded(
            child: SizedBox(
              child: MediaQuery.removePadding(
                context: context,
                child: Scrollbar(
                  isAlwaysShown: true,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: threadList.length,
                    itemBuilder: (ctx, i) =>
                        _threadItemBuilder(ctx, i, threadList),
                  ),
                ),
                removeTop: true,
                removeBottom: true,
              ),
            ),
          ),

          // -- CREATE NEW THREAD BUTTON --
          MonoElevatedButton(
            child: const Text('Create New Thread'),
            onPressed: () => _newThread(context),
          ),

          // --
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _seeAll(BuildContext context) {
    Navigator.of(context).pop(
      ThreadListResult(type: ThreadListResultType.thread, data: null),
    );
  }

  void _tapThread(BuildContext context, int? id) {
    Navigator.of(context).pop(
      ThreadListResult(type: ThreadListResultType.thread, data: id),
    );
  }

  void _newThread(BuildContext context) {
    Navigator.of(context).pop(
      ThreadListResult(type: ThreadListResultType.newThreadRequest),
    );
  }

  Widget _threadItemBuilder(BuildContext context, int i, List<Thread> list) {
    return Column(
      children: [
        SizedBox(
          height: _threadItemHeight,
          child: ListTile(
            leading: Icon(MonoIcons.thread_icon),
            title: Text(
              list[i].name,
              style: Theme.of(context).textTheme.bodyText2,
              overflow: TextOverflow.fade,
              softWrap: false,
            ),
            trailing: const SizedBox(width: 20),
            onTap: () => _tapThread(context, list[i].id),
          ),
        ),
      ],
    );
  }
}

enum ThreadListResultType {
  thread,
  newThreadRequest,
}

class ThreadListResult {
  late final ThreadListResultType type;
  late final dynamic data;
  ThreadListResult({required this.type, this.data});
}
