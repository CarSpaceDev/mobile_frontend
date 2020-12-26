import 'package:flutter/material.dart';

import '../../reusable/ImageUploadWidget.dart';

class TestScreen extends StatefulWidget {
  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  dynamic imageWidget;

  _TestScreenState() {
    imageWidget = new ImageUploadWidget(
        prompt: "Upload a something something", callback: saveUrl);
  }
  String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: [
            imageWidget,
            FlatButton(onPressed: () {}, child: Icon(Icons.image))
          ],
        ),
      ),
    );
  }

  saveUrl(String v) {
    print("Saved url");
    setState(() {
      imageUrl = v;
    });
    print(imageUrl);
  }
}
