import 'package:flutter/material.dart';

import '../../reusable/ImageUploadWidget.dart';

class TestScreen extends StatefulWidget {
  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  dynamic imageWidget;

  _TestScreenState() {
    imageWidget = new ImageUploadWidget((92 / 60), saveUrl,
        prompt: "Upload a something something");
  }
  String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: [
            Padding(padding: EdgeInsets.all(16), child: imageWidget),
            FlatButton(onPressed: () {print(imageUrl);}, child: Icon(Icons.image))
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
