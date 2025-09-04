import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SigninScreen extends StatelessWidget {
  const SigninScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: FilledButton.icon(
        onPressed: () {},
        label: const Text('Sign In'),
        icon: FaIcon(FontAwesomeIcons.google),
      ),
    ));
  }
}
