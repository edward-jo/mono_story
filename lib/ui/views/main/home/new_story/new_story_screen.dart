import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:mono_story/constants.dart';
import 'package:mono_story/models/story.dart';
import 'package:mono_story/models/thread.dart';
import 'package:mono_story/ui/views/main/home/common/new_thread_bottom_sheet.dart';
import 'package:mono_story/ui/views/main/home/common/thread_list_bottom_sheet.dart';
import 'package:mono_story/view_models/story_viewmodel.dart';
import 'package:mono_story/view_models/thread_viewmodel.dart';
import 'package:provider/provider.dart';

class NewStoryScreen extends StatefulWidget {
  static const routeName = '/new_story';
  const NewStoryScreen({Key? key}) : super(key: key);

  @override
  _NewStoryScreenState createState() => _NewStoryScreenState();
}

class _NewStoryScreenState extends State<NewStoryScreen> {
  final _newStoryController = TextEditingController();
  late final ThreadViewModel _threadVM;
  late final StoryViewModel _storyVM;
  Thread? _threadData;
  bool _initialized = false;
  bool _disableSaveButton = true;

  @override
  void initState() {
    super.initState();
    _threadVM = context.read<ThreadViewModel>();
    _storyVM = context.read<StoryViewModel>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final arguments = ModalRoute.of(context)!.settings.arguments
          as NewStoryScreenArgument;
      int? threadId = arguments.threadId;
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
        title: const Text('New Story'),
        // -- SAVE BUTTON --
        actions: <Widget>[
          TextButton(
            onPressed: _disableSaveButton ? null : () => _save(context),
            child: const Text('Save'),
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

              // -- STORY TEXT FIELD --
              Expanded(
                child: TextField(
                  autofocus: true,
                  maxLines: null,
                  maxLength: storyMaxLength,
                  keyboardType: TextInputType.multiline,
                  controller: _newStoryController,
                  onSubmitted: (_) => _save(context),
                  onChanged: (value) {
                    if (value.isEmpty) {
                      setState(() => _disableSaveButton = true);
                    } else if (_disableSaveButton) {
                      setState(() => _disableSaveButton = false);
                    }
                  },
                  decoration: const InputDecoration(
                    hintText: 'Compose story',
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                  inputFormatters: <TextInputFormatter>[
                    _DenyFirstNewLineFormatter(),
                    FilteringTextInputFormatter(
                      '\n\n\n',
                      allow: false,
                      replacementString: '\n\n',
                    ),
                  ],
                  // inputFormatters: <TextInputFormatter>[_NewLineFormatter()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future _save(BuildContext context) async {
    final String story = _newStoryController.text.trim();

    if (story.isEmpty) {
      return;
    }

    final result = NewStoryScreenResult(
      isSaved: true,
      savedStoryThreadId: _threadData?.id,
      story: story,
    );

    Navigator.of(context).pop(result);
    return;
  }

  void _showThreadList(BuildContext context) async {
    final ThreadListResult? result;
    result = await showModalBottomSheet<ThreadListResult>(
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
    final int? newThreadId = await showModalBottomSheet<int>(
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

class NewStoryScreenArgument {
  final int? threadId;
  NewStoryScreenArgument(this.threadId);
}

class NewStoryScreenResult {
  final int? savedStoryThreadId;
  final bool isSaved;
  final String story;
  const NewStoryScreenResult({
    this.savedStoryThreadId,
    required this.isSaved,
    required this.story,
  });
}

class _DenyFirstNewLineFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return (newValue.text == '\n') ? oldValue : newValue;
  }
}
