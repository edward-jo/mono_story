import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../thread_list_bottom_sheet.dart';
import '/constants.dart';

class NewMessageScreen extends StatefulWidget {
  const NewMessageScreen({Key? key}) : super(key: key);

  @override
  _NewMessageScreenState createState() => _NewMessageScreenState();
}

class _NewMessageScreenState extends State<NewMessageScreen> {
  final _newMessageController = TextEditingController();
  String _currentThreadName = '';
  bool _loadedInitData = false;

  @override
  void didChangeDependencies() {
    if (!_loadedInitData) {
      String arguments = ModalRoute.of(context)!.settings.arguments as String;
      _currentThreadName = arguments.isEmpty ? 'All' : arguments;
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
            onPressed: () {},
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
                    onPressed: () => _showThreadSelectList(context),
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

  void _showThreadSelectList(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return ThreadListBottomSheet(onTap: (threadName) {
          setState(() {
            _currentThreadName = threadName;
          });
          Navigator.of(context).pop();
        });
      },
    );
  }
}
