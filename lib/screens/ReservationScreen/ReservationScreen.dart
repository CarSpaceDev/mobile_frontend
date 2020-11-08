import 'package:carspace/constants/GlobalConstants.dart';
import 'package:carspace/resusables/AppBarLayout.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ReservationScreen extends StatefulWidget {
  @override
  _ReservationScreenState createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  bool hideInfo = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: mainAppBar(context, 'CarSpace', () {}),
      body: Stack(
        children: <Widget>[
          Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Image.network(
                'https://kerb.imgix.net/listing-photos/39667-5d564b5d8231f.jpg?ixlib=php-1.2.1&s=497d1a1d3826657ff45a415f46aa80a5',
                fit: BoxFit.cover,
                width: double.infinity,
              )),
          Positioned(
            top: 12,
            left: 10,
            child: GestureDetector(
              onTap: (){
                Navigator.pop(context);
              },
              child: Container(
                  child: Icon(
                Icons.arrow_back_ios,
                color: Colors.black,
              )),
            ),
          ),
          hideInfo
              ? Positioned(
                  bottom: 10,
                  left: 10,
                  right: 10,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.0)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text('Bacon St.',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                  Text('Php 25.00 /per hour'),
                                ],
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    this.hideInfo = false;
                                  });
                                },
                                child: Text('Hide',
                                    style: TextStyle(
                                        decoration: TextDecoration.underline)),
                              )
                            ],
                          ),
                          Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text('Lot details',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    width: 200,
                                    child: Text('Address: Cebu, Cebu City\n'
                                        'Vehicles accepted: Sedan and smaller'),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    showCupertinoDialog(
                                        context: context,
                                        builder: (_) {
                                          return Material(
                                            color: Colors.grey,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 100.0,
                                                  left: 10.0,
                                                  right: 10.0,
                                                  bottom: 100.0),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20.0),
                                                  color: Colors.white,
                                                ),
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                  children: <Widget>[
                                                    GestureDetector(
                                                      onTap:(){
                                                        Navigator.pop(context);
                                                      },
                                                      child: Align(
                                                          alignment:
                                                              Alignment.topLeft,
                                                          child: Padding(
                                                            padding: const EdgeInsets.only(left:8.0),
                                                            child: Icon(Icons.close),
                                                          )),
                                                    ),
                                                    Center(
                                                        child: Text(
                                                            'Reservation confirmed.',
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize:
                                                                    20.0))),
                                                    Padding(
                                                      padding:
                                                      const EdgeInsets.all(
                                                          20.0),
                                                      child: Container(
                                                        child: Center(
                                                          child: Text(
                                                            'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt '
                                                                'ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation '
                                                                'ullamco laboris nisi ut aliquip ex ea commodo '
                                                                'consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse '
                                                                'cillum dolore eu fugiat nulla pariatur.',
                                                            textAlign: TextAlign
                                                                .justify,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Center(
                                                      child: Padding(
                                                        padding:
                                                        const EdgeInsets
                                                            .all(8.0),
                                                        child: Text(
                                                            'Open in app',
                                                            style: TextStyle(
                                                                fontWeight:
                                                                FontWeight
                                                                    .bold,
                                                                fontSize:
                                                                16.0)),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                      const EdgeInsets.all(
                                                          8.0),
                                                      child: Center(
                                                        child: Container(
                                                          child: Row(
                                                            mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceEvenly,
                                                            children: <Widget>[
                                                              Container(
                                                                child: Text(
                                                                    'Waze Logo'),
                                                              ),
                                                              Container(
                                                                child: Text(
                                                                    'Google Map Logo'),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Align(
                                                      alignment: Alignment
                                                          .bottomCenter,
                                                      child: Container(
                                                        width: MediaQuery.of(
                                                            context)
                                                            .size
                                                            .width -
                                                            100,
                                                        height: 40,
                                                        decoration: BoxDecoration(
                                                            color: themeData
                                                                .secondaryHeaderColor,
                                                            borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                20.0)),
                                                        child: Center(
                                                            child: Text(
                                                                'Main menu',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white))),
                                                      ),
                                                    ),

                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        });
                                  },
                                  child: Container(
                                    height: 30,
                                    width:
                                        MediaQuery.of(context).size.width - 100,
                                    decoration: BoxDecoration(
                                        color: themeData.secondaryHeaderColor,
                                        borderRadius:
                                            BorderRadius.circular(20.0)),
                                    child: Center(
                                        child: Text('Book now',
                                            style: TextStyle(
                                                color: Colors.white))),
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                )
              : Positioned(
                  bottom: 12,
                  left: 10,
                  child: GestureDetector(
                      onTap: () {
                        setState(() {
                          this.hideInfo = true;
                        });
                      },
                      child: Icon(
                        Icons.info,
                        size: 50,
                        color: Colors.indigo,
                      )),
                ),
        ],
      ),
    );
  }
}
