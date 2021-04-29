
import 'package:flutter/material.dart';

class LoadingFullScreenWidget extends StatelessWidget {
  final String prompt;
  LoadingFullScreenWidget({this.prompt = "LOADING"});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              height: MediaQuery.of(context).size.width * .15,
              width: MediaQuery.of(context).size.width * .15,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>( Theme.of(context).primaryColor),
                backgroundColor: Colors.transparent,
              ),
            ),
          ),
          Text(
            prompt,
            style: TextStyle(color: Theme.of(context).primaryColor),
          )
        ],
      ),
    );
  }
}
