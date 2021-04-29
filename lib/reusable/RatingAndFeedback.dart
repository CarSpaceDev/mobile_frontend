import 'package:carspace/model/Reservation.dart';
import 'package:carspace/reusable/Popup.dart';
import 'package:carspace/services/ApiService.dart';
import 'package:carspace/services/navigation.dart';
import 'package:carspace/services/serviceLocator.dart';
import 'package:flutter/material.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

import 'CSText.dart';
import 'CSTile.dart';

class RatingAndFeedback extends StatefulWidget {
  final String user;
  final Reservation reservation;
  final type;
  const RatingAndFeedback(this.reservation, this.user, this.type);
  @override
  _RatingAndFeedbackState createState() => _RatingAndFeedbackState();
}

class _RatingAndFeedbackState extends State<RatingAndFeedback> {
  var rating = 5.0;
  var searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return CSSegmentedTile(
      title: CSText(
        "Rating and Feedback",
        textAlign: TextAlign.center,
        textType: TextType.H3Bold,
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CSTile(
            margin: EdgeInsets.symmetric(vertical: 16),
            padding: EdgeInsets.zero,
            child: SmoothStarRating(
              rating: rating,
              isReadOnly: false,
              size: 45,
              filledIconData: Icons.star,
              halfFilledIconData: Icons.star_half,
              defaultIconData: Icons.star_border,
              starCount: 5,
              allowHalfRating: true,
              spacing: 2.0,
              onRated: (value) {
                rating = value;
              },
            ),
          ),
          CSTile(
            margin: EdgeInsets.symmetric(vertical: 8),
            padding: EdgeInsets.zero,
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                  border: OutlineInputBorder(), hintText: 'Enter Feedback'),
            ),
          ),
          CSTile(
            margin: EdgeInsets.only(top: 8),
            borderRadius: 8,
            color: TileColor.Green,
            onTap: callToAction,
            child: CSText("SUBMIT",
                textType: TextType.Button, textColor: TextColor.White),
          ),
        ],
      ),
    );
  }

  callToAction() async {
    locator<NavigationService>().goBack();
    if (this.widget.type == 0) {
      var ratingBody = {
        "userId": widget.user,
        "reservationId": this.widget.reservation.uid,
        "lotId": this.widget.reservation.lotId,
        "rating": rating,
        "feedback": searchController.text
      };
      print(ratingBody);
      print(widget.user);
      await locator<ApiService>().rateLot(ratingBody).then((data) {
        showMessage(data.body);
      });
    } else {
      var ratingBody = {
        "userId": widget.user,
        "reservationId": widget.reservation.uid,
        "lotId": this.widget.reservation.lotId,
        "rating": rating,
        "feedback": searchController.text
      };
      print(widget.user);
      await locator<ApiService>().rateDriver(ratingBody).then((data) {
        showMessage(data.body);
      });
    }
  }

  showMessage(String v) {
    PopUp.showInfo(
        context: locator<NavigationService>().navigatorKey.currentContext,
        title: "Thank you!",
        body: v);
  }
}
