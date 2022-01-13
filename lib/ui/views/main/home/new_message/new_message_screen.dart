import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mono_story/fake_data.dart';

import '/constants.dart';

class NewMessageScreen extends StatefulWidget {
  const NewMessageScreen({Key? key}) : super(key: key);

  @override
  _NewMessageScreenState createState() => _NewMessageScreenState();
}

class _NewMessageScreenState extends State<NewMessageScreen> {
  final _newMessageController = TextEditingController();

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
                Text(
                  fakeThreads.last,
                  style: Theme.of(context)
                      .textTheme
                      .headline6!
                      .copyWith(backgroundColor: threadNameBgColor),
                ),
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
}
