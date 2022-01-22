import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:mono_story/fake_data.dart';

class ThreadNameListBottomSheet extends StatelessWidget {
  final void Function(String) onTap;
  const ThreadNameListBottomSheet({
    Key? key,
    required this.onTap,
  }) : super(key: key);

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
                itemCount: fakeThreads.length,
                itemBuilder: (_, i) {
                  // -- THREAD LIST NAME ITEM --
                  return Container(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.topic),
                          title: Text(
                            fakeThreads[i],
                            style: TextStyle(
                              fontSize: textTheme.bodyText2?.fontSize,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.fade,
                            softWrap: false,
                          ),
                          trailing: const SizedBox(width: 20),
                          onTap: () => onTap(fakeThreads[i]),
                        ),
                        const Divider(height: 1),
                      ],
                    ),
                  );
                }),
          ),
        )
      ],
    );
  }
}
