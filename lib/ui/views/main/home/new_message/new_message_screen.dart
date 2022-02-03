import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mono_story/constants.dart';
import 'package:mono_story/models/message.dart';
import 'package:mono_story/models/thread.dart';
import 'package:mono_story/ui/views/main/home/common/new_thread_bottom_sheet.dart';
import 'package:mono_story/ui/views/main/home/common/thread_list_bottom_sheet.dart';
import 'package:mono_story/view_models/message_viewmodel.dart';
import 'package:mono_story/view_models/thread_viewmodel.dart';
import 'package:provider/provider.dart';

class NewMessageScreen extends StatefulWidget {
  static const routeName = '/new_message';
  const NewMessageScreen({Key? key}) : super(key: key);

  @override
  _NewMessageScreenState createState() => _NewMessageScreenState();
}

class _NewMessageScreenState extends State<NewMessageScreen> {
  final _newMessageController = TextEditingController();
  late final ThreadViewModel _threadVM;
  late final MessageViewModel _messageVM;
  Thread? _threadData;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _threadVM = context.read<ThreadViewModel>();
    _messageVM = context.read<MessageViewModel>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      int? threadId = ModalRoute.of(context)!.settings.arguments as int?;
      if (threadId == null) {
        _threadData = null;
      } else {
        _threadData = _threadVM.findThreadData(id: threadId);
      }
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // -- APP BAR --
      appBar: AppBar(
        automaticallyImplyLeading: false,
        // -- CANCEL BUTTON --
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close_outlined),
        ),
        title: const Text('New Message'),
        // -- SAVE BUTTON --
        actions: <Widget>[
          IconButton(
            onPressed: () => _save(context),
            icon: const Icon(Icons.save_alt_outlined),
          ),
        ],
      ),

      // -- BODY --
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * scaffoldBodyWidthRate,
          alignment: Alignment.topCenter,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // -- THREAD NAME --
              Builder(builder: (ctx) {
                if (_threadData == null) {
                  return ActionChip(
                    backgroundColor: undefinedThreadBgColor,
                    label: const Text('Select thread'),
                    onPressed: () => _showThreadList(ctx),
                  );
                }

                return InputChip(
                  backgroundColor: threadNameBgColor,
                  label: Text(_threadData!.name),
                  deleteIcon: const Icon(Icons.cancel),
                  deleteIconColor: Colors.grey,
                  onDeleted: () => setState(() => _threadData = null),
                  onPressed: () => _showThreadList(ctx),
                );
              }),

              const Divider(),

              // -- MESSAGE TEXT FIELD --
              TextField(
                autofocus: true,
                maxLines: 7,
                keyboardType: TextInputType.text,
                keyboardAppearance: Brightness.light,
                controller: _newMessageController,
                decoration: const InputDecoration(
                  hintText: 'Compose story',
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future _save(BuildContext context) async {
    final String message = _newMessageController.text.trim();

    if (message.isEmpty) {
      return;
    }

    developer.log('Save messasge( $message )');
    await _messageVM.save(
      Message(
        id: null,
        message: message,
        threadId: _threadData?.id,
        createdTime: DateTime.now(),
      ),
    );

    final result = NewMessageScreenResult(
      isSaved: true,
      savedMessageThreadId: _threadData?.id,
    );

    Navigator.of(context).pop(result);
    return;
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
      builder: (ctx) => const ThreadListBottomSheet(),
    );

    if (result == null) return;

    switch (result.type) {
      case ThreadListResultType.thread:
        final threadId = result.data as int?;
        if (threadId == null) {
          setState(() => _threadData = null);
        } else {
          setState(() => _threadData = _threadVM.findThreadData(id: threadId));
        }
        break;
      case ThreadListResultType.newThreadRequest:
        _showNewThread(context);
        break;
    }
    return;
  }

  void _showNewThread(BuildContext context) async {
    final int? newThreadId = await showModalBottomSheet(
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

    if (newThreadId == null) return;

    setState(() => _threadData = _threadVM.findThreadData(id: newThreadId));
    return;
  }
}

class NewMessageScreenResult {
  final int? savedMessageThreadId;
  final bool isSaved;
  const NewMessageScreenResult(
      {this.savedMessageThreadId, required this.isSaved});
}
