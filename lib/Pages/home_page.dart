import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/Pages/activity_page.dart';
import 'package:instagram_clone/Widgets/show_posts_widget.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AdaptiveTheme.of(context).mode.isLight
            ? Image.asset(
                "assets/images/insta_logo.png",
                height: 50,
              )
            : Image.asset(
                "assets/images/instagram-logo-white.png",
                height: 50,
              ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ActivityScreen()),
              );
            },
            icon: const Icon(CupertinoIcons.heart),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .collection('following')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: LoadingAnimationWidget.horizontalRotatingDots(
                color: Colors.blueGrey,
                size: 50,
              ),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.downloading,
                    size: 120,
                    color: Colors.red,
                  ),
                  Text("Failed to load posts!"),
                ],
              ),
            );
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person,
                    size: 120,
                    color: Colors.blue,
                  ),
                  Text(
                    "There is no posts!\nYou are not following anyone yet!",
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView(
            children: snapshot.data!.docs.map((followingDoc) {
              final followingUserId = followingDoc.id;

              return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(followingUserId)
                    .get(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox.shrink();
                  }

                  if (userSnapshot.hasError || !userSnapshot.hasData) {
                    return const Center(child: Text("Error loading user data"));
                  }

                  final userData = userSnapshot.data!.data()!;

                  return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('posts')
                        .doc(userData['username'])
                        .collection('posts')
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                    builder: (context, postsSnapshot) {
                      if (postsSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const SizedBox.shrink();
                      }

                      if (postsSnapshot.hasError || !postsSnapshot.hasData) {
                        return const Center(child: Text("Error loading posts"));
                      }

                      if (postsSnapshot.data!.docs.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: postsSnapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          final postId = postsSnapshot.data!.docs[index].id;

                          return ShowPostsWidget(
                            postRef: FirebaseFirestore.instance
                                .collection('posts')
                                .doc(userData['username'])
                                .collection('posts')
                                .doc(postId),
                            userData: userData,
                          );
                        },
                      );
                    },
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
