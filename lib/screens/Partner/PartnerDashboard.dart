import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PartnerDashboard extends StatefulWidget {
  @override
  _PartnerDashboardState createState() => _PartnerDashboardState();
}

class _PartnerDashboardState extends State<PartnerDashboard> {
  bool isSelected;
  bool isSwitched = false;
  var textValue = 'Switch is OFF';

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
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Icon(Icons.menu, color: Colors.blue),
      ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/login_screen_assets/bg.png'),
                  fit: BoxFit.cover)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Hello',
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700)),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(vertical: 12.0),
                            child: RichText(
                                text: TextSpan(children: <TextSpan>[
                              TextSpan(
                                  text: 'Juan',
                                  style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue)),
                              TextSpan(
                                  text: ' Dela Cruz',
                                  style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green))
                            ])),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 80,
                      width: 80,
                      child: Card(
                          color: Colors.white,
                          child: Image.asset('assets/images/car.png',
                              fit: BoxFit.contain)),
                    )
                  ],
                ),
                // Container(
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       SizedBox(
                //         width: MediaQuery.of(context).size.width / 100 * 42,
                //         height: MediaQuery.of(context).size.width / 100 * 25,
                //         child: Card(
                //           color: Colors.blue,
                //           shape: RoundedRectangleBorder(
                //               borderRadius: BorderRadius.circular(10)),
                //           child: Column(
                //             children: [
                //               Container(
                //                   width: MediaQuery.of(context).size.width,
                //                   child: Padding(
                //                     padding: const EdgeInsets.all(8.0),
                //                     child: Text('Current rating'),
                //                   )),
                //               Center(child: Text('5.0')),
                //             ],
                //           ),
                //         ),
                //       ),
                //       SizedBox(
                //         width: MediaQuery.of(context).size.width / 100 * 42,
                //         height: MediaQuery.of(context).size.width / 100 * 25,
                //         child: Card(
                //           color: Colors.yellow,
                //           shape: RoundedRectangleBorder(
                //               borderRadius: BorderRadius.circular(10)),
                //           child: Column(
                //             children: [
                //               Text('Current rating'),
                //               Text('5.0'),
                //             ],
                //           ),
                //         ),
                //       )
                //     ],
                //   ),
                // ),
                Padding(
                  padding:  EdgeInsets.only(top: 20.0),
                  child: Container(
                    child: Text('YOUR LOTS',
                        style: TextStyle(
                            fontSize: 26,
                            color: Colors.white,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
                if (!isSelected)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: GridView.builder(
                        scrollDirection: Axis.vertical,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 3 / 3,
                          ),
                          itemCount: 6,
                          itemBuilder: (BuildContext context, index) {
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  this.isSelected = true;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Image.asset('assets/images/car.png'),
                                      Text(
                                        '173 Sandayong Lipata...',
                                        textAlign: TextAlign.center,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 10,
                                            height: 10,
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.red),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 4.0),
                                            child: Text('ACTIVE'),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                    ),
                  ),
                if (isSelected)
                  Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Container(
                        
                          padding: EdgeInsets.all(20.0),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10)),
                          width: MediaQuery.of(context).size.width,
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Align(
                                  alignment: Alignment.topRight,
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        this.isSelected = false;
                                      });
                                    },
                                    child: Icon(Icons.close),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text(
                                    '173 Sandayon Lipata, Minglanilla, Cebu',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                CustomTextWidget(
                                  label: 'Parking type',
                                  name: 'RESERVATION',
                                ),
                                CustomTextWidget(
                                  label: 'Available days',
                                  name: 'Wednesday, Thursday',
                                ),
                                CustomTextWidget(
                                  label: 'Available time',
                                  name: '0000H - 2300H',
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Price :',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black54)),
                                      Row(
                                        children: [
                                          InkWell(
                                            onTap: () {},
                                            child: Padding(
                                              padding: const EdgeInsets.only(right: 8.0),
                                              child: Icon(Icons.remove_circle_outlined, size: 20, color: Colors.lightBlueAccent,),
                                            ),
                                          ),


                                          Container(
                                            width: 100,
                                            height: 30,
                                            child: TextField(
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(),
                                                labelText: 'Php 25.00 /hr',
                                                labelStyle: TextStyle(fontSize: 12)
                                              ),
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () {},
                                            child: Padding(
                                              padding: const EdgeInsets.only(left: 8.0),
                                              child: Icon(Icons.add_circle, size: 20, color: Colors.lightBlueAccent,),
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                CustomTextWidget(
                                  label: 'Status',
                                  name: 'Verified',
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Lot status :',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black54)),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text('$textValue'),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: Transform.scale(
                                              scale: 1,
                                              child: Switch(
                                                onChanged: toggleSwitch,
                                                value: isSwitched,
                                                activeColor: Colors.blue,
                                                activeTrackColor:
                                                    Colors.lightBlueAccent,
                                                inactiveThumbColor: Colors.grey,
                                                inactiveTrackColor:
                                                    Colors.blueGrey,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ))
              ],
            ),
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
