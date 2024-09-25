import 'package:cloud_firestore/cloud_firestore.dart';

class FireStoreServices {
  Future<void> saveUserData(String uid, Map<String, dynamic> data) async {
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .set(data, SetOptions(merge: true));
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<void> follow(String currentUserId, String targetUserId) async {
    try {
      final currentUserRef =
          FirebaseFirestore.instance.collection("users").doc(currentUserId);
      final targetUserRef =
          FirebaseFirestore.instance.collection("users").doc(targetUserId);

      final relationshipId =
          targetUserId; // Use targetUserId as relationship ID

      final followingRef =
          currentUserRef.collection("following").doc(relationshipId);
      final followersRef =
          targetUserRef.collection("followers").doc(currentUserId);

      final followingDoc = await followingRef.get();

      if (!followingDoc.exists) {
        // Increase following count for current user
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          final currentUserDoc = await transaction.get(currentUserRef);
          final currentFollowing = currentUserDoc.data()?['following'] ?? 0;
          transaction
              .update(currentUserRef, {'following': currentFollowing + 1});
        });

        // Increase follower count for target user
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          final targetUserDoc = await transaction.get(targetUserRef);
          final currentFollowers = targetUserDoc.data()?['followers'] ?? 0;
          transaction
              .update(targetUserRef, {'followers': currentFollowers + 1});
        });

        // Create documents in subcollections to represent the relationship
        await followingRef
            .set({'userId': targetUserId}, SetOptions(merge: true));
        await followersRef
            .set({'userId': currentUserId}, SetOptions(merge: true));
      }
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<void> unfollow(String currentUserId, String targetUserId) async {
    try {
      final currentUserRef =
          FirebaseFirestore.instance.collection("users").doc(currentUserId);
      final targetUserRef =
          FirebaseFirestore.instance.collection("users").doc(targetUserId);

      // Delete the relationship document (using targetUserId as ID)
      await currentUserRef.collection("following").doc(targetUserId).delete();
      await currentUserRef.collection("followers").doc(targetUserId).delete();
      await targetUserRef.collection("following").doc(currentUserId).delete();
      await targetUserRef.collection('followers').doc(currentUserId).delete();

      // Decrease following count for current user
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final currentUserDoc = await transaction.get(currentUserRef);
        final currentFollowers = currentUserDoc.data()?['followers'] ?? 1;
        if (currentFollowers > 0) {
          transaction
              .update(currentUserRef, {'followers': currentFollowers - 1});
        }
        final currentFollowing = currentUserDoc.data()?['following'] ?? 1;
        if (currentFollowing > 0) {
          transaction
              .update(currentUserRef, {'following': currentFollowing - 1});
        }
      });

      // Decrease follower count for target user
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final targetUserDoc = await transaction.get(targetUserRef);
        final currentFollowers = targetUserDoc.data()?['followers'] ?? 1;
        transaction.update(targetUserRef, {'followers': currentFollowers - 1});
        final currentFollowing = targetUserDoc.data()?['following'] ?? 1;
        if (currentFollowing > 0) {
          transaction
              .update(targetUserRef, {'following': currentFollowing - 1});
        }
      });
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<bool> isFollowing(String currentUserId, String targetUserId) async {
    try {
      final followingRef = FirebaseFirestore.instance
          .collection("users")
          .doc(currentUserId)
          .collection("following")
          .doc(targetUserId);
      final followingDoc = await followingRef.get();
      return followingDoc.exists;
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<void> likePost(
      String currentUserName, String username, String postId) async {
    try {
      final postRef = FirebaseFirestore.instance
          .collection('posts')
          .doc(username)
          .collection('posts')
          .doc(postId);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final postDoc = await transaction.get(postRef);
        final currentLikes = postDoc.data()?['likes'] ?? 0;
        transaction.update(postRef, {
          'likes': currentLikes + 1,
          'likedBy': FieldValue.arrayUnion([currentUserName])
        });
      });
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<void> unlikePost(
      String currentUserName, String username, String postId) async {
    try {
      final postRef = FirebaseFirestore.instance
          .collection('posts')
          .doc(username)
          .collection('posts')
          .doc(postId);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final postDoc = await transaction.get(postRef);
        final currentLikes = postDoc.data()?['likes'] ?? 1;
        transaction.update(postRef, {
          'likes': currentLikes - 1,
          'likedBy': FieldValue.arrayRemove([currentUserName])
        });
      });
    } catch (error) {
      throw Exception(error);
    }
  }
}
