import 'package:carspace/screens/DriverScreens/Reservations/ReservationScreen.dart';
import 'package:carspace/screens/Home/PartnerReservationScreen.dart';
import 'package:carspace/services/ApiService.dart';
import 'package:carspace/services/navigation.dart';
import 'package:carspace/services/serviceLocator.dart';
import 'package:flutter/material.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';


class RatingAndFeedback extends StatefulWidget {
  final String user;
  final reservation;
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
    return MaterialApp(
        title: 'Rating',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Column(
            children: [
              Text(
                "Rating and Feedback",
                textAlign: TextAlign.center,
                style: TextStyle(height: 2, fontSize: 20),
              ),
              SizedBox(
                height: 20,
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
              Flexible(
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), hintText: 'Enter Feedback'),
                ),
              ),
              SizedBox(
                height: 20,
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

  callToAction() async {
    if (this.widget.type == 0) {
      var ratingBody = {
        "userId": this.widget.user,
        "reservationId": this.widget.reservation.reservationId,
        "lotId": this.widget.reservation.lotId,
        "rating": rating,
        "feedback": searchController.text
      };
      print(ratingBody);
      await locator<ApiService>().rateLot(ratingBody).then((data) {
        showMessage(data.body);
      });
    } else {
      var ratingBody = {
        "userId": this.widget.user,
        "reservationId": this.widget.reservation.reservationId,
        "lotId": this.widget.reservation.lotId,
        "rating": rating,
        "feedback": searchController.text
      };
      print(ratingBody);
      await locator<ApiService>().rateDriver(ratingBody).then((data) {
        showMessage(data.body);
      });
    }
  }

  showMessage(String v) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            content: SingleChildScrollView(
              child: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Icon(
                        Icons.info_outline,
                        color: Colors.grey,
                        size: 50,
                      ),
                    ),
                    Text(
                      "$v",
                      textAlign: TextAlign.center,
                      style: TextStyle(height: 5, fontSize: 20),
                    )
                  ],
                ),
              ),
            ),
            actions: [
              FlatButton(
                  onPressed: () {
                    if (this.widget.type == 0) {
                      locator<NavigationService>().pushNavigateToWidget(
                        getPageRoute(
                          ReservationScreen(),
                          RouteSettings(name: "Reservation"),
                        ),
                      );
                    } else {
                      locator<NavigationService>().pushNavigateToWidget(
                        getPageRoute(
                          PartnerReservationScreen(),
                          RouteSettings(name: "PartnerReservation"),
                        ),
                      );
                    }
                  },
                  child: Text("Close"))
            ],
          );
        });
  }
}
