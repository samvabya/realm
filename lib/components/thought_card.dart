import 'package:flutter/material.dart';
import 'package:hashtagable_v3/widgets/hashtag_text.dart';
import 'package:realm/model/thought.dart';
import 'package:realm/screens/thought_details.dart';
import 'package:realm/util.dart';

class ThoughtCard extends StatelessWidget {
  final ThoughtModel thought;
  final bool clickDisabled;
  const ThoughtCard({
    super.key,
    required this.thought,
    this.clickDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: clickDisabled
          ? null
          : () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ThoughtDetails(thought: thought),
              ),
            ),
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundImage: thought.user?.image != null
                    ? NetworkImage(formattedUrl(thought.user?.image ?? ''))
                    : null,
              ),
              title: Text(thought.user?.name ?? ''),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: HashTagText(
                text: thought.body ?? '',
                basicStyle: Theme.of(context).textTheme.bodyLarge!,
                decoratedStyle: Theme.of(
                  context,
                ).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
                onTap: (text) {
                  showSnack(text, context);
                },
              ),
            ),
            Divider(),
          ],
        ),
      ),
    );
  }
}
