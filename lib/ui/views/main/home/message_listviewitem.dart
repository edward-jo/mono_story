import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MessageListViewItem extends StatelessWidget {
  const MessageListViewItem({Key? key, required this.message})
      : super(key: key);

  final Map<String, dynamic> message;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(
            left: 15.0,
            top: 5.0,
            bottom: 5.0,
            right: 10.0,
          ),
          child: Text(message['message']),
        ),
        const Divider(thickness: 1.0),
      ],
    );
  }
}
