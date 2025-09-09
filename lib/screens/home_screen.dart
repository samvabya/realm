import 'dart:async';

import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:realm/components/post_card.dart';
import 'package:realm/components/search_modal.dart';
import 'package:realm/main.dart';
import 'package:realm/model/post.dart';
import 'package:realm/model/user.dart';
import 'package:realm/screens/profile_screen.dart';
import 'package:realm/screens/stories_screen.dart';
import 'package:realm/util.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isFabExtended = true;
  bool isLoading = false;
  List<PostModel> allPosts = [];
  UserModel user = UserModel();

  Future<void> getUser() async {
    try {
      await supabase
          .from('users')
          .select()
          .eq('id', supabase.auth.currentUser?.id ?? '')
          .single()
          .then((value) => user = UserModel.fromJson(value));
      setState(() {});
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> getAllPosts() async {
    List<PostModel> posts = [];
    try {
      await supabase
          .from('posts')
          .select('''
              id,
              userId,
              file,
              body,
              created_at,
              users(id, name, image)
            ''')
          .order('created_at', ascending: false)
          .then(
            (value) => posts = value.map((e) {
              return PostModel.fromJson(e);
            }).toList(),
          );
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
    setState(() {
      allPosts = posts;
    });
  }

  Future<void> getData() async {
    await getUser();
    await getAllPosts();
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

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
        child: LiquidPullToRefresh(
          animSpeedFactor: 1.5,
          onRefresh: () async {
            setState(() => isLoading = true);
            await getData();
            Future.delayed(
              const Duration(seconds: 2),
              () => setState(() => isLoading = false),
            );
          },
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                title: Opacity(
                  opacity: 0.2,
                  child: Image.asset(
                    'assets/realm.png',
                    width: 70,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                actions: [
                  IconButton(
                    onPressed: () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      showDragHandle: true,
                      builder: (context) => const SearchModal(),
                    ),
                    icon: const Icon(Icons.search),
                  ),
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
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ),
                    ),
                    icon: CircleAvatar(
                      backgroundImage: user.image != null
                          ? NetworkImage(formattedUrl(user.image!))
                          : null,
                      child: user.image == null
                          ? Text(user.email?[0].toUpperCase() ?? '')
                          : null,
                    ),
                  ),
                ],
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
              ),
              if (isLoading) ...[
                SliverToBoxAdapter(child: LinearProgressIndicator()),
              ],
              SliverList.builder(
                itemCount: allPosts.length,
                itemBuilder: (context, index) =>
                    PostCard(post: allPosts[index]),
              ),
            ],
          ),
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
