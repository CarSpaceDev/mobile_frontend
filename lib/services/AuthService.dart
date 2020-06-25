//import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:carspace/model/User.dart';

//custom imports

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
//  Future<bool> get appleSignInAvailable => AppleSignIn.isAvailable();

  AuthService() {
    print('AuthService is initialized');
  }
  //UserObject transformation
  User _userFromResult(FirebaseUser user, String token) {
    if (user == null)
      return null;
    else
      return User.fromAuthService(user, token);
  }

  currentUser() async {
    try {
      var user = await _auth.currentUser();
      if (user != null) {
        var token = await _getJWT(user);
        return User.fromAuthService(user, token);
      }
      else
        return null;
    }
    catch (e){
      print(e);
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
      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );
      //sign in to firebase auth
      final AuthResult result = await _auth.signInWithCredential(credential);
      final token = await _getJWT(result.user);
//      print(token);
      final User currentUser = _userFromResult(result.user, token);
      return currentUser;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

//  Future loginApple() async {
//    try {
//      final AuthorizationResult result = await AppleSignIn.performRequests([
//        AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
//      ]);
//
//      switch (result.status) {
//        case AuthorizationStatus.authorized:
//          try {
//            print("Apple sign in success");
//            final AppleIdCredential appleIdCredential = result.credential;
//
//            OAuthProvider oAuthProvider =
//            new OAuthProvider(providerId: "apple.com");
//            final AuthCredential credential = oAuthProvider.getCredential(
//              idToken:
//              String.fromCharCodes(appleIdCredential.identityToken),
//              accessToken:
//              String.fromCharCodes(appleIdCredential.authorizationCode),
//            );
//
//            await FirebaseAuth.instance
//                .signInWithCredential(credential);
//
//            FirebaseAuth.instance.currentUser().then((val) async {
//              UserUpdateInfo updateUser = UserUpdateInfo();
//              updateUser.displayName =
//              "${appleIdCredential.fullName.givenName} ${appleIdCredential.fullName.familyName}";
//              updateUser.photoUrl =
//              "https://www.pikpng.com/pngl/b/80-805068_my-profile-icon-blank-profile-picture-circle-clipart.png";
//              await val.updateProfile(updateUser);
//            });
//            return await currentUser();
//          } catch (e) {
//            print("error");
//            return null;
//          }
//          break;
//        case AuthorizationStatus.error:
//          return null;
//          break;
//
//        case AuthorizationStatus.cancelled:
//          return null;
//          break;
//      }
//    } catch (error) {
//      print("error with apple sign in");
//      return null;
//    }
//  }

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
