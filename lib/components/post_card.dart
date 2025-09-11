import 'package:flutter/material.dart';
import 'package:realm/model/post.dart';
import 'package:realm/util.dart';

class PostCard extends StatelessWidget {
  final PostModel post;
  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: post.user?.image != null
                  ? NetworkImage(formattedUrl(post.user?.image ?? ''))
                  : null,
              child: post.user?.image == null
                  ? Text(post.user?.name?[0].toUpperCase() ?? '')
                  : null,
            ),
            title: Text(post.user?.name ?? ''),
          ),
          if (post.file != null)
            AspectRatio(
              aspectRatio: 4 / 3,
              child: Image.network(formattedUrl(post.file!)),
            ),
          if (post.body != null && post.body != '')
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                post.body ?? '',
                style: post.file != null
                    ? Theme.of(context).textTheme.bodyLarge
                    : Theme.of(context).textTheme.headlineMedium,
              ),
            ),
        ],
      ),
    );
  }
}
