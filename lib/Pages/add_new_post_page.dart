// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/Pages/root_page.dart';
import 'package:instagram_clone/Services/firebase_storage_service.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class AddNewPostPage extends StatefulWidget {
  const AddNewPostPage({super.key});

  @override
  State<AddNewPostPage> createState() => _AddNewPostPageState();
}

class _AddNewPostPageState extends State<AddNewPostPage> {
  TextEditingController postDescriptionController = TextEditingController();
  File? selectedImage;
  bool showImage = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Add a new post"),
        ),
        resizeToAvoidBottomInset: true,
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 100),
                      AdaptiveTheme.of(context).mode.isLight
                          ? Image.asset(
                              "assets/images/insta_logo.png",
                              height: 50,
                            )
                          : Image.asset(
                              "assets/images/instagram-logo-white.png",
                              height: 50,
                            ),
                      TextButton(
                        onPressed: () async {
                          final XFile? pickedImage = await ImagePicker()
                              .pickImage(source: ImageSource.gallery);
                          if (pickedImage != null) {
                            showImage = true;
                            setState(() {
                              selectedImage = File(pickedImage.path);
                            });
                          }
                        },
                        child: const Text("Pick a photo for your post"),
                      ),
                      if (showImage)
                        Image.file(
                          width: MediaQuery.of(context).size.width,
                          fit: BoxFit.contain,
                          File(selectedImage!.path),
                        ),
                      const SizedBox(height: 50),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: TextField(
                          keyboardType: TextInputType.text,
                          enabled: selectedImage != null ? true : false,
                          controller: postDescriptionController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AdaptiveTheme.of(context).mode.isDark
                                ? const Color(0xff2A2A2A)
                                : Colors.grey[200],
                            hintText: "Write a description for your post",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 20),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.90,
                  child: MaterialButton(
                    color: Colors.blue,
                    onPressed: _isLoading
                        ? null
                        : () async {
                            if (selectedImage != null) {
                              setState(() {
                                _isLoading = true;
                              });
                              try {
                                await FirebaseStorageService().savePost(
                                  selectedImage!,
                                  postDescriptionController.text,
                                );
                                Navigator.of(context)
                                    .pushReplacement(MaterialPageRoute(
                                  builder: (context) => const RootPage(),
                                ));
                              } catch (error) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: Colors.red,
                                    content: Text('Error sending post: $error'),
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
                                  content: Text('Choose a photo to send!'),
                                ),
                              );
                            }
                          },
                    child: _isLoading
                        ? LoadingAnimationWidget.waveDots(
                            color: Colors.blueGrey,
                            size: 20,
                          )
                        : const Text("Send post"),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
