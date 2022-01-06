import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import 'home/home_page.dart';

class MainPage extends StatefulWidget {
  static final routeName = '/main';
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const HomePage(),
    const Center(child: Text('Search')),
    const Center(child: Text('Starred')),
  ];

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      // BODY
      body: _widgetOptions[_selectedIndex],

      // BOTTOM NAVIGATION BAR
      bottomNavBar: PlatformNavBar(
        currentIndex: _selectedIndex,
        itemChanged: (index) => setState(() {
          _selectedIndex = index;
        }),
        items: [
          BottomNavigationBarItem(
            icon: Icon(PlatformIcons(context).home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(PlatformIcons(context).search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(PlatformIcons(context).star),
            label: 'Starred',
          ),
        ],
      ),
    );
  }
}
