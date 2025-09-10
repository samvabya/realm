class ChatModel {
  final String id;
  final String text;
  final String time;
  final bool isSentByMe;
  final MessageType type;
  final String? imageUrl;
  final bool isRead;
  final String senderId;
  final String receiverId;
  final DateTime createdAt;

  ChatModel({
    required this.id,
    required this.text,
    required this.time,
    required this.isSentByMe,
    this.type = MessageType.text,
    this.imageUrl,
    this.isRead = false,
    required this.senderId,
    required this.receiverId,
    required this.createdAt,
  });

  factory ChatModel.fromMap(Map<String, dynamic> map, String currentUserId) {
    final DateTime createdAt = DateTime.parse(map['created_at']);

    return ChatModel(
      id: map['id'] ?? '',
      text: map['message'] ?? '',
      time: formatTime(createdAt),
      isSentByMe: map['sender_id'] == currentUserId,
      type: MessageType.text,
      isRead: map['is_read'] ?? false,
      senderId: map['sender_id'] ?? '',
      receiverId: map['receiver_id'] ?? '',
      createdAt: createdAt,
    );
  }

  static String formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

enum MessageType { text, image, audio }
