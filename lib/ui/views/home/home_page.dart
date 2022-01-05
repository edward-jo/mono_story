import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: PlatformWidget(
          cupertino: (_, __) => Image.asset(
            'assets/images/appbar_title_blue.png',
            width: 64,
            height: 64,
          ),
          material: (_, __) => Image.asset(
            'assets/images/appbar_title_white.png',
            width: 64,
            height: 64,
          ),
        ),
      ),
      body: const Center(child: Text('MyHomePage')),
    );
  }
}
