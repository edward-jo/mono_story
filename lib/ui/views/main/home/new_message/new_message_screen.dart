import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mono_story/models/message.dart';
import 'package:mono_story/view_models/message_viewmodel.dart';
import 'package:provider/provider.dart';

import '/constants.dart';
import '../threadname_list_bottom_sheet.dart';

class NewMessageScreen extends StatefulWidget {
  const NewMessageScreen({Key? key}) : super(key: key);

  @override
  _NewMessageScreenState createState() => _NewMessageScreenState();
}

class _NewMessageScreenState extends State<NewMessageScreen> {
  final _newMessageController = TextEditingController();
  String _currentThreadName = '';
  bool _loadedInitData = false;
  late final MessageViewModel _model;

  @override
  void initState() {
    super.initState();
    _model = context.read<MessageViewModel>();
  }

  @override
  void didChangeDependencies() {
    if (!_loadedInitData) {
      NewMessageScreenArguments arguments = ModalRoute.of(context)!
          .settings
          .arguments as NewMessageScreenArguments;
      _currentThreadName = arguments.threadName;
      _loadedInitData = true;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // -- APP BAR --
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close_outlined),
        ),
        title: const Text('New Message'),
        actions: <Widget>[
          IconButton(
            onPressed: () => _save(context),
            icon: const Icon(Icons.save_alt_outlined),
          ),
        ],
      ),

      // -- BODY --
      body: SafeArea(
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * scaffoldBodyWidthRate,
            alignment: Alignment.topCenter,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // -- THREAD NAME --
                Builder(builder: (context) {
                  return ActionChip(
                    backgroundColor: threadNameBgColor,
                    label: Text(_currentThreadName),
                    onPressed: () => _showThreadNameList(context),
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
                    border: InputBorder.none,
                  ),
                ),
              ],
            ),
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
    await _model.save(
      Message(
          id: null,
          message: message,
          threadNameId: 1,
          createdTime: DateTime.now()),
    );
    Navigator.of(context).pop();
    return;
  }

  void _showThreadNameList(BuildContext context) async {
    final selectedThreadName = await showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return ThreadNameListBottomSheet(onTap: (threadName) {
          Navigator.of(context).pop(threadName);
        });
      },
    );
    setState(() => _currentThreadName = selectedThreadName);
  }
}

class NewMessageScreenArguments {
  final String threadName;
  const NewMessageScreenArguments({required this.threadName});
}
