import 'package:flutter/material.dart';

class ThoughtsScreens extends StatefulWidget {
  const ThoughtsScreens({super.key});

  @override
  State<ThoughtsScreens> createState() => _ThoughtsScreensState();
}

class _ThoughtsScreensState extends State<ThoughtsScreens> {
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
              title: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.tag, size: 30),
              ),
              centerTitle: true,
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
                      hintText: 'Search Thoughts',
                    ),
                  ),
                ),
              ),
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
        icon: const Icon(Icons.tag),
      ),
    );
  }
}
