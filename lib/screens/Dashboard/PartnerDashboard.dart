import 'package:carspace/model/Enums.dart';
import 'package:carspace/repo/reservationRepo/reservation_repo_bloc.dart';
import 'package:carspace/reusable/CSText.dart';
import 'package:carspace/reusable/CSTile.dart';
import 'package:carspace/reusable/NavigationDrawer.dart';
import 'package:carspace/screens/Dashboard/DriverDashboard.dart';
import 'package:carspace/screens/Notifications/NotificationLinkWidget.dart';
import 'package:carspace/screens/Reservations/PartnerReservationScreen.dart';
import 'package:carspace/screens/Wallet/WalletInfoWidget.dart';
import 'package:carspace/services/navigation.dart';
import 'package:carspace/services/serviceLocator.dart';
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
        title: CSText(
          "Partner Dashboard",
          textType: TextType.H5Bold,
          textColor: TextColor.White,
          padding: EdgeInsets.only(top: 4),
        ),
        leading: CSMenuButton(),
        actions: [NotificationLinkWidget()],
      ),
      drawer: HomeNavigationDrawer(
        isPartner: true,
      ),
      body: BackgroundImage(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: SafeArea(
          child: Column(
            children: [ CSTile(
              color: TileColor.Primary,
              onTap: () {
                locator<NavigationService>().pushNavigateTo(WalletRoute);
              },
              borderRadius: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CSText(
                    "Your Wallet",
                    textType: TextType.H3Bold,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    textAlign: TextAlign.center,
                    textColor: TextColor.Green,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: WalletInfoWidget(
                      textColor: TextColor.White,
                      textType: TextType.H2,
                      noRedirect: true,
                    ),
                  ),
                ],
              ),
            ),
              Expanded(
                child: SingleChildScrollView(
                  child: BlocBuilder<ReservationRepoBloc, ReservationRepoState>(
                    builder: (BuildContext context, state) {
                      if (state is ReservationRepoReady) {
                        return Column(
                          children: [
                            for (var reservation in state.reservations)
                              if (reservation.reservationStatus ==
                                      ReservationStatus.Active ||
                                  reservation.reservationStatus ==
                                      ReservationStatus.Reserved)
                                PartnerReservationTileWidget(
                                    reservation: reservation)
                          ],
                        );
                      }
                      return Container();
                    },
                  ),
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
          Text(label + ' :',
              style: TextStyle(
                  fontWeight: FontWeight.w600, color: Colors.black54)),
          Text(
            name,
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
