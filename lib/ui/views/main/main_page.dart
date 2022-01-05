import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
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
