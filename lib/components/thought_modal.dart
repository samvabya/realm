import 'package:flutter/material.dart';
import 'package:hashtagable_v3/widgets/hashtag_text_field.dart';
import 'package:realm/main.dart';

class ThoughtModal extends StatefulWidget {
  const ThoughtModal({super.key});

  @override
  State<ThoughtModal> createState() => _ThoughtModalState();
}

class _ThoughtModalState extends State<ThoughtModal> {
  bool isLoading = false;
  TextEditingController textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            HashTagTextField(
              controller: textController,
              maxLines: 8,
              decoratedStyle: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                hintText: 'What\'s on your mind?',
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton.tonal(
                onPressed: isLoading
                    ? null
                    : () async {
                        setState(() => isLoading = true);

                        try {
                          await supabase.from('thoughts').insert({
                            "body": textController.text,
                            "userId": supabase.auth.currentUser?.id,
                          });
                          setState(() => isLoading = false);
                          Navigator.pop(context);
                        } on Exception catch (e) {
                          debugPrint(e.toString());
                          setState(() => isLoading = false);
                        }
                      },
                child: const Text('Share'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
