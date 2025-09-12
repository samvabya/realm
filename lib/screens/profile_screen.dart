import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:realm/components/post_card.dart';
import 'package:realm/components/thought_card.dart';
import 'package:realm/main.dart';
import 'package:realm/model/post.dart';
import 'package:realm/model/thought.dart';
import 'package:realm/model/user.dart';
import 'package:realm/screens/user_chat.dart';
import 'package:realm/util.dart';

class ProfileScreen extends StatefulWidget {
  final String? uid;
  const ProfileScreen({super.key, this.uid});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  bool isLoading = false;
  UserModel? user;
  int segmentIndex = 0;
  List<PostModel> allPosts = [];
  List<ThoughtModel> allThoughts = [];
  TabController? tabController;

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
          .select('''
              id,
              userId,
              file,
              body,
              created_at,
              users(id, name, image)
            ''')
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
    });
  }

  Future<void> getAllThoughts() async {
    List<ThoughtModel> thoughts = [];
    try {
      await supabase
          .from('thoughts')
          .select('''
              id,
              userId,
              file,
              body,
              created_at,
              users(id, name, image)
            ''')
          .eq('userId', widget.uid ?? supabase.auth.currentUser?.id ?? '')
          .isFilter('head', null)
          .order('created_at', ascending: false)
          .then(
            (value) => thoughts = value.map((e) {
              return ThoughtModel.fromJson(e);
            }).toList(),
          );
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
    setState(() {
      allThoughts = thoughts;
    });
  }

  void getData() async {
    setState(() => isLoading = true);
    await getUser();
    await getAllPosts();
    await getAllThoughts();
    setState(() => isLoading = false);
  }

  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this);
    getData();
    super.initState();
  }

  Widget _buildUserAvatar() {
    return GestureDetector(
      onTap: user?.story == null
          ? null
          : () => showDialog(
              context: context,
              builder: (context) => Container(
                child: Center(child: Image.network(formattedUrl(user!.story!))),
              ),
            ),
      onLongPress: user?.image == null
          ? null
          : () => showDialog(
              context: context,
              builder: (context) => Container(
                child: Center(
                  child: ClipOval(
                    child: Image.network(
                      formattedUrl(user!.image!),
                      width: 200,
                    ),
                  ),
                ),
              ),
            ),
      child: CircleAvatar(
        radius: 30,
        backgroundImage: user?.image != null
            ? NetworkImage(formattedUrl(user!.image!))
            : null,
        child: user?.image == null ? const Icon(Icons.person, size: 30) : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Column(children: [AppBar(), LinearProgressIndicator()])
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  floating: true,
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
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserChat(user: user!),
                          ),
                        ),
                        icon: const Icon(Icons.chat_outlined),
                      ),
                    ],
                  ],
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(150),
                    child: Column(
                      children: [
                        ListTile(
                          isThreeLine: true,
                          leading: user?.story == null
                              ? _buildUserAvatar()
                              : AvatarGlow(
                                  glowRadiusFactor: 0.5,
                                  startDelay: const Duration(
                                    milliseconds: 1000,
                                  ),
                                  glowColor: Theme.of(
                                    context,
                                  ).colorScheme.primary,
                                  glowShape: BoxShape.circle,
                                  curve: Curves.fastOutSlowIn,
                                  child: _buildUserAvatar(),
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
                        TabBar(
                          controller: tabController,
                          tabs: [
                            Tab(icon: Icon(Icons.photo_outlined)),
                            Tab(icon: Icon(Icons.tag)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.9,
                    child: TabBarView(
                      controller: tabController,
                      children: [
                        ListView.builder(
                          itemCount: allPosts.length,
                          itemBuilder: (context, index) =>
                              PostCard(post: allPosts[index]),
                        ),
                        ListView.builder(
                          itemCount: allThoughts.length,
                          itemBuilder: (context, index) =>
                              ThoughtCard(thought: allThoughts[index]),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
