import 'package:flutter/material.dart';
import 'package:realm/main.dart';
import 'package:realm/model/chat.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseClient _supabase = supabase;
  // Get chat messages between two users
  static Future<List<ChatModel>> getChatMessages(String otherUserId) async {
    try {
      final userId = _supabase.auth.currentUser!.id;

      final response = await _supabase
          .from('chats')
          .select()
          .or('sender_id.eq.$userId,receiver_id.eq.$userId')
          .or('sender_id.eq.$otherUserId,receiver_id.eq.$otherUserId')
          .order('created_at', ascending: true);

      // if (response.error != null) {
      //   throw response.error!;
      // }

      final List<dynamic> data = response;
      return data
          .where(
            (msg) =>
                (msg['sender_id'] == userId &&
                    msg['receiver_id'] == otherUserId) ||
                (msg['sender_id'] == otherUserId &&
                    msg['receiver_id'] == userId),
          )
          .map((msg) => ChatModel.fromMap(msg, userId))
          .toList();
    } catch (e) {
      debugPrint('Error getting chat messages: $e');
      return [];
    }
  }

  // Send a message
  static Future<ChatModel?> sendMessage({
    required String receiverId,
    required String message,
  }) async {
    try {
      final userId = _supabase.auth.currentUser!.id;

      final response = await _supabase.from('chats').insert({
        'sender_id': userId,
        'receiver_id': receiverId,
        'message': message,
      }).select();

      // if (response.error != null) {
      //   throw response.error!;
      // }

      final data = response[0];
      return ChatModel.fromMap(data, userId);
    } catch (e) {
      debugPrint('Error sending message: $e');
      return null;
    }
  }

  // Mark messages as read
  static Future<void> markMessagesAsRead(String senderId) async {
    try {
      final userId = _supabase.auth.currentUser!.id;

      await _supabase
          .from('chats')
          .update({'is_read': true})
          .eq('sender_id', senderId)
          .eq('receiver_id', userId)
          .eq('is_read', false);
    } catch (e) {
      debugPrint('Error marking messages as read: $e');
    }
  }

  // Listen to new messages
  static Stream<List<ChatModel>> listenToMessages(String otherUserId) {
    final userId = _supabase.auth.currentUser!.id;

    return _supabase
        .from('chats')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: true)
        .map((events) {
          return events
              .where(
                (msg) =>
                    (msg['sender_id'] == userId &&
                        msg['receiver_id'] == otherUserId) ||
                    (msg['sender_id'] == otherUserId &&
                        msg['receiver_id'] == userId),
              )
              .map((msg) => ChatModel.fromMap(msg, userId))
              .toList();
        });
  }

  static Future<void> deleteMessage(String id) async {
    try {
      await _supabase.from('chats').delete().eq('id', id);
    } catch (e) {
      debugPrint('Error deleting message: $e');
    }
  }
}
