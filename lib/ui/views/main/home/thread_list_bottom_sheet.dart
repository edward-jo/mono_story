import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:mono_story/fake_data.dart';

class ThreadListBottomSheet extends StatelessWidget {
  final void Function(String) onTap;
  const ThreadListBottomSheet({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                  itemCount: fakeThreads.length,
                  itemBuilder: (_, i) {
                    return ListTile(
                      leading: const Icon(Icons.access_alarm),
                      title: Text(
                        fakeThreads[i],
                        style: TextStyle(
                            fontSize: Theme.of(context)
                                .textTheme
                                .headline6
                                ?.fontSize),
                        overflow: TextOverflow.fade,
                        softWrap: false,
                      ),
                      trailing: const SizedBox(width: 20),
                      onTap: () => onTap(fakeThreads[i]),
                    );
                  }),
            ),
          )
        ],
      ),
    );
  }
}
