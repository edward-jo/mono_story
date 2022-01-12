import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mono_story/ui/common/modal_page_route.dart';
import 'package:mono_story/ui/views/main/home/new_message/new_message_screen.dart';

import 'thread_select_button.dart';
import 'message_listview.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _currentThread = 'All';

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        // -- APP BAR --
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Builder(builder: (context) {
            return ThreadSelectButton(
              name: _currentThread,
              onPressed: () => showThreadSelectList(context),
            );
          }),
          actions: <Widget>[
            Builder(builder: (context) {
              return IconButton(
                onPressed: () => showNewMessage(context),
                icon: const Icon(Icons.add_outlined),
              );
            })
          ],
        ),

        // -- BODY --
        body: const SafeArea(
          child: MessageListView(),
        ),
      ),
    );
  }

  void showThreadSelectList(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          child: Column(
            children: <Widget>[
              const SizedBox(height: 20),
              Text(
                'Select Thread',
                style: Theme.of(context)
                    .textTheme
                    .bodyText1!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: SizedBox(
                  child: ListView.builder(
                      itemCount: 15,
                      itemBuilder: (_, i) {
                        return ListTile(
                          leading: const Icon(Icons.access_alarm),
                          title: Text(
                            "Item 012345 67891234567890 $i",
                            style: TextStyle(
                                fontSize: Theme.of(context)
                                    .textTheme
                                    .headline6
                                    ?.fontSize),
                            overflow: TextOverflow.fade,
                            softWrap: false,
                          ),
                          trailing: const SizedBox(width: 20),
                          onTap: () => Navigator.of(context).pop(),
                        );
                      }),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  void showNewMessage(BuildContext context) {
    Navigator.of(context).push(
      ModalPageRoute(child: const NewMessageScreen()),
    );
  }
}
