import 'package:planit/main/utils/AppConstant.dart';
import 'package:flutter/material.dart';
import 'package:planit/navigationbar/userHome.dart';

class NavigationBarScreen {
  final String title;
  final Widget icon;
  final Widget activeIcon;
  final Widget page;
  final int index;
  const NavigationBarScreen(
      {required this.index,
      required this.title,
      required this.icon,
      required this.activeIcon,
      required this.page});
  static final List<NavigationBarScreen> pages = [
    NavigationBarScreen(
        index: 0,
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home),
        title: 'Home',
        page: HomePage()
    ),
    NavigationBarScreen(
        index: 1,
        icon: Icon(Icons.explore_outlined),
        activeIcon: Icon(Icons.explore),
        title: 'Explore',
        page: HomePage()
    ),
    NavigationBarScreen(
        index: 2,
        icon: Icon(Icons.location_on_outlined),
        activeIcon: Icon(Icons.location_on),
        title: 'My trips',
        page: HomePage()
    ),
    NavigationBarScreen(
        index: 3,
        icon: Icon(Icons.person_outlined),
        activeIcon: Icon(Icons.person),
        title: 'Profile',
        page: HomePage()
    ),
  ];
}
