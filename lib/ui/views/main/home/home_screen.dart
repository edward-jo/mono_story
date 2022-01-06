import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      const Center(child: Text('tab1 page')),
      const Center(child: Text('tab2 page')),
      const Center(child: Text('tab3 page')),
      const Center(child: Text('tab4 page')),
      const Center(child: Text('tab5 page')),
    ];
    return PlatformWidget(
      cupertino: (_, __) => CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Image.asset(
            'assets/images/appbar_title_blue.png',
            width: 64,
            height: 64,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              CupertinoTabView(
                builder: (context) => items[_currentIndex],
              ),
              Container(
                alignment: Alignment.bottomRight,
                child: CupertinoButton(
                  child: const Text('BUTTON'),
                  onPressed: () => setState(() {
                    _currentIndex =
                        (_currentIndex >= 4) ? 0 : _currentIndex + 1;
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
      //
      // MATERIAL
      //
      material: (_, __) => DefaultTabController(
        length: 5,
        child: Scaffold(
          // APP BAR
          appBar: AppBar(
            title: Image.asset(
              'assets/images/appbar_title_white.png',
              width: 64,
              height: 64,
            ),
          ),
          // body: const Center(child: Text('Home Page')),
          body: const SafeArea(
            child: TabBarView(
              children: [
                Center(child: Text('tab1 page')),
                Center(child: Text('tab2 page')),
                Center(child: Text('tab3 page')),
                Center(child: Text('tab4 page')),
                Center(child: Text('tab5 page')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
