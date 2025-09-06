import 'package:flutter/material.dart';
import 'package:realm/main.dart';

void showSnack(String message, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
  );
}

String getUsernameByEmail(String? email) {
  return email?.split('@')[0] ?? '';
}

String getMyUsername() {
  return supabase.auth.currentUser?.email?.split('@')[0] ?? '';
}

String getMyUsername3letters() {
  final email = supabase.auth.currentUser?.email ?? '';
  return email[0].toUpperCase() + email.substring(1, 3);
}
