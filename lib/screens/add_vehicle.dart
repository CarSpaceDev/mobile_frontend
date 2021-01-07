import 'package:flutter/material.dart';

class AddVehicle extends StatefulWidget {
  @override
  _AddVehicleState createState() => _AddVehicleState();
}

class _AddVehicleState extends State<AddVehicle> {

  _showDialog(){
    return showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0)
        ),
        child: new SizedBox(
          height: 100,
          // color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: GestureDetector(
                    onTap: (){},
                    child: Column(
                      children: [
                        Icon(Icons.edit, color: Colors.blueAccent,),
                        Text('Edit', style: TextStyle(color: Colors.blueAccent))
                      ],
                    ),
                  ),
                ),
                 Padding(
                   padding: const EdgeInsets.only(top: 20.0),
                   child: GestureDetector(
                     onTap: (){},
                     child: Column(
                       children: [
                         Icon(Icons.delete, color: Colors.redAccent),
                         Text('Delete', style: TextStyle(color: Colors.redAccent),)
                       ],
                     ),
                   ),
                 ),
                 Padding(
                   padding: const EdgeInsets.only(top: 20.0),
                   child: GestureDetector(
                     onTap: (){},
                     child: Column(
                       children: [
                         Icon(Icons.share, color: Colors.green),
                         Text('Share', style: TextStyle(color: Colors.green))
                       ],
                     ),
                   ),
                 ),
                 Padding(
                   padding: const EdgeInsets.only(top: 20.0),
                   child: GestureDetector(
                     onTap: (){},
                     child: Column(
                       children: [
                         Icon(Icons.more_horiz),
                         Text('See more')
                       ],
                     ),
                   ),
                 ),
               ],
             ),
            ),
          ),
        ),
      )
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Vehicle'),
        centerTitle: true,
      ),
      floatingActionButton:
          FloatingActionButton(onPressed: () {}, child: Icon(Icons.add)),
      body: ListView.builder(
        itemCount: 3,
        itemBuilder: (BuildContext context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            child: SizedBox(
              child: Card(
                elevation: 4.0,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal:20.0),
                            child: Text('KIA',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                          GestureDetector(
                            onTap: (){
                              _showDialog();
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Align(
                                  alignment: Alignment.bottomRight,
                                  child: Icon(Icons.more_vert, color: Colors.blueAccent,)),
                            ),
                          )
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset(
                              'assets/images/car.png',
                              scale: 2.5,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: RichText(
                                  text: TextSpan(
                                      style: TextStyle(color: Colors.black),
                                      children: <TextSpan>[
                                        TextSpan(
                                            text: 'Model : ',
                                            style:
                                                TextStyle(color: Colors.grey)),
                                        TextSpan(text: 'Picanto')
                                      ]),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: RichText(
                                  text: TextSpan(
                                      style: TextStyle(color: Colors.black),
                                      children: <TextSpan>[
                                        TextSpan(
                                            text: 'Color : ',
                                            style:
                                                TextStyle(color: Colors.grey)),
                                        TextSpan(text: 'Red')
                                      ]),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: RichText(
                                  text: TextSpan(
                                      style: TextStyle(color: Colors.black),
                                      children: <TextSpan>[
                                        TextSpan(
                                            text: 'Plate number : ',
                                            style:
                                                TextStyle(color: Colors.grey)),
                                        TextSpan(text: 'ABC123')
                                      ]),
                                ),
                              ),

                            ],
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

}



