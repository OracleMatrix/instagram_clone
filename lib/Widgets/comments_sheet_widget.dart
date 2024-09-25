import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/Provider/firebase_provider.dart';
import 'package:instagram_clone/Widgets/comments_widget.dart';
import 'package:provider/provider.dart';

class CommentSheet extends StatefulWidget {
  final DocumentReference<Map<String, dynamic>> postRef;
  final String postOwnerUsername;

  const CommentSheet({
    super.key,
    required this.postRef,
    required this.postOwnerUsername,
  });

  @override
  State<CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<CommentSheet> {
  final TextEditingController _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final firebaseProvider = Provider.of<FirebaseProvider>(context);
    final currentUser = FirebaseAuth.instance.currentUser;

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.2,
      maxChildSize: 0.8,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: widget.postRef.collection('comments').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text('Error loading comments'));
                  }
                  final comments = snapshot.data!.docs;
                  if (comments.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.comments_disabled,
                            size: 70,
                            color: Colors.grey,
                          ),
                          Text(
                            'No comments yet.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return ListView.builder(
                      controller: scrollController,
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final commentData = comments[index].data();
                        return CommentWidget(
                          profileImageUrl: commentData['profileImageUrl'],
                          username: commentData['username'],
                          comment: commentData['comment'],
                        );
                      },
                    );
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: const InputDecoration(
                        hintText: 'Add a comment...',
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      if (_commentController.text.isNotEmpty) {
                        firebaseProvider.addComment(
                          widget.postRef,
                          currentUser!.displayName!,
                          currentUser.photoURL!,
                          _commentController.text,
                          widget.postOwnerUsername,
                        );
                        _commentController.clear();
                        firebaseProvider.addCommentNotification(
                          currentUser.displayName!,
                          widget.postOwnerUsername,
                          widget.postRef.id,
                          _commentController.text,
                        );
                      }
                    },
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
