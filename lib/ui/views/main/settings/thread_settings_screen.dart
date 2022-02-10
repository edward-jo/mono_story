import 'package:flutter/material.dart';

class ThreadSettingsScreen extends StatelessWidget {
  const ThreadSettingsScreen({Key? key}) : super(key: key);

  static const String routeName = '/settings/thread';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text('Thread'),
      ),
      body: const Center(child: Text('Thread Settings')),
    );
  }
}
