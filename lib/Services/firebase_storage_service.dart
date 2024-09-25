import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart';

class FirebaseStorageService {
  final currentUser = FirebaseAuth.instance.currentUser;

  Future<void> saveProfileImage(File image) async {
    try {
      String fileName = basename(image.path);
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('profile_images/user: ${currentUser!.uid}/$fileName');
      await ref.putFile(image);

      String downloadURL = await ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .update({'profileImageUrl': downloadURL});

      await currentUser!.updatePhotoURL(downloadURL);
    } catch (e) {
      throw Exception('Error uploading image: $e');
    }
  }

  Future<void> savePost(File image, String? description) async {
    try {
      String fileName = basename(image.path);
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('posts/user: ${currentUser!.displayName}/$fileName');
      await ref.putFile(image);
      String downloadURL = await ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection("posts")
          .doc('${currentUser!.displayName}')
          .collection('posts')
          .add(
        {
          'postURL': downloadURL,
          'Post Description': description,
          'owner': currentUser!.displayName,
          'createdAt': DateTime.now(),
          'sender ID': currentUser!.uid,
          'likes': 0,
          'comments': 0,
          'shares': 0,
        },
      );
    } catch (error) {
      throw Exception(error);
    }
  }
}
