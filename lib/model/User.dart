import 'package:firebase_auth/firebase_auth.dart';

class User {
  String uid;
  String photoUrl;
  DateTime lastSignInTime;
  String displayName;
  String email;
  double distance;
  bool firstLogin;
  String jwt;

  User(FirebaseUser user, String token) {
    this.uid = user.uid;
    this.photoUrl = user.photoUrl;
    this.lastSignInTime = user.metadata.lastSignInTime;
    this.displayName = user.displayName;
    this.email = user.email;
    this.firstLogin = firstLogin;
    this.distance = distance;
    this.jwt = token;
  }
  User.another({ this.uid, this.displayName, this.photoUrl,this.distance});

  printUserData() {
    print({
      this.uid,
      this.displayName,
      this.email,
      this.photoUrl,
      this.lastSignInTime
    });
  }

  Map<String, dynamic> toJson() => {
        'uid': this.uid,
        'photoUrl': this.photoUrl,
        'displayName': this.displayName,
        'lastSignInTime': this.lastSignInTime.toString(),
      };

}
