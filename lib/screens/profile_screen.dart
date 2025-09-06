import 'package:flutter/material.dart';
import 'package:realm/main.dart';
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
      showSnack(e.toString(), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getUser(),
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
                          ? NetworkImage(user!.image!)
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
              SliverList.builder(
                itemBuilder: (context, index) =>
                    const AspectRatio(aspectRatio: 3 / 2, child: Card()),
              ),
            ],
          ),
        );
      },
    );
  }
}
