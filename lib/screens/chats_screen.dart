import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:realm/main.dart';
import 'package:realm/model/user.dart';
import 'package:realm/screens/ai_chat_screen.dart';
import 'package:realm/screens/user_chat.dart';
import 'package:realm/util.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  List<UserModel> allUsers = [];
  List<ChatSummary> allChats = [];
  bool isLoading = false;

  Future<List<ChatSummary>> getUniqueInteractedUserIds(String myId) async {
    final response = await supabase
        .from('chats')
        .select('sender_id, receiver_id, message, created_at')
        .or('sender_id.eq.$myId,receiver_id.eq.$myId')
        .order('created_at', ascending: false); // newest first

    if (response.isEmpty) {
      return [];
    }

    final Map<String, ChatSummary> latestMessages = {};

    for (final chat in response) {
      final senderId = chat['sender_id'] as String;
      final receiverId = chat['receiver_id'] as String;
      final message = chat['message'] as String;
      final createdAt = DateTime.parse(chat['created_at']);

      // Get the "other" user in the chat
      final otherUserId = senderId == myId ? receiverId : senderId;

      // If this user not seen yet, store their latest message
      if (!latestMessages.containsKey(otherUserId)) {
        latestMessages[otherUserId] = ChatSummary(
          userId: otherUserId,
          lastMessage: message,
          timestamp: createdAt,
        );
      }
    }

    return latestMessages.values.toList();
  }

  Future<List<UserModel>> getChatContacts() async {
    try {
      final response = await supabase.from('users').select('*');

      List<ChatSummary> chattedUsers = await getUniqueInteractedUserIds(
        supabase.auth.currentUser?.id ?? '',
      );

      setState(() => allChats = chattedUsers);

      return response
          .map((user) => UserModel.fromJson(user))
          .where((user) => chattedUsers.any((chat) => chat.userId == user.id))
          .toList();
    } catch (e) {
      debugPrint('Error getting chat contacts: $e');
      return [];
    }
  }

  void getData() async {
    setState(() => isLoading = true);
    allUsers = await getChatContacts();
    for (final chat in allChats) {
      chat.user = allUsers.firstWhere((user) => user.id == chat.userId);
    }
    setState(() => isLoading = false);
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

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
          SliverPadding(padding: const EdgeInsets.only(top: 10)),
          isLoading
              ? SliverToBoxAdapter(child: LinearProgressIndicator())
              : SliverList.builder(
                  itemCount: allChats.length,
                  itemBuilder: (context, index) => Card(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(index == 0 ? 20 : 0),
                        bottom: Radius.circular(
                          index == allChats.length - 1 ? 20 : 0,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  UserChat(user: allChats[index].user!),
                            ),
                          ),
                          title: Text(allChats[index].user?.name ?? ''),
                          subtitle: Text(allChats[index].lastMessage),
                          leading: CircleAvatar(
                            radius: 20,
                            backgroundImage: allChats[index].user?.image != null
                                ? NetworkImage(
                                    formattedUrl(allChats[index].user?.image ?? ''),
                                  )
                                : null,
                            child: allChats[index].user?.image == null
                                ? Text(
                                    allChats[index].user?.name?[0].toUpperCase() ??
                                        '',
                                  )
                                : null,
                          ),
                        ),
                        if (index != allChats.length - 1) ...[
                          Divider(height: 1),
                        ],
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

class ChatSummary {
  final String userId;
  final String lastMessage;
  final DateTime timestamp;
  UserModel? user;

  ChatSummary({
    required this.userId,
    required this.lastMessage,
    required this.timestamp,
    this.user,
  });
}
