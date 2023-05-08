import 'package:chatme/helper/helper_funtion.dart';
import 'package:chatme/service/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  /// method for  Login in
  Future loginwithEmailandPassword(String email, String password) async {
    try {
      User? user = (await _firebaseAuth.signInWithEmailAndPassword(
              email: email, password: password))
          .user;

      if (user != null) {
        ///call our database service to update the user data.

        return true;
      }
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  /// method for register
  Future registerUserwithEmailandPassword(
      String fullname, String email, String password) async {
    try {
      User? user = (await _firebaseAuth.createUserWithEmailAndPassword(
              email: email, password: password))
          .user;

      if (user != null) {
        ///call our database service to update the user data.
        await DatabaseService(uid: user.uid).savingUserData(fullname, email);
        return true;
      }
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  ///method for signout
  Future signOutUser() async {
    try {
      await HelperFunction.saveUserLoggedInStatus(false);
      await HelperFunction.saveUserEmailKey("");
      await HelperFunction.saveUserNameKey("");
      await _firebaseAuth.signOut();
    } catch (e) {
      return null;
    }
  }
}
