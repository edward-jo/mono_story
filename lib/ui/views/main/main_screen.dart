import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mono_story/ui/common/platform_widget.dart';
import 'package:mono_story/ui/views/main/home/home_screen.dart';
import 'package:mono_story/ui/views/main/settings/settings_screen.dart';
import 'package:mono_story/ui/views/main/starred/starred_screen.dart';

class MainScreen extends StatefulWidget {
  static final routeName = '/main';
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  static final _homeScreenKey = GlobalKey<HomeScreenState>();
  static final _starredScreenKey = GlobalKey<StarredScreenState>();
  static final List<Widget> _widgetOptions = <Widget>[
    HomeScreen(key: _homeScreenKey),
    StarredScreen(key: _starredScreenKey),
    const SettingsScreen(),
  ];

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // BODY
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      // BOTTOM NAVIGATION BAR
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        items: mainBottomNavBarItems(),
        onTap: (index) {
          if (_selectedIndex == index) {
            switch (index) {
              case 0:
                _homeScreenKey.currentState?.scrollToTop();
                return;
              case 1:
                _starredScreenKey.currentState?.scrollToTop();
                return;
            }
            return;
          }
          setState(() => _selectedIndex = index);
        },
      ),
    );
  }

  List<BottomNavigationBarItem> mainBottomNavBarItems() {
    return const <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        icon: PlatformWidget(
          cupertino: Icon(CupertinoIcons.home),
          material: Icon(Icons.home),
        ),
        label: 'Home',
      ),
      BottomNavigationBarItem(
        icon: PlatformWidget(
          cupertino: Icon(CupertinoIcons.star),
          material: Icon(Icons.star),
        ),
        label: 'Starred',
      ),
      BottomNavigationBarItem(
        icon: PlatformWidget(
          cupertino: Icon(CupertinoIcons.settings), // CupertinoIcons.bars
          material: Icon(Icons.settings), // Icons.menu
        ),
        label: 'Settings',
      ),
    ];
  }
}
