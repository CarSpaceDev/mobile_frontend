import 'package:carspace/constants/GlobalConstants.dart';
import 'package:flutter/material.dart';

class EulaScreen extends StatefulWidget {
  @override
  _EulaScreenState createState() => _EulaScreenState();
}

class _EulaScreenState extends State<EulaScreen> {
  final scrollController = new ScrollController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: themeData.primaryColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "End User License Agreement",
          style: TextStyle(color: Colors.white),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: themeData.backgroundColor,
        child: Container(
          height: MediaQuery.of(context).size.height *.1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              FlatButton(
                onPressed: () => {},
                padding: EdgeInsets.all(10.0),
                child: Column(
                  children: <Widget>[
                    Icon(Icons.not_interested),
                    Text('Decline'),
                  ],
                ),
              ),
              FlatButton(
                onPressed: () => {},
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                            StringConstants.loremIpsum,
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
}
