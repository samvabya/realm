import 'package:flutter/material.dart';
import 'package:realm/screens/chats_screen.dart';
import 'package:realm/screens/thoughts_screen.dart';
import 'package:realm/screens/home_screen.dart';
import 'package:realm/util.dart';

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
        const ThoughtsScreens(),
        const ChatsScreen(),
      ].elementAt(currentPageIndex),
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.photo_outlined),
            selectedIcon: Icon(Icons.photo),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.cloud_outlined),
            selectedIcon: Icon(Icons.cloud),
            label: 'Thoughts',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_outlined),
            selectedIcon: Icon(Icons.chat),
            label: 'Chats',
          ),
          NavigationDestination(
            icon: Icon(Icons.star_border),
            selectedIcon: Icon(Icons.chat),
            label: 'Premium',
          ),
        ],
        selectedIndex: currentPageIndex,
        onDestinationSelected: (index) => index != 3
            ? setState(() => currentPageIndex = index)
            : showSnack('Feature coming soon!', context),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
    );
  }
}
