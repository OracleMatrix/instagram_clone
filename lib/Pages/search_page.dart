// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/Pages/others_profile_page.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String _searchTerm = '';

  Future<QuerySnapshot<Map<String, dynamic>>> _searchUsers(
      String searchTerm) async {
    if (searchTerm.isEmpty) {
      return FirebaseFirestore.instance
          .collection('users')
          .where("username", isEqualTo: "")
          .get();
    } else {
      return FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: searchTerm.toLowerCase())
          .get();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: SearchBar(
                keyboardType: TextInputType.emailAddress,
                hintText: "Search users...",
                elevation: const WidgetStatePropertyAll(0),
                leading: const Icon(Icons.search),
                onChanged: (value) {
                  setState(() {
                    _searchTerm = value.toLowerCase();
                  });
                },
              ),
            ),
            const Divider(),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                future: _searchUsers(_searchTerm),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Icon(
                        Icons.error_outline,
                        size: 50,
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: LoadingAnimationWidget.horizontalRotatingDots(
                        color: Colors.blueGrey,
                        size: 50,
                      ),
                    );
                  }

                  List<QueryDocumentSnapshot<Map<String, dynamic>>> users =
                      snapshot.data!.docs;
                  if (users.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.search_off, size: 70),
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                            child: Text(
                              _searchTerm.isEmpty
                                  ? 'Search for users by username'
                                  : 'No users found matching "$_searchTerm"',
                              style: const TextStyle(fontSize: 16),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return ListView.separated(
                      separatorBuilder: (context, index) => const Divider(),
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final userDoc = users[index];
                        final userData = userDoc.data();

                        return ListTile(
                          onTap: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OthersProfilePage(
                                  targetUserID: userData['uid'],
                                  displayName: userData['username'],
                                ),
                              ),
                            );
                          },
                          leading: CircleAvatar(
                            backgroundImage: userData['profileImageUrl'] != null
                                ? CachedNetworkImageProvider(
                                    userData['profileImageUrl'],
                                  )
                                : const AssetImage(
                                    "assets/images/profile_pic.jpg",
                                  ),
                          ),
                          title: Text(
                            userData['username'],
                          ),
                          subtitle: Text(userData['email']),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}