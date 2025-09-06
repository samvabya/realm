import 'package:flutter/material.dart';
import 'package:realm/components/post_card.dart';
import 'package:realm/main.dart';
import 'package:realm/model/post.dart';
import 'package:realm/model/user.dart';
import 'package:realm/util.dart';

class ProfileScreen extends StatefulWidget {
  final String? uid;
  const ProfileScreen({super.key, this.uid});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? user;
  int segmentIndex = 0;
  List<PostModel> allPosts = [];
  List<PostModel> filteredPosts = [];
  Future<void> getUser() async {
    try {
      await supabase
          .from('users')
          .select()
          .eq('id', widget.uid ?? supabase.auth.currentUser?.id ?? '')
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
          .select()
          .eq('userId', widget.uid ?? supabase.auth.currentUser?.id ?? '')
          .order('created_at', ascending: false)
          .then(
            (value) => posts = value.map((e) => PostModel.fromJson(e)).toList(),
          );
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
    setState(() {
      allPosts = posts;
      if (segmentIndex == 0) {
        filteredPosts = posts;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([getUser(), getAllPosts()]),
      builder: (context, asyncSnapshot) {
        if (user == null) {
          return Scaffold(
            body: Column(children: [AppBar(), LinearProgressIndicator()]),
          );
        }
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(88),
                  child: ListTile(
                    isThreeLine: true,
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundImage: user?.image != null
                          ? NetworkImage(formattedUrl(user!.image!))
                          : null,
                      child: user?.image == null
                          ? const Icon(Icons.person, size: 30)
                          : null,
                    ),
                    title: Text(
                      user?.name ?? 'Realm User',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    subtitle: Text(
                      '@${getUsernameByEmail(user?.email)}\n${user?.bio ?? ''}',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                ),
                actions: [
                  if (user?.id == supabase.auth.currentUser?.id) ...[
                    FilledButton.tonalIcon(
                      onPressed: () async {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Logout?'),
                            content: const Text(
                              'Are you sure you want to logout?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  Navigator.popUntil(
                                    context,
                                    (route) => route.isFirst,
                                  );
                                  await supabase.auth.signOut();
                                },
                                child: const Text('Logout'),
                              ),
                            ],
                          ),
                        );
                      },
                      label: Text(
                        'Logout',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      icon: const Icon(Icons.logout),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () {},
                    ),
                  ] else ...[
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.chat_outlined),
                    ),
                  ],
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      SegmentedButton(
                        showSelectedIcon: false,
                        segments: const <ButtonSegment<int>>[
                          ButtonSegment<int>(value: 0, label: Text('All')),
                          ButtonSegment<int>(
                            value: 1,
                            icon: Icon(Icons.photo_outlined),
                          ),
                          ButtonSegment<int>(
                            value: 2,
                            icon: Icon(Icons.cloud_outlined),
                          ),
                        ],
                        selected: <int>{segmentIndex},
                        onSelectionChanged: (Set<int> newSelection) {
                          setState(() {
                            segmentIndex = newSelection.first;
                            switch (segmentIndex) {
                              case 0:
                                filteredPosts = allPosts;
                                break;
                              case 1:
                                filteredPosts = allPosts
                                    .where((post) => post.file != null)
                                    .toList();
                                break;
                              case 2:
                                filteredPosts = allPosts
                                    .where((post) => post.file == null)
                                    .toList();
                                break;
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SliverList.builder(
                itemCount: filteredPosts.length,
                itemBuilder: (context, index) =>
                    PostCard(post: filteredPosts[index]),
              ),
            ],
          ),
        );
      },
    );
  }
}
