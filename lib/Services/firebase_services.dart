import 'package:firebase_auth/firebase_auth.dart';

class FirebaseServices {
  Future<User?> signUpUser(String email, String password) async {
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      return credential.user;
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<User?> loginUser(String email, String password) async {
    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      return credential.user;
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<void> logOutUser() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<void> sendResetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } catch (error) {
      throw Exception(error);
    }
  }
}
