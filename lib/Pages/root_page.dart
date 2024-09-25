import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/Pages/add_new_post_page.dart';
import 'package:instagram_clone/Pages/home_page.dart';
import 'package:instagram_clone/Pages/profile_page.dart';
import 'package:instagram_clone/Pages/search_page.dart';

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  int currentIndex = 0;
  List<Widget> pages = [
    const HomePage(),
    const SearchPage(),
    const AddNewPostPage(),
    const ProfilePage(),
  ];

  List<IconData> icons = [
    Icons.home_filled,
    CupertinoIcons.search,
    Icons.add_box_outlined,
    Icons.person,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: AnimatedBottomNavigationBar(
        elevation: 0,
        backgroundColor:
        AdaptiveTheme.of(context).mode.isDark ? Colors.black26: Colors.white,
        gapWidth: 1,
        icons: icons,
        activeIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}
