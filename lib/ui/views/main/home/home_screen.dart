import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mono_story/constants.dart';
import 'package:mono_story/models/message.dart';
import 'package:mono_story/models/thread.dart';
import 'package:mono_story/ui/common/platform_alert_dialog.dart';
import 'package:mono_story/ui/common/platform_indicator.dart';
import 'package:mono_story/ui/views/main/home/common/new_thread_bottom_sheet.dart';
import 'package:mono_story/ui/views/main/home/common/thread_list_bottom_sheet.dart';
import 'package:mono_story/ui/views/main/home/message_listviewitem.dart';
import 'package:mono_story/ui/views/main/home/new_message/new_message_screen.dart';
import 'package:mono_story/ui/views/main/home/thread_button.dart';
import 'package:mono_story/view_models/message_viewmodel.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Thread? _threadData;
  late Future<void> _readThreadFuture;
  late MessageViewModel _model;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _model = context.read<MessageViewModel>();
    _threadData = _model.currentThreadData;
    _scrollController.addListener(_scrollListener);
    _readThreadFuture = _model.readThreadChunk(_threadData?.id);
  }

  void _scrollListener() {
    if (_scrollController.position.outOfRange) return;

    if (_scrollController.offset >=
        _scrollController.position.maxScrollExtent / 2) {
      _model.readThreadChunk(_threadData?.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // -- APP BAR --
      appBar: AppBar(
        automaticallyImplyLeading: false,
        // -- TITLE --
        title: ThreadButton(
          name: _threadData?.name ?? defaultThreadName,
          onPressed: () => _showThreadList(context),
        ),
        // -- ACTIONS --
        actions: <Widget>[
          IconButton(
            onPressed: () => _showNewMessage(context),
            icon: const Icon(Icons.add_outlined),
          ),
        ],
      ),
      // -- BODY --
      body: FutureBuilder<void>(
        future: _readThreadFuture,
        builder: _messageListBuilder,
      ),
    );
  }

  Widget _messageListBuilder(
    BuildContext context,
    AsyncSnapshot<void> snapshot,
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

    // if (!snapshot.hasData) return Container();

    // List<Message> messageList = snapshot.data!;

    // -- MESSAGE LIST --
    return Column(
      children: [
        const SizedBox(height: 10.0),
        Expanded(
          child: SizedBox(
            child: Scrollbar(
              controller: _scrollController,
              child: ListView.separated(
                controller: _scrollController,
                itemCount: context.watch<MessageViewModel>().messages.length,
                itemBuilder: (_, i) {
                  return MessageListViewItem(
                    message: context.watch<MessageViewModel>().messages[i],
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return const Divider(thickness: 0.5);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showThreadList(BuildContext context) async {
    final ThreadNameListResult? result;
    result = await showModalBottomSheet<ThreadNameListResult>(
      context: context,
      backgroundColor: Theme.of(context).canvasColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(bottomSheetRadius),
        ),
      ),
      builder: (_) => const ThreadListBottomSheet(),
    );

    if (result == null) return;

    switch (result.type) {
      case ThreadListResultType.thread:
        final threadId = result.data as int?;
        setState(() {
          _model.currentThreadId = threadId;
          _threadData = _model.currentThreadData;
          _readThreadFuture = _model.readThreadChunk(_threadData?.id);
        });
        break;
      case ThreadListResultType.newThreadRequest:
        _showNewThread(context);
        break;
    }
    return;
  }

  void _showNewThread(BuildContext context) async {
    final int? threadId = await showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).canvasColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(bottomSheetRadius),
        ),
      ),
      builder: (_) => const NewThreadBottomSheet(),
    );

    if (threadId == null) return;

    setState(() {
      _model.currentThreadId = threadId;
      _threadData = _model.currentThreadData;
      _readThreadFuture = _model.readThreadChunk(_threadData?.id);
    });

    return;
  }

  void _showNewMessage(BuildContext context) async {
    var result = await Navigator.of(context).pushNamed(
      NewMessageScreen.routeName,
      arguments: _threadData?.id,
    );

    if (result == null) return;

    result = result as NewMessageScreenResult;
    bool isSaved = result.isSaved;
    int? savedMessageThreadId = result.savedMessageThreadId;
    if (isSaved && savedMessageThreadId == _threadData?.id) {
      setState(() {
        _readThreadFuture = _model.readThreadChunk(_threadData?.id);
      });
    }
  }
}
