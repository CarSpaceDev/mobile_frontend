import 'package:carspace/services/DevTools.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

//custom imports

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthService() {
    devLog("AuthServiceInit", 'AuthService is initialized');
  }

  User currentUser() {
    try {
      var user = _auth.currentUser;
      // print(user);
      if (user != null) {
        // var token = await _getJWT(user);
        return user;
        // return CSUser.fromAuthService(user, token);
      } else
        return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future signInWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      // final token = await _getJWT(result.user);
      // print(token);
      final User currentUser = result.user;
      return currentUser;
    } catch (e) {
      print(e.message);
      return null;
    }
  }

  //login with google
  Future loginGoogle() async {
    try {
      //trigger the login dialog
      final GoogleSignIn _googleSignIn = GoogleSignIn();
      final GoogleSignInAccount googleSignInAccount =
          await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );
      //sign in to firebase auth
      final UserCredential result =
          await _auth.signInWithCredential(credential);
      final token = await _getJWT(result.user);
      print(token);
      final User currentUser = result.user;
      return currentUser;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  _getJWT(User user) async {
    final String result = await user.getIdToken();
    return result;
  }

  Future logOut() async {
    final GoogleSignIn _googleSignIn = GoogleSignIn();
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      return null;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
