import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:realm/screens/ai_chat_screen.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            // leading: IconButton(onPressed: () {}, icon: const Icon(Icons.chat)),
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
                    hintText: 'Search Chats',
                  ),
                ),
              ),
            ),
            actions: [
              TextButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AiChatScreen()),
                ),
                label: Text('Chat with AI'),
                icon: FaIcon(FontAwesomeIcons.openai),
              ),
            ],
          ),
          // SliverToBoxAdapter(child: LinearProgressIndicator()),
          SliverPadding(padding: const EdgeInsets.only(top: 10)),
          SliverList.builder(
            itemBuilder: (context, index) => Card(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(index == 0 ? 20 : 0),
                ),
              ),
              child: Column(
                children: [
                  ListTile(
                    onTap: () {},
                    title: Text('Chat $index'),
                    subtitle: Text('Lorem ipsum dolor sit amet'),
                    leading: const CircleAvatar(radius: 20),
                  ),
                  Divider(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
