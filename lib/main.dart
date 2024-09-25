// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instagram_clone/Pages/login_page.dart';
import 'package:instagram_clone/Pages/root_page.dart';
import 'package:instagram_clone/Provider/firebase_provider.dart';
import 'package:instagram_clone/firebase_options.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(
    ChangeNotifierProvider(
      create: (context) => FirebaseProvider(),
      builder: (context, child) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      dark: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        textTheme:
            GoogleFonts.poppinsTextTheme().apply(bodyColor: Colors.white),
      ),
      initial: AdaptiveThemeMode.dark,
      builder: (light, dark) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Instagram Clone',
        theme: light,
        darkTheme: dark,
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              Timer.periodic(
                const Duration(minutes: 5),
                (timer) async {
                  try {
                    await FirebaseAuth.instance.currentUser?.reload();
                    if (FirebaseAuth.instance.currentUser == null) {
                      FirebaseAuth.instance
                          .signOut()
                          .then((value) => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const LoginSignupScreen())))
                          .catchError((error) =>
                              throw Exception("Failed to delete user: $error"));
                    }
                  } catch (e) {
                    throw Exception(e);
                  }
                },
              );
              return const RootPage();
            } else {
              return const LoginSignupScreen();
            }
          },
        ),
      ),
    );
  }
}
