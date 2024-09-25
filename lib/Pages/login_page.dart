// ignore_for_file: use_build_context_synchronously, valid_regexps

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/Pages/root_page.dart';
import 'package:instagram_clone/Provider/firebase_provider.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class LoginSignupScreen extends StatefulWidget {
  const LoginSignupScreen({super.key});

  @override
  State<LoginSignupScreen> createState() => _LoginSignupScreenState();
}

class _LoginSignupScreenState extends State<LoginSignupScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  bool isLogin = true;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final firebaseProvider = Provider.of<FirebaseProvider>(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                /*
                * instagram logo text
                * */
                Padding(
                  padding: const EdgeInsets.only(top: 70.0, bottom: 130),
                  child: AdaptiveTheme.of(context).mode.isLight
                      ? Image.asset(
                          "assets/images/insta_logo.png",
                          height: 50,
                        )
                      : Image.asset(
                          "assets/images/instagram-logo-white.png",
                          height: 50,
                        ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    /*
                    * email field
                    * */
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!EmailValidator.validate(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: isLogin ? 'Email' : 'Email address',
                          hintStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: AdaptiveTheme.of(context).mode.isDark
                              ? const Color(0xff2A2A2A)
                              : Colors.grey[200],
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    /*
                    * password field
                    * */
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextFormField(
                        controller: passwordController,
                        keyboardType: TextInputType.text,
                        obscureText: _obscurePassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 8) {
                            return 'Password must be at least 8 characters';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: 'Password',
                          hintStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: AdaptiveTheme.of(context).mode.isDark
                              ? const Color(0xff2A2A2A)
                              : Colors.grey[200],
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    if (!isLogin) const SizedBox(height: 10),
                    if (!isLogin)
                      /*
                      * username field
                      * */
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TextFormField(
                          validator: (value) {
                            if (value == null && value!.isEmpty) {
                              return "Choose a username for your profile";
                            }
                            return null;
                          },
                          controller: usernameController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            hintText: 'Username',
                            hintStyle: const TextStyle(color: Colors.grey),
                            filled: true,
                            fillColor: AdaptiveTheme.of(context).mode.isDark
                                ? const Color(0xff2A2A2A)
                                : Colors.grey[200],
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    /*
                    * login and sign up button
                    * */
                    SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : () async {
                                  if (_formKey.currentState!.validate()) {
                                    setState(() {
                                      _isLoading = true;
                                    });
                                    /*
                                    * sign up
                                    * */
                                    if (!isLogin) {
                                      try {
                                        User? user = await firebaseProvider
                                            .firebase!
                                            .signUpUser(emailController.text,
                                                passwordController.text);
                                        if (user != null) {
                                          await firebaseProvider.fireStore!
                                              .saveUserData(user.uid, {
                                            "email": emailController.text,
                                            "uid": user.uid,
                                            "username": usernameController.text.toLowerCase(),
                                            "followers": 0,
                                            "following": 0,
                                          });
                                          await user.updateDisplayName(
                                              usernameController.text);
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const RootPage(),
                                            ),
                                          );
                                        }
                                      } catch (errorOnSignUp) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            backgroundColor: Colors.red,
                                            content:
                                                Text("Email already exists"),
                                          ),
                                        );
                                      }
                                      /*
                                      * login
                                      * */
                                    } else if (isLogin) {
                                      try {
                                        User? user = await firebaseProvider
                                            .firebase!
                                            .loginUser(emailController.text,
                                                passwordController.text);
                                        if (user != null) {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const RootPage(),
                                            ),
                                          );
                                        }
                                      } catch (errorOnLoginUer) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            backgroundColor: Colors.red,
                                            content: Text(
                                                "Invalid email or password"),
                                          ),
                                        );
                                      }
                                    }
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.lightBlue,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          child: _isLoading
                              ? LoadingAnimationWidget.waveDots(
                                  color: Colors.white,
                                  size: 20,
                                )
                              : Text(
                                  isLogin ? 'Log In' : 'Sign Up',
                                  style: const TextStyle(color: Colors.white),
                                ),
                        ),
                      ),
                    ),
                    /*
                    * login and signup switch
                    * */
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          isLogin = !isLogin;
                        });
                      },
                      child: Text(
                        isLogin
                            ? "Don't have an account? Sign up."
                            : 'Already have an account? Log in.',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (isLogin)
                      /*
                      * reset password
                      * */
                      TextButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text("Reset Password"),
                                content: TextFormField(
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (!EmailValidator.validate(value!)) {
                                      return "Invalid email please enter a valid email address";
                                    }
                                    return null;
                                  },
                                  controller: emailController,
                                  decoration: const InputDecoration(
                                    hintText: "Email address",
                                    hintStyle: TextStyle(color: Colors.grey),
                                  ),
                                ),
                                actions: [
                                  /*
                                  * reset button
                                  * */
                                  TextButton(
                                      onPressed: () {
                                        if (emailController.text.isNotEmpty) {
                                          try {
                                            firebaseProvider.firebase!
                                                .sendResetPassword(
                                                    emailController.text);
                                            Navigator.of(context).pop();
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                backgroundColor: Colors.green,
                                                content: Text(
                                                    "Reset password email sent"),
                                              ),
                                            );
                                          } catch (onResetPasswordError) {
                                            throw Exception(
                                                onResetPasswordError);
                                          }
                                        } else {
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              backgroundColor: Colors.orange,
                                              content: Text(
                                                  "Enter your email to send you a reset password email!"),
                                            ),
                                          );
                                        }
                                      },
                                      child: const Text("Send Email")),
                                  TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text("Cancel")),
                                ],
                              );
                            },
                          );
                        },
                        child: const Text(
                          "Forgot password?",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
