
import 'package:flutter/material.dart';

class LoadingFullScreenWidget extends StatelessWidget {
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
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                backgroundColor: Theme.of(context).primaryColor,
              ),
            ),
          ),
          Text(
            "LOADING",
            style: TextStyle(color: Theme.of(context).primaryColor),
          )
        ],
      ),
    );
  }
}
