import 'package:flutter/material.dart';
import 'package:realm/screens/chats_screen.dart';
import 'package:realm/screens/forums_screens.dart';
import 'package:realm/screens/home_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentPageIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: [
        const HomeScreen(),
        const ForumsScreens(),
        const ChatsScreen(),
      ].elementAt(currentPageIndex),
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(
              icon: Icon(
                Icons.home_filled,
              ),
              label: 'Home'),
          NavigationDestination(
              icon: Icon(
                Icons.forum_outlined,
              ),
              selectedIcon: Icon(
                Icons.forum,
              ),
              label: 'Forums'),
          NavigationDestination(
              icon: Icon(
                Icons.chat_outlined,
              ),
              selectedIcon: Icon(
                Icons.chat,
              ),
              label: 'Chats'),
        ],
        selectedIndex: currentPageIndex,
        onDestinationSelected: (index) =>
            setState(() => currentPageIndex = index),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
    );
  }
}
