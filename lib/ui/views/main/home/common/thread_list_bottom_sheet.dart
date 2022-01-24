import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mono_story/view_models/message_viewmodel.dart';
import 'package:provider/provider.dart';

class ThreadListBottomSheet extends StatelessWidget {
  const ThreadListBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Column(
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
                itemCount: context.watch<MessageViewModel>().threads.length,
                itemBuilder: (_, i) {
                  // -- THREAD LIST NAME ITEM --
                  return Container(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.topic),
                          title: Text(
                            context.watch<MessageViewModel>().threads[i].name,
                            style: TextStyle(
                              fontSize: textTheme.bodyText2?.fontSize,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.fade,
                            softWrap: false,
                          ),
                          trailing: const SizedBox(width: 20),
                          onTap: () => Navigator.of(context).pop(
                            ThreadNameListResult(
                              type: ThreadListResultType.thread,
                              data: context.read<MessageViewModel>().threads[i],
                            ),
                          ),
                        ),
                        const Divider(height: 1),
                      ],
                    ),
                  );
                }),
          ),
        ),
        const SizedBox(height: 10),

        // -- CREATE NEW THREAD BUTTON --
        TextButton(
          onPressed: () => Navigator.of(context).pop(ThreadNameListResult(
            type: ThreadListResultType.newThreadRequest,
          )),
          child: const Text('Create New Thread'),
        ),
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
