import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
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
                  'Hey Sam!',
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                subtitle: Text(
                  'What are you up to today?',
                  style: GoogleFonts.lato(),
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
                          Icon(
                            Icons.settings,
                            size: 20,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text('Settings'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 1,
                      child: Row(
                        children: [
                          Icon(
                            Icons.help,
                            size: 20,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text('Help'),
                        ],
                      ),
                    ),
                  ];
                },
                icon: const Icon(Icons.more_horiz),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.search),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.account_circle_outlined),
              ),
            ],
          ),
          // SliverToBoxAdapter(child: LinearProgressIndicator()),
          SliverList.builder(
              itemBuilder: (context, index) => const AspectRatio(
                    aspectRatio: 3 / 2,
                    child: Card(),
                  )),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
