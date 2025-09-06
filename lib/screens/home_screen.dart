import 'package:flutter/material.dart';
import 'package:realm/components/search_modal.dart';
import 'package:realm/screens/profile_screen.dart';
import 'package:realm/screens/stories_screeen.dart';
import 'package:realm/util.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isFabExtended = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollUpdateNotification) {
            if (notification.scrollDelta! > 0) {
              // Scrolling down
              setState(() => isFabExtended = false);
            } else {
              // Scrolling up
              setState(() => isFabExtended = true);
            }
          }
          return true;
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              leading: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.auto_awesome),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(88),
                child: ListTile(
                  title: Text(
                    'Hey ${getMyUsername3letters()}!',
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  subtitle: Text(
                    'What are you up to today?',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
              ),
              actions: [
                FilledButton.tonal(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => StoriesScreen()),
                  ),
                  child: Text(
                    'Stories',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
                IconButton(
                  onPressed: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    showDragHandle: true,
                    builder: (context) => const SearchModal(),
                  ),
                  icon: const Icon(Icons.search),
                ),
                IconButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  ),
                  icon: const Icon(Icons.account_circle_outlined),
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
          child: isFabExtended ? const Text("New Post") : const SizedBox(),
        ),
        icon: const Icon(Icons.photo),
      ),
    );
  }
}
