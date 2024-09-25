import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/Pages/add_new_post_page.dart';
import 'package:instagram_clone/Pages/edit_profile_page.dart';
import 'package:instagram_clone/Pages/login_page.dart';
import 'package:instagram_clone/Pages/settings_page.dart';
import 'package:instagram_clone/Pages/show_current_user_posts_info_page.dart';
import 'package:instagram_clone/Provider/firebase_provider.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final firebaseProvider = Provider.of<FirebaseProvider>(context);
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: firebaseProvider.firebaseFirestore!
            .collection("users")
            .doc(currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: LoadingAnimationWidget.horizontalRotatingDots(
                  color: Colors.blueGrey, size: 50),
            );
          }
          if (snapshot.hasError) {
            return const Center(
                child: Icon(
              Icons.error,
              size: 50,
            ));
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;
          return Column(
            children: [
              /*
                * show user name
                * */
              AppBar(
                title: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(currentUser!.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Text("...");
                      }
                      if (snapshot.hasError) {
                        return const Icon(Icons.error_outline, size: 10);
                      }
                      final username =
                          snapshot.data!.data() as Map<String, dynamic>;
                      return Text(username['username']);
                    }),
                /*
                * PopupMenuButton
                * */
                actions: [
                  IconButton(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddNewPostPage(),
                          )),
                      icon: const Icon(Icons.add_box_outlined)),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'settings') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingsPage(),
                          ),
                        );
                      } else if (value == 'logout') {
                        FirebaseAuth.instance.signOut();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginSignupScreen(),
                          ),
                        );
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'settings',
                        child: Text('Settings'),
                      ),
                      const PopupMenuItem(
                        value: 'logout',
                        child: Text('Logout'),
                      ),
                    ],
                    icon: const Icon(Icons.more_vert),
                  ),
                ],
              ),
              /*
              * Profile pic and user account info
              * */
              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: userData['profileImageUrl'] != null
                          ? CachedNetworkImageProvider(
                              userData['profileImageUrl'])
                          : const AssetImage("assets/images/profile_pic.jpg"),
                    ),
                  ),
                  const SizedBox(width: 35),
                  Column(
                    children: [
                      StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('posts')
                              .doc(currentUser!.displayName)
                              .collection('posts')
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Text("...");
                            }
                            if (snapshot.hasError) {
                              return const Icon(Icons.error_outline, size: 10);
                            }
                            return Text(snapshot.data!.docs.length.toString());
                          }),
                      const Text("Posts"),
                    ],
                  ),
                  const SizedBox(width: 35),
                  Column(
                    children: [
                      Text(userData['followers'].toString()),
                      const Text("followers"),
                    ],
                  ),
                  const SizedBox(width: 35),
                  Column(
                    children: <Widget>[
                      Text(userData['following'].toString()),
                      const Text("following"),
                    ],
                  ),
                ],
              ),
              /*
              * bio
              * */
              const SizedBox(height: 5),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userData['name'] ?? "",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(userData['bio'] ?? "",
                            maxLines: 4, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.90,
                      child: MaterialButton(
                        elevation: 0,
                        color: AdaptiveTheme.of(context).mode.isDark
                            ? const Color(0xff2A2A2A)
                            : Colors.grey.shade300,
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EditProfilePage(),
                            )),
                        child: const Text(
                          "Edit profile",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  )
                ],
              ),
              /*
                * show user's posts
                * */
              const SizedBox(height: 20),
              const Icon(Icons.grid_view_sharp, size: 30),
              const Text('Posts'),
              const Divider(),
              /*
              * StreamBuilder getting posts
              * */
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('posts')
                      .doc(currentUser!.displayName)
                      .collection('posts')
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: LoadingAnimationWidget.horizontalRotatingDots(
                            color: Colors.blueGrey, size: 50),
                      );
                    }

                    if (snapshot.hasError) {
                      return const Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 60),
                            Text("Failed to load your posts!"),
                          ],
                        ),
                      );
                    }

                    // if (snapshot.hasData) {
                    //   return const Center(
                    //     child: Column(
                    //       crossAxisAlignment: CrossAxisAlignment.center,
                    //       children: [
                    //         SizedBox(height: 100),
                    //         Icon(Icons.post_add_rounded, size: 60, color: Colors.grey,),
                    //         SizedBox(height: 10),
                    //         Text("You have no post!"),
                    //       ],
                    //     ),
                    //   );
                    // }

                    final posts = snapshot.data?.docs;
                    /*
                    * GridView posts
                    * */
                    return GridView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3),
                      itemCount: posts?.length,
                      itemBuilder: (context, index) {
                        final postData =
                            posts?[index].data() as Map<String, dynamic>;
                        return GestureDetector(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ShowCurrentUserPostsInfoPage(
                                  postRef: FirebaseFirestore.instance
                                      .collection('posts')
                                      .doc(currentUser!.displayName)
                                      .collection('posts')
                                      .doc(posts![index].id),
                                  userData: userData,
                                ),
                              )),
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 1.0),
                            child: CachedNetworkImage(
                              errorWidget: (context, url, error) => const Icon(
                                Icons.error_outline,
                                color: Colors.grey,
                              ),
                              progressIndicatorBuilder:
                                  (context, url, progress) {
                                return Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.grey,
                                    value: progress.progress,
                                  ),
                                );
                              },
                              imageUrl: postData['postURL'],
                              fit: BoxFit.contain,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
