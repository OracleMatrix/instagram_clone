// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/Provider/firebase_provider.dart';
import 'package:instagram_clone/Services/firebase_storage_service.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final currentUser = FirebaseAuth.instance.currentUser;
  TextEditingController nameController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  bool _isLoading = false;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .get();

    if (userData.exists) {
      setState(() {
        usernameController.text = userData['username'] ?? "";
        nameController.text = userData['name'] ?? "";
        bioController.text = userData['bio'] ?? "";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final firebaseProvider = Provider.of<FirebaseProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit profile'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 80,
                  backgroundImage: _selectedImage != null
                      ? FileImage(_selectedImage!)
                      : currentUser?.photoURL != null
                          ? CachedNetworkImageProvider(currentUser!.photoURL!)
                          : const AssetImage("assets/images/profile_pic.jpg")
                              as ImageProvider,
                ),
                TextButton(
                  onPressed: () async {
                    final XFile? pickedImage = await ImagePicker()
                        .pickImage(source: ImageSource.gallery);
                    if (pickedImage != null) {
                      setState(() {
                        _selectedImage = File(pickedImage.path);
                      });
                    }
                  },
                  child: const Text("Edit picture"),
                ),
                const SizedBox(height: 20),
                buildEditProfileTextFields("Name", nameController),
                buildEditProfileTextFields('username', usernameController),
                buildEditProfileTextFields("Bio", bioController),
                SizedBox(
                  height: 60,
                  width: MediaQuery.of(context).size.width * 0.90,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: MaterialButton(
                      color: Colors.blue,
                      onPressed: _isLoading
                          ? null
                          : () async {
                              if (nameController.text.isNotEmpty &&
                                  usernameController.text.isNotEmpty &&
                                  bioController.text.isNotEmpty) {
                                setState(() {
                                  _isLoading = true;
                                });
                                try {
                                  if (_selectedImage != null) {
                                    await FirebaseStorageService()
                                        .saveProfileImage(_selectedImage!);
                                  }
                                  await firebaseProvider.fireStore!
                                      .saveUserData(currentUser!.uid, {
                                    "username": usernameController.text,
                                    "name": nameController.text,
                                    "bio": bioController.text,
                                  });
                                  await currentUser!
                                      .updateDisplayName(usernameController.text);
                                  Navigator.pop(context);
                                } catch (error) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: Colors.red,
                                      content: Text(
                                          "Error on Updating profile!\n$error"),
                                    ),
                                  );
                                } finally {
                                  setState(() {
                                    _isLoading = false;
                                  });
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    backgroundColor: Colors.red,
                                    content: Text("Inputs cannot leave empty"),
                                  ),
                                );
                              }
                            },
                      child: _isLoading
                          ? LoadingAnimationWidget.waveDots(
                              color: Colors.blue,
                              size: 20,
                            )
                          : const Text(
                              "Save Changes",
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildEditProfileTextFields(
      String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: AdaptiveTheme.of(context).mode.isDark
              ? const Color(0xff2A2A2A)
              : Colors.grey[200],
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        inputFormatters: label == 'username'
            ? [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_]')),
                // Allow only letters, numbers and underscore
              ]
            : null,
      ),
    );
  }
}
