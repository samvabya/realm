import 'package:flutter/material.dart';
import 'package:realm/main.dart';

class SigninModal extends StatefulWidget {
  const SigninModal({super.key});

  @override
  State<SigninModal> createState() => _SigninModalState();
}

class _SigninModalState extends State<SigninModal> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          spacing: 30,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(30),
                      ),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    hintText: 'Email',
                  ),
                ),
                Divider(height: 1),
                TextField(
                  controller: passwordController,
                  keyboardType: TextInputType.visiblePassword,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(30),
                      ),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    hintText: 'Password',
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              spacing: 10,
              children: [
                TextButton(
                  onPressed: () async {
                    try {
                      await supabase.auth.signUp(
                        password: passwordController.text,
                        email: emailController.text,
                      );
                      Navigator.pop(context);
                    } catch (e) {
                      setState(() => errorMessage = e.toString());
                    }
                  },
                  child: const Text('Sign Up'),
                ),
                FilledButton(
                  onPressed: () async {
                    try {
                      await supabase.auth.signInWithPassword(
                        password: passwordController.text,
                        email: emailController.text,
                      );
                      Navigator.pop(context);
                    } catch (e) {
                      setState(() => errorMessage = e.toString());
                    }
                  },
                  child: const Text('Sign In'),
                ),
              ],
            ),
            Text(
              textAlign: TextAlign.center,
              errorMessage,
              style: Theme.of(context).textTheme.labelSmall!.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
