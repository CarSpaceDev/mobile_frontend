import 'package:carspace/constants/GlobalConstants.dart';
import 'package:carspace/screens/Home/MapScreen.dart';
import 'package:carspace/services/AuthService.dart';
import 'package:flutter/material.dart';
import 'login/LoginBlocHandler.dart';
import 'package:provider/provider.dart';
import 'package:carspace/model/GlobalData.dart';
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  TextEditingController _searchController;
  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: "");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: themeData.primaryColor,
        title: Text("Map"),
        centerTitle: true,
        leading: IconButton(
          color: Colors.white,
          onPressed: () async {
            await _authService.logOut();
            Navigator.of(context)
                .pushReplacement(MaterialPageRoute(builder: (BuildContext context) => LoginBlocHandler()));
          },
          icon: Icon(Icons.exit_to_app),
        ),
        actions: <Widget>[
          FlatButton.icon(
              onPressed: () => {},
              icon: Icon(
                Icons.menu,
                color: Colors.white,
              ),
              label: Text(""))
        ],
      ),
      backgroundColor: themeData.primaryColor,
      body: SafeArea(
        child: Stack(children: [
          MapScreen(),
          Positioned(
            top: 16,
            child: PreferredSize(
              preferredSize: Size(MediaQuery.of(context).size.width, 53),
              child: Container(
                width: MediaQuery.of(context).size.width,
                color: Colors.transparent,
                child: searchBar(context),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  searchBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Spacer(flex: 1),
        Container(
          width: MediaQuery.of(context).size.width * .75,
          decoration: new BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(
              Radius.circular(25.0),
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: TextField(
            controller: _searchController,
            style: TextStyle(fontFamily: "Champagne & Limousines", color: Colors.black, fontSize: 20),
            decoration: InputDecoration(
              hintText: "Enter destination",
              hintStyle: TextStyle(fontFamily: "Champagne & Limousines", fontSize: 18, color: Colors.black),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
            ),
          ),
        ),
        Spacer(flex: 1),
        Container(
          width: 50,
          height: 50,
          decoration: new BoxDecoration(
            color: themeData.secondaryHeaderColor,
            borderRadius: BorderRadius.all(
              Radius.circular(25.0),
            ),
          ),
          child: Icon(Icons.search, color: Colors.white),
        ),
        Spacer(flex: 1),
      ],
    );
  }
}
