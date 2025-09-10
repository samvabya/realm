import 'package:flutter/material.dart';
import 'package:hashtagable_v3/widgets/hashtag_text_field.dart';
import 'package:realm/components/message_bubble.dart';
import 'package:realm/model/chat.dart';
import 'package:realm/model/user.dart';
import 'package:realm/screens/profile_screen.dart';
import 'package:realm/services/supabase_service.dart';
import 'package:realm/util.dart';

class UserChat extends StatefulWidget {
  final UserModel user;
  const UserChat({super.key, required this.user});

  @override
  State<UserChat> createState() => _UserChatState();
}

class _UserChatState extends State<UserChat> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<ChatModel> _messages = [];
  bool _isSending = false;
  Stream<List<ChatModel>>? _messagesStream;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _markMessagesAsRead();
    _setupMessagesStream();
  }

  Future<void> _loadMessages() async {
    setState(() {});

    try {
      final messages = await SupabaseService.getChatMessages(widget.user.id!);
      setState(() {
        _messages = messages;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {});
      _showErrorSnackBar('Failed to load messages');
    }
  }

  void _setupMessagesStream() {
    _messagesStream = SupabaseService.listenToMessages(widget.user.id!);
    _messagesStream?.listen((messages) {
      setState(() {
        _messages = messages;
      });
      _scrollToBottom();
      _markMessagesAsRead();
    });
  }

  Future<void> _markMessagesAsRead() async {
    await SupabaseService.markMessagesAsRead(widget.user.id!);
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() {
      _isSending = true;
    });

    try {
      await SupabaseService.sendMessage(
        receiverId: widget.user.id!,
        message: text,
      );

      _messageController.clear();
    } catch (e) {
      _showErrorSnackBar('Failed to send message');
    } finally {
      setState(() {
        _isSending = false;
      });
      _loadMessages();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ListTile(
          title: Text(widget.user.name ?? 'Realm User'),
          leading: GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileScreen(uid: widget.user.id),
              ),
            ),
            child: CircleAvatar(
              radius: 18,
              backgroundImage: widget.user.image != null
                  ? NetworkImage(formattedUrl(widget.user.image ?? ''))
                  : null,
              child: widget.user.image == null
                  ? Text(widget.user.name?[0].toUpperCase() ?? '')
                  : null,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty ? _buildEmptyChat() : _buildMessagesList(),
          ),
          BottomAppBar(
            child: Row(
              children: [
                Expanded(
                  child: HashTagTextField(
                    controller: _messageController,
                    decoratedStyle: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      hintText: 'Message',
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  onPressed: _isSending ? null : _sendMessage,
                  icon: Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return StreamBuilder<List<ChatModel>>(
      stream: _messagesStream,
      initialData: _messages,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final messages = snapshot.data ?? _messages;

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            final showDate =
                index == 0 ||
                !_isSameDay(
                  messages[index].createdAt,
                  messages[index - 1].createdAt,
                );

            return Column(
              children: [
                if (showDate) _buildDateSeparator(message.createdAt),
                MessageBubble(
                  message: message,
                  onDelete: () async {
                    await SupabaseService.deleteMessage(message.id);
                    _loadMessages();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDateSeparator(DateTime date) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: Divider(color: Theme.of(context).dividerColor)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _formatDate(date),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
            ),
          ),
          Expanded(child: Divider(color: Theme.of(context).dividerColor)),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final dateToCheck = DateTime(date.year, date.month, date.day);

    if (dateToCheck == today) {
      return 'Today';
    } else if (dateToCheck == yesterday) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Widget _buildEmptyChat() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.message,
              size: 60,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Messages Yet',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Start a conversation with ${widget.user.name}',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
