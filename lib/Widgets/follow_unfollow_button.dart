import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/Provider/firebase_provider.dart';

class FollowUnfollowButton extends StatefulWidget {
  final String currentUserId;
  final String targetUserId;
  final FirebaseProvider firebaseProvider;

  const FollowUnfollowButton({
    super.key,
    required this.currentUserId,
    required this.targetUserId,
    required this.firebaseProvider,
  });

  @override
  State<FollowUnfollowButton> createState() => _FollowUnfollowButtonState();
}

class _FollowUnfollowButtonState extends State<FollowUnfollowButton> {
  final currentUser = FirebaseAuth.instance.currentUser;
  bool _isFollowing = false;

  @override
  void initState() {
    super.initState();
    _checkFollowingStatus();
  }

  Future<void> _checkFollowingStatus() async {
    bool isFollowing = await widget.firebaseProvider.fireStore!
        .isFollowing(widget.currentUserId, widget.targetUserId);
    setState(() {
      _isFollowing = isFollowing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.90,
        child: MaterialButton(
          elevation: 0,
          color: _isFollowing ? Colors.red : Colors.blue,
          onPressed: () async {
            if (_isFollowing) {
              await widget.firebaseProvider.fireStore!
                  .unfollow(widget.currentUserId, widget.targetUserId);
            } else {
              await widget.firebaseProvider.fireStore!
                  .follow(widget.currentUserId, widget.targetUserId);
              widget.firebaseProvider.addFollowNotification(
                  currentUser!.displayName!, widget.targetUserId);
            }
            _checkFollowingStatus();
          },
          child: Text(
            _isFollowing ? "Unfollow" : "Follow",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
