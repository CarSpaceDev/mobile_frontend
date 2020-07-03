import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:carspace/model/User.dart';
import 'package:carspace/services/ApiService.dart';
import './bloc.dart';
import 'package:carspace/services/AuthService.dart';

final AuthService authService = AuthService();
final ApiService apiService = ApiService.create();

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  @override
  LoginState get initialState => LoginInitialState();

  @override
  Stream<LoginState> mapEventToState(
    LoginEvent event,
  ) async* {
    if (event is NoSessionEvent) {
      yield LoggedOut();
    }
    if (event is LoggedInEvent) {
      User user = await authService.currentUser();
      yield AuthorizationSuccess();
      user = await getUserDataFromApi(user);
      yield LoggedIn(user);
    }
    if (event is LoginGoogleEvent) {
      yield LoginInProgress();
      User user = await authService.loginGoogle();
      if (user != null) {
        yield AuthorizationSuccess();
        user = await getUserDataFromApi(user);
        yield LoggedIn(user);
      } else
        yield LoggedOut();
    } else if (event is LogInEmailEvent) {
      yield LoginInProgress();
      User user =
          await authService.signInWithEmail(event.email, event.password);
      if (user != null) {
        yield AuthorizationSuccess();
        user = await getUserDataFromApi(user);
        yield LoggedIn(user);
      } else
        yield LoggedOut();
    }
  }

  getUserDataFromApi(User user) async {
    try {
      final response =
          await apiService.requestUserInfo(user.jwt, user.toJson());
      if (response.statusCode == 201) {
        print('Decoding the response body');
        print(response.body.toString());
        user = user.fromJson(response.body);
        return user;
      } else if (response.statusCode == 403)
        print("JWT Error");
      else
        throw Error();
    } catch (e) {
      print(e);
      return null;
    }
  }
}
