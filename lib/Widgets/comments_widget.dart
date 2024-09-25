import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CommentWidget extends StatelessWidget {
  final String profileImageUrl;
  final String username;
  final String comment;

  const CommentWidget({
    super.key,
    required this.profileImageUrl,
    required this.username,
    required this.comment,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: CachedNetworkImageProvider(profileImageUrl),
      ),
      title: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$username ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: comment),
          ],
        ),
      ),
    );
  }
}
