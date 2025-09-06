import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:realm/components/signin_modal.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.network(
          'https://plus.unsplash.com/premium_vector-1713965460192-d1e3c8382029?q=80&w=750&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.cover,
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
          body: Column(
            children: [
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text.rich(
                      textAlign: TextAlign.center,
                      textScaler: TextScaler.linear(1.5),
                      style: GoogleFonts.montserrat(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFF2a2a2a),
                        shadows: [
                          Shadow(
                            color: Color(0xFFed997d),
                            offset: Offset(3, 3),
                          ),
                        ],
                      ),
                      TextSpan(
                        children: [
                          TextSpan(text: "Experience the "),
                          TextSpan(
                            text: "Allrounder ",
                            style: TextStyle(color: Color(0xFF4B0082)),
                          ),
                          TextSpan(text: "Social App! "),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                color: Theme.of(
                  context,
                ).colorScheme.onPrimary.withValues(alpha: 0.3),
                height: MediaQuery.of(context).size.height * 0.3,
                child: Center(
                  child: FilledButton.icon(
                    onPressed: () => showModalBottomSheet(
                      isScrollControlled: true,
                      showDragHandle: true,
                      
                      context: context,
                      builder: (context) => const SigninModal(),
                    ),
                    label: const Text('Sign In with Email'),
                    icon: FaIcon(FontAwesomeIcons.google, size: 30),
                    style: FilledButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 30,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
