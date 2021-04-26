import 'package:carspace/reusable/CSText.dart';
import 'package:carspace/reusable/CSTile.dart';
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
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        brightness: Brightness.dark,
        elevation: 0,
        centerTitle: true,
        title: CSText(
          "Terms and Conditions",
          textColor: TextColor.White,
          textType: TextType.H4,
          textAlign: TextAlign.center,
        ),
      ),
      body: Column(
        children: [
          Flexible(
            child: Center(
              child: CSTile(
                color: TileColor.White,
                shadow: true,
                borderRadius: 16,
                margin: EdgeInsets.all(16),
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  height: MediaQuery.of(context).size.height * .5,
                  child: Scrollbar(
                    controller: scrollController,
                    isAlwaysShown: true,
                    child: SingleChildScrollView(
                      controller: scrollController,
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
            ),
          ),
          CSTile(
            color: TileColor.None,
            child: Row(
              children: <Widget>[
                Flexible(
                  child: CSTile(
                    borderRadius: 8,
                    onTap: () => {sendResponse(context, false)},
                    margin: EdgeInsets.zero,
                    padding: EdgeInsets.all(16.0),
                    child: CSText('DECLINE', textType: TextType.Button, textColor: TextColor.Red,),
                  ),
                ),
                Container(
                  width: 16,
                ),
                Flexible(
                  child: CSTile(
                    borderRadius: 8,
                    onTap: () => {sendResponse(context, true)},
                    margin: EdgeInsets.zero,
                    padding: EdgeInsets.all(16.0),
                    child: CSText('ACCEPT', textType: TextType.Button, textColor: TextColor.Primary,),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  sendResponse(BuildContext context, bool v) {
    context.read<LoginBloc>().add(EulaResponseEvent(value: v));
  }
}
