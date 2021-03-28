import 'package:carspace/constants/GlobalConstants.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import '../../blocs/login/login_bloc.dart';

class EulaScreen extends StatefulWidget {
  @override
  _EulaScreenState createState() => _EulaScreenState();
}

class _EulaScreenState extends State<EulaScreen> {
  final scrollController = new ScrollController();
  final cache = Hive.box("localCache");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: csTheme.primaryColor,
      appBar: AppBar(
        brightness: Brightness.dark,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "End User License Agreement",
          style: TextStyle(color: Colors.white),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: csTheme.backgroundColor,
        child: Container(
          height: MediaQuery.of(context).size.height * .1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              FlatButton(
                onPressed: () => {sendResponse(context, false)},
                padding: EdgeInsets.all(10.0),
                child: Column(
                  children: <Widget>[
                    Icon(Icons.not_interested),
                    Text('Decline'),
                  ],
                ),
              ),
              FlatButton(
                onPressed: () => {sendResponse(context, true)},
                padding: EdgeInsets.all(10.0),
                child: Column(
                  children: <Widget>[
                    Icon(Icons.check),
                    Text('Accept'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: Center(
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              width: MediaQuery.of(context).size.width * .8,
              height: MediaQuery.of(context).size.height * .6,
              child: Column(
                children: <Widget>[
                  Text("Terms and Conditions"),
                  Divider(),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .78,
                    height: MediaQuery.of(context).size.height * .55,
                    child: Scrollbar(
                      isAlwaysShown: true,
                      controller: scrollController,
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text(
                            cache.get("data")["eula"],
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  sendResponse(BuildContext context, bool v) {
    context.read<LoginBloc>().add(EulaResponseEvent(value: v));
  }
}
