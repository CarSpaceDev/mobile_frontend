import 'package:carspace/model/CSNotification.dart';
import 'package:carspace/repo/notificationRepo/notification_bloc.dart';
import 'package:carspace/repo/reservationRepo/reservation_repo_bloc.dart';
import 'package:carspace/reusable/CSText.dart';
import 'package:carspace/reusable/CSTile.dart';
import 'package:carspace/reusable/LoadingFullScreenWidget.dart';
import 'package:carspace/reusable/NavigationDrawer.dart';
import 'package:carspace/screens/DriverScreens/HomeDashboard.dart';
import 'package:carspace/screens/DriverScreens/Notifications/NotificationWidget.dart';
import 'package:carspace/screens/DriverScreens/Reservations/PartnerReservationScreen.dart';
import 'package:carspace/screens/Wallet/WalletInfoWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PartnerDashboard extends StatefulWidget {
  @override
  _PartnerDashboardState createState() => _PartnerDashboardState();
}

class _PartnerDashboardState extends State<PartnerDashboard> {
  bool isSelected;
  bool isSwitched = false;
  var textValue = 'Switch is OFF';
  int page = 0;
  List<String> header = ["LOTS", "RESERVATIONS", "NOTIFICATIONS"];
  void toggleSwitch(bool value) {
    if (isSwitched == false) {
      setState(() {
        isSwitched = true;
        textValue = 'Active';
      });
      print('Switch Button is ON');
    } else {
      setState(() {
        isSwitched = false;
        textValue = 'Inactive';
      });
      print('Switch Button is OFF');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    this.isSelected = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        brightness: Brightness.dark,
        centerTitle: true,
        actions: [
          WalletInfoWidget(),
        ],
        leading: CSMenuButton(),
      ),
      drawer: HomeNavigationDrawer(
        isPartner: true,
      ),
      body: BackgroundImage(
        child: SafeArea(
          child: Column(
            children: [
              CSTile(
                margin: EdgeInsets.fromLTRB(16, 16, 16, 8),
                borderRadius: 16,
                child: CSText(
                  header[page],
                  textType: TextType.H3Bold,
                  textColor: TextColor.Blue,
                ),
              ),
              Flexible(
                child: PageView(
                  onPageChanged: (i) {
                    setState(() {
                      page = i;
                    });
                  },
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: Center(
                        child: CSText(
                          "2",
                          textColor: TextColor.values[2],
                        ),
                      ),
                    ),
                    BlocBuilder<ReservationRepoBloc, ReservationRepoState>(
                      builder: (BuildContext context, state) {
                        if (state is ReservationRepoReady) {
                          if (state.reservations.isEmpty) {
                            return Center(
                              child: CSText("No reservations at the moment", textType: TextType.Button, textColor: TextColor.Black,),
                            );
                          }
                          return ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            itemCount: state.reservations.length,
                            itemBuilder: (BuildContext context, index) {
                              return PartnerReservationTileWidget(reservation: state.reservations[index]);
                            },
                          );
                        }
                        return LoadingFullScreenWidget();
                      },
                    ),
                    BlocBuilder<NotificationBloc, NotificationState>(
                      builder: (BuildContext context, state) {
                        if (state is NotificationsReady) {
                          if (state.notifications.isEmpty)
                            return Center(child: CSText("No notifications at the moment", textType: TextType.Button,textColor: TextColor.Black,));
                          else
                            return ListView.builder(
                                itemCount: state.notifications.length,
                                itemBuilder: (BuildContext context, index) {
                                  return NotificationWidget(
                                      notification: state.notifications[index],
                                      onTap: () {
                                        if (!state.notifications[index].opened)
                                          context
                                              .bloc<NotificationBloc>()
                                              .add(NotificationOpened(uid: state.notifications[index].uid));
                                      });
                                });
                        } else
                          return Text("Getting notifications ... ");
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomTextWidget extends StatelessWidget {
  final String label;
  final String name;
  const CustomTextWidget({
    Key key,
    this.label,
    this.name,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label + ' :', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black54)),
          Text(
            name,
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
