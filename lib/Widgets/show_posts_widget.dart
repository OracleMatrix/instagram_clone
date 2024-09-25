import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/Pages/others_profile_page.dart';
import 'package:instagram_clone/Provider/firebase_provider.dart';
import 'package:instagram_clone/Widgets/comments_sheet_widget.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class ShowPostsWidget extends StatefulWidget {
  final DocumentReference<Map<String, dynamic>> postRef;
  final Map<String, dynamic> userData;

  const ShowPostsWidget(
      {super.key, required this.postRef, required this.userData});

  @override
  State<ShowPostsWidget> createState() => _ShowPostsWidgetState();
}

class _ShowPostsWidgetState extends State<ShowPostsWidget> {
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final firebaseProvider = Provider.of<FirebaseProvider>(context);
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: widget.postRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox.shrink();
          }
          if (snapshot.hasError) {
            return const SizedBox.shrink();
          }
          final postData = snapshot.data!.data()!;
          final isLiked = (postData['likedBy'] as List?)
                  ?.contains(currentUser!.displayName!) ??
              false;
          return Column(
            children: [
              Card(
                elevation: 0,
                color: Colors.transparent,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OthersProfilePage(
                                targetUserID: widget.userData['uid'],
                                displayName: widget.userData['username']),
                          )),
                      leading: CircleAvatar(
                        backgroundImage: CachedNetworkImageProvider(
                          widget.userData['profileImageUrl'],
                        ),
                      ),
                      title: Text(widget.userData['username']),
                    ),
                    CachedNetworkImage(
                      width: MediaQuery.sizeOf(context).width,
                      fit: BoxFit.contain,
                      imageUrl: postData['postURL'],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  if (isLiked) {
                                    firebaseProvider.fireStore!.unlikePost(
                                      currentUser!.displayName!,
                                      widget.userData['username'],
                                      snapshot.data!.id,
                                    );
                                  } else {
                                    firebaseProvider.fireStore!.likePost(
                                      currentUser!.displayName!,
                                      widget.userData['username'],
                                      snapshot.data!.id,
                                    );
                                    firebaseProvider.addLikeNotification(
                                      currentUser!.displayName!,
                                      widget.userData['username'],
                                      widget.postRef.id,
                                    );
                                  }
                                },
                                child: Icon(
                                  isLiked
                                      ? CupertinoIcons.heart_fill
                                      : CupertinoIcons.heart,
                                  color: isLiked ? Colors.red : null,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(postData['likes'].toString()),
                              const SizedBox(width: 20),
                              GestureDetector(
                                  onTap: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      builder: (context) => CommentSheet(
                                        postRef: widget.postRef,
                                        postOwnerUsername:
                                            widget.userData['username'],
                                      ),
                                    );
                                  },
                                  child:
                                      const Icon(Icons.mode_comment_outlined)),
                              const SizedBox(width: 5),
                              Text(postData['comments'].toString()),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(postData['Post Description'] ?? ""),
                          const SizedBox(height: 5),
                          GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (context) => CommentSheet(
                                  postRef: widget.postRef,
                                  postOwnerUsername:
                                      widget.userData['username'],
                                ),
                              );
                            },
                            child: const Text(
                              'View all comments',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                          const SizedBox(height: 5),
                          _formatTime(postData['createdAt']),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        });
  }

  Widget _formatTime(Timestamp timestamp) {
    final postDate = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(postDate);

    if (difference.inDays > 7) {
      final formattedDate =
          "${postDate.year}-${postDate.month.toString().padLeft(2, '0')}-${postDate.day.toString().padLeft(2, '0')} ${postDate.hour.toString().padLeft(2, '0')}:${postDate.minute.toString().padLeft(2, '0')}";
      return Text(
        formattedDate,
        style: const TextStyle(color: Colors.grey),
      );
    } else {
      final timeDifference = timeago.format(postDate);
      return Text(
        timeDifference,
        style: const TextStyle(color: Colors.grey),
      );
    }
  }
}
