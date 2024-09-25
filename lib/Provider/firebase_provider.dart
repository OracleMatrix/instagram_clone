import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/Services/firebase_firestore_service.dart';
import 'package:instagram_clone/Services/firebase_services.dart';

class FirebaseProvider extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseServices _firebaseServices = FirebaseServices();
  final FireStoreServices _fireStoreServices = FireStoreServices();

  FireStoreServices? get fireStore => _fireStoreServices;

  FirebaseServices? get firebase => _firebaseServices;

  FirebaseAuth? get auth => _firebaseAuth;

  FirebaseFirestore? get firebaseFirestore => _firestore;

  Future<String> getUserIdByUsername(String username) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .get();
    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.id;
    } else {
      return '';
    }
  }

  Future<void> addComment(
      DocumentReference<Map<String, dynamic>> postRef,
      String username,
      String profileImageUrl,
      String comment,
      String postOwnerUsername) async {
    try {
      await postRef.collection('comments').add({
        'username': username,
        'profileImageUrl': profileImageUrl,
        'comment': comment,
        'createdAt': Timestamp.now(),
      });
      await postRef.update({'comments': FieldValue.increment(1)});
      // Optional: Send a notification to the post owner
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<void> addFollowNotification(
      String currentUserName, String targetUserID) async {
    try {
      final targetUserDoc = await FirebaseFirestore.instance
          .collection('users')
          .where('uid', isEqualTo: targetUserID)
          .get();
      if (targetUserDoc.docs.isNotEmpty) {
        final targetUserId = targetUserDoc.docs.first.id;
        await FirebaseFirestore.instance
            .collection('users')
            .doc(targetUserId)
            .collection('notifications')
            .add({
          'type': 'follow',
          'from': currentUserName,
          'profileImageUrl': auth!.currentUser!.photoURL,
          'message': '$currentUserName started following you.',
          'timestamp': Timestamp.now(),
        });
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> addLikeNotification(
      String currentUserName, String postOwner, String postId) async {
    try {
      if (currentUserName != postOwner) {
        final postOwnerDoc = await FirebaseFirestore.instance
            .collection('users')
            .where('username', isEqualTo: postOwner)
            .get();
        if (postOwnerDoc.docs.isNotEmpty) {
          final postOwnerId = postOwnerDoc.docs.first.id;
          await FirebaseFirestore.instance
              .collection('users')
              .doc(postOwnerId)
              .collection('notifications')
              .add({
            'type': 'like',
            'from': currentUserName,
            'profileImageUrl': auth!.currentUser!.photoURL,
            'postId': postId,
            'message': '$currentUserName liked your post.',
            'timestamp': Timestamp.now(),
          });
        }
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> addCommentNotification(String currentUserName, String postOwner,
      String postId, String comment) async {
    try {
      if (currentUserName != postOwner) {
        final postOwnerDoc = await FirebaseFirestore.instance
            .collection('users')
            .where('username', isEqualTo: postOwner)
            .get();
        if (postOwnerDoc.docs.isNotEmpty) {
          final postOwnerId = postOwnerDoc.docs.first.id;
          await FirebaseFirestore.instance
              .collection('users')
              .doc(postOwnerId)
              .collection('notifications')
              .add({
            'type': 'comment',
            'from': currentUserName,
            'profileImageUrl': auth!.currentUser!.photoURL,
            'postId': postId,
            'message': '$currentUserName commented: $comment',
            'timestamp': Timestamp.now(),
          });
        }
      }
    } catch (e) {
      throw Exception(e);
    }
  }
}
