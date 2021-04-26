import 'package:flutter/material.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

class RatingAndFeedback extends StatefulWidget {
  @override
  _RatingAndFeedbackState createState() => _RatingAndFeedbackState();
}

class _RatingAndFeedbackState extends State<RatingAndFeedback> {
  var rating = 5.0;
  var searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Rating',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                "Rating and Feedback",
                textAlign: TextAlign.center,
                style: TextStyle(height: 5, fontSize: 20),
              ),
              Center(
                  child: SmoothStarRating(
                rating: rating,
                isReadOnly: false,
                size: 40,
                filledIconData: Icons.star,
                halfFilledIconData: Icons.star_half,
                defaultIconData: Icons.star_border,
                starCount: 5,
                allowHalfRating: true,
                spacing: 2.0,
                onRated: (value) {
                  rating = value;
                  // print("rating value dd -> ${value.truncate()}");
                },
              )),
              Expanded(
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), hintText: 'Enter Feedback'),
                ),
              ),
              TextButton(
                  child: Text("Submit".toUpperCase(),
                      style: TextStyle(fontSize: 25)),
                  style: ButtonStyle(
                      padding: MaterialStateProperty.all<EdgeInsets>(
                          EdgeInsets.all(15)),
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.blue),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: BorderSide(color: Colors.blue)))),
                  onPressed: () => callToAction()),
            ],
          ),
        ));
  }

  callToAction() {
    print("called");
    print(rating);
    print(searchController.text);
  }
}
