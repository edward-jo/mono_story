import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../../fake_data.dart';

class ThreadPicker extends StatelessWidget {
  final List<String> items;
  final void Function(int) onSelectedItemChanged;
  const ThreadPicker({
    Key? key,
    required this.onSelectedItemChanged,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CupertinoColors.white,
      height: 250,
      alignment: Alignment.bottomCenter,
      child: CupertinoPicker(
        useMagnifier: true,
        magnification: 1.1,
        itemExtent: 48,
        scrollController: FixedExtentScrollController(initialItem: 0),
        children: List.generate(items.length, (index) => Text(items[index])),
        onSelectedItemChanged: onSelectedItemChanged,
      ),
    );
  }
}
