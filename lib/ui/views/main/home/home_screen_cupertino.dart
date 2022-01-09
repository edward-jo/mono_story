import 'dart:developer' as developer;
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:mono_story/fake_data.dart';
import 'package:mono_story/ui/views/main/home/message_listview.dart';
import 'package:mono_story/ui/views/main/home/thread_button.dart';
import 'package:mono_story/ui/views/main/home/thread_picker.dart';

class HomeScreenCupertino extends StatefulWidget {
  const HomeScreenCupertino({Key? key}) : super(key: key);

  @override
  _HomeScreenCupertinoState createState() => _HomeScreenCupertinoState();
}

class _HomeScreenCupertinoState extends State<HomeScreenCupertino> {
  int _currentIndex = 0;
  String _currentThread = 'All';
  final items = <Widget>[
    const Center(child: Text('tab1 page')),
    const Center(child: Text('tab2 page')),
    const Center(child: Text('tab3 page')),
    const Center(child: Text('tab4 page')),
    const Center(child: Text('tab5 page')),
  ];

  @override
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      // -- NAVIGATION BAR --
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.white,
        border: null,
        middle: Builder(
          builder: (context) => ThreadSelectButton(
            name: _currentThread,
            onPressed: () => showCupertinoThreadSelectPopup(context),
          ),
        ),
        trailing: CupertinoButton(
          padding: const EdgeInsets.only(top: 0),
          child: const Icon(CupertinoIcons.add),
          onPressed: () {},
        ),
      ),
      // -- BODY --
      child: const SafeArea(
        child: MessageListView(),
      ),
    );
  }

  void showCupertinoThreadSelectPopup(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) {
        return ThreadPicker(
          items: ['All', ...fakeThreads],
          onSelectedItemChanged: (value) {
            developer.log("Value: $value");
            _currentThread = value == 0 ? 'All' : fakeThreads[--value];
          },
        );
      },
    ).then((_) => setState(() {}));
  }
}
