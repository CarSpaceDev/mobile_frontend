import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:carspace/model/User.dart';
import 'package:carspace/services/ApiService.dart';
import 'package:carspace/services/LocalStorage.dart';

//custom imports

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  AuthService() {
    print('AuthService is initialized');
  }
  //UserObject transformation
  User _userFromResult(FirebaseUser user, String token) {
    if (user == null)
      return null;
    else
      return User(user, token);
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
      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );
      //sign in to firebase auth
      final AuthResult result = await _auth.signInWithCredential(credential);
      final token = await _getJWT(result.user);
      final User currentUser = _userFromResult(result.user, token);
      return currentUser;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  _getJWT(FirebaseUser user) async {
    final IdTokenResult result = await user.getIdToken();
    return result.token;
  }

  //TODO insert a method to update DB and download session data after authentication is done particularly since we need first login status and user UUID and filter data if set

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
