import 'package:flutter/material.dart';

class ForumsScreens extends StatefulWidget {
  const ForumsScreens({super.key});

  @override
  State<ForumsScreens> createState() => _ForumsScreensState();
}

class _ForumsScreensState extends State<ForumsScreens> {
  bool isFabExtended = true;
  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollUpdateNotification) {
            if (notification.scrollDelta! > 0) {
              // Scrolling down
              setState(() {
                isFabExtended = false;
              });
            } else {
              // Scrolling up
              setState(() {
                isFabExtended = true;
              });
            }
          }
          return true;
        },
        child: CustomScrollView(
          controller: scrollController,
          slivers: [
            SliverAppBar(
              floating: true,
              leading: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.tag),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(88),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 5,
                  ),
                  child: TextField(
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      hintText: 'Search Forums',
                    ),
                  ),
                ),
              ),
              actions: [
                PopupMenuButton<int>(
                  onSelected: (value) {},
                  itemBuilder: (context) {
                    return [
                      const PopupMenuItem(
                        value: 0,
                        child: Row(
                          children: [
                            Icon(Icons.settings, size: 20),
                            SizedBox(width: 10),
                            Text('Settings'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 1,
                        child: Row(
                          children: [
                            Icon(Icons.help, size: 20),
                            SizedBox(width: 10),
                            Text('Help'),
                          ],
                        ),
                      ),
                    ];
                  },
                  icon: const Icon(Icons.more_horiz),
                ),
              ],
            ),
            // SliverToBoxAdapter(child: LinearProgressIndicator()),
            SliverList.builder(
              itemBuilder: (context, index) =>
                  const AspectRatio(aspectRatio: 3 / 2, child: Card()),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        extendedIconLabelSpacing: isFabExtended ? 10 : 0,
        onPressed: () {},
        label: AnimatedSize(
          duration: const Duration(milliseconds: 250),
          child: isFabExtended ? const Text("Compose") : const SizedBox(),
        ),
        icon: const Icon(Icons.edit),
      ),
      // bottomNavigationBar: BottomAppBar(),
    );
  }
}
