import 'package:flutter/material.dart';
import 'package:matrix_gesture_detector_pro/matrix_gesture_detector_pro.dart';
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

String formattedUrl(String url) {
  return 'https://dzndxdypnvjafxmindwj.supabase.co/storage/v1/object/public/uploads/$url';
}

class MatrixGD extends StatelessWidget {
  final Widget child;
  const MatrixGD({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<Matrix4> notifier = ValueNotifier(Matrix4.identity());
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: MatrixGestureDetector(
        onMatrixUpdate: (m, tm, sm, rm) {
          notifier.value = m;
        },
        child: AnimatedBuilder(
          animation: notifier,
          builder: (ctx, buildChild) {
            return Transform(
              transform: notifier.value,
              child: Container(
                  padding: EdgeInsets.all(32),
                  alignment: Alignment(0, 0),
                  child: child),
            );
          },
        ),
      ),
    );
  }
}
