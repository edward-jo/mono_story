import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class MainPage extends StatefulWidget {
  static final routeName = '/main';
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const Center(child: Text('Home')),
    const Center(child: Text('Search')),
    const Center(child: Text('Starred')),
  ];

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      // APP BAR
      appBar: PlatformAppBar(
        title: PlatformWidget(
          cupertino: cupertinoImageAsset,
          material: materialImageAsset,
        ),
      ),

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

  Widget? cupertinoImageAsset(BuildContext context, PlatformTarget target) {
    String assetName = 'assets/images/appbar_title_blue.png';
    return Image.asset(assetName, width: 64, height: 64);
  }

  Widget? materialImageAsset(BuildContext context, PlatformTarget target) {
    String assetName = 'assets/images/appbar_title_white.png';
    return Image.asset(assetName, width: 64, height: 64);
  }
}
